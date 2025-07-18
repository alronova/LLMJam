package main

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Frontend Request Model
type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type RequestPayload struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
}

// Chat Model
type ChatModel struct {
	ID		 	primitive.ObjectID	`json:"id"`
	Title	  	string            	`json:"title"`
	Description string            	`json:"description"`
	Chat	 	[]Message			`json:"chat"`
}

// User Model
type User struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Email     string             `bson:"email" json:"email" binding:"required,email"`
	Password  string             `bson:"password" json:"password"`
	FirstName string             `bson:"first_name" json:"firstName"`
	LastName  string             `bson:"last_name" json:"lastName"`
	Chats     []ChatModel		 `bson:"chats" json:"chats"`
	CreatedAt time.Time          `bson:"created_at" json:"createdAt"`
	UpdatedAt time.Time          `bson:"updated_at" json:"updatedAt"`
}

// SignUp Request Model
type SignupRequest struct {
	Email     string `json:"email" binding:"required,email"`
	Password  string `json:"password" binding:"required,min=6"`
	FirstName string `json:"firstName" binding:"required"`
	LastName  string `json:"lastName" binding:"required"`
}

// Login Request Model
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// Login Response Model
type LoginResponse struct {
	User  User   `json:"user"`
	Token string `json:"token"`
}

// Chat Update Request Model
type ChatUpdateModel struct {
	Chat     ChatModel	`json:"chat"`
}

// Message Update Request Model
type MessageUpdateModel struct {
	ChatID   primitive.ObjectID `json:"chatId"`
	Message  Message            `json:"message"`
}

// General Response Model
type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}

type SuccessResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}