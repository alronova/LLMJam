package main

import (
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
			auth.POST("/chat", authMiddleware(), chatUpdateHandler)
			auth.POST("/message", authMiddleware(), messageUpdateHandler)
			auth.GET("/profile", authMiddleware(), profileHandler)
		}

		// Chat Route
		api.POST("/chat", authMiddleware(), chatHandler)
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