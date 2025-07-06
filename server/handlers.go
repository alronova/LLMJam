package main

import (
	"os"
	"bytes"
	"encoding/json"
	"io"
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

func signupHandler(c *gin.Context) {
	var req SignupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
		return
	}

	// Check if user already exists
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	var existingUser User
	err := usersColl.FindOne(ctx, bson.M{"email": req.Email}).Decode(&existingUser)
	if err == nil {
		c.JSON(http.StatusConflict, ErrorResponse{
			Error:   "user_exists",
			Message: "User with this email already exists",
		})
		return
	}

	// Hash Password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "server_error",
			Message: "Failed to process password",
		})
		return
	}

	// Create New User
	user := User{
		Email:     req.Email,
		Password:  string(hashedPassword),
		FirstName: req.FirstName,
		LastName:  req.LastName,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	result, err := usersColl.InsertOne(ctx, user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "database_error",
			Message: "Failed to create user",
		})
		return
	}

	user.ID = result.InsertedID.(primitive.ObjectID)

	// Generate JWT Token
	token, err := generateJWT(user.ID.Hex())
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "token_error",
			Message: "Failed to generate authentication token",
		})
		return
	}

	c.JSON(http.StatusCreated, LoginResponse{
		User:  user,
		Token: token,
	})
}

func loginHandler(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
		return
	}

	// Find user by email
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	var user User
	err := usersColl.FindOne(ctx, bson.M{"email": req.Email}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusUnauthorized, ErrorResponse{
				Error:   "invalid_credentials",
				Message: "Invalid email or password",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "database_error",
			Message: "Failed to authenticate user",
		})
		return
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, ErrorResponse{
			Error:   "invalid_credentials",
			Message: "Invalid email or password",
		})
		return
	}

	// Generate JWT token
	token, err := generateJWT(user.ID.Hex())
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "token_error",
			Message: "Failed to generate authentication token",
		})
		return
	}

	c.JSON(http.StatusOK, LoginResponse{
		User:  user,
		Token: token,
	})
}

func chatUpdateHandler(c *gin.Context) {
	var req ChatUpdateModel
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "validation_error",
			Message: err.Error(),
		})
		return
	}
}

func messageUpdateHandler(c *gin.Context) {
    userID := c.GetString("userID")

    var req MessageUpdateModel
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Error:   "validation_error",
            Message: err.Error(),
        })
        return
    }

    objectID, err := primitive.ObjectIDFromHex(userID)
    if err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Error:   "invalid_user_id",
            Message: "Invalid user ID format",
        })
        return
    }

    filter := bson.M{
        "_id":      objectID,
        "chats.id": req.ChatID,
    }

    update := bson.M{
        "$push": bson.M{
            "chats.$.chat": req.Message,
        },
    }

    ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
    defer cancel()

    result, err := usersColl.UpdateOne(ctx, filter, update)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{
            Error:   "update_failed",
            Message: "Failed to update chat",
        })
        return
    }

    if result.MatchedCount == 0 {
        c.JSON(http.StatusNotFound, ErrorResponse{
            Error:   "chat_not_found",
            Message: "No chat found with the given ID for this user",
        })
        return
    }

    c.JSON(http.StatusOK, SuccessResponse{
        Message: "Chat updated successfully",
    })
}

func profileHandler(c *gin.Context) {
	userID := c.GetString("userID")

	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	objectID, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Error:   "invalid_user_id",
			Message: "Invalid user ID format",
		})
		return
	}

	var user User
	err = usersColl.FindOne(ctx, bson.M{"_id": objectID}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, ErrorResponse{
				Error:   "user_not_found",
				Message: "User not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Error:   "database_error",
			Message: "Failed to fetch user profile",
		})
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{
		Message: "Profile fetched successfully",
		Data:    user,
	})
}

func chatHandler(c *gin.Context) {
	
	apiKey := os.Getenv("API_KEY")
	apiURL := os.Getenv("BASE_URL")

	var payload RequestPayload
	if err := c.BindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	reqBody, err := json.Marshal(payload)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal payload"})
		return
	}

	req, err := http.NewRequest("POST", apiURL, bytes.NewBuffer(reqBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to reach external service"})
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response"})
		return
	}

	c.Data(resp.StatusCode, "application/json", body)		
}