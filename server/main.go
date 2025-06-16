package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"context"
	"time"

	"github.com/joho/godotenv"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	mongo_client    	*mongo.Client
	db         			*mongo.Database
	usersColl  			*mongo.Collection
)

func main() {

	// Load Env Variables
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	apiKey := os.Getenv("API_KEY")
	apiURL := os.Getenv("BASE_URL")
	port := os.Getenv("PORT")


	// Initialize MongoDB connection
	if err := conn_DB(); err != nil {
		log.Fatal("Failed to connect to MongoDB:", err)
	}

	// Initialize Gin router
	router := gin.Default()

	// Configure CORS for Flutter app
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization"}
	config.AllowCredentials = true
	router.Use(cors.New(config))


	// API Routes
	api := router.Group("/api")
	{
		// Health Check Route
		api.GET("/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"status":    "healthy",
				"timestamp": time.Now(),
			})
		})

		// Auth Routes
		auth := api.Group("/auth")
		{
			auth.POST("/signup", signupHandler)
			auth.POST("/login", loginHandler)
			auth.POST("/logout", authMiddleware(), logoutHandler)
			auth.GET("/profile", authMiddleware(), profileHandler)
			auth.PUT("/profile", authMiddleware(), updateProfileHandler)
		}

		// Chat Route
		api.POST("/chat", func(c *gin.Context) {
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
		})
	}

	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func conn_DB() error {
	mongoURI := os.Getenv("MONGODB_URI")

	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	var err error
	mongo_client, err = mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
	if err != nil {
		return err
	}

	// Test connection
	if err = mongo_client.Ping(ctx, nil); err != nil {
		return err
	}

	dbName := os.Getenv("DATABASE_NAME")

	db = mongo_client.Database(dbName)
	usersColl = db.Collection("users")

	log.Println("Successfully connected to MongoDB")
	return nil
}