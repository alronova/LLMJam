package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type RequestPayload struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	apiKey := os.Getenv("API_KEY")
	apiURL := os.Getenv("BASE_URL")
	port := os.Getenv("PORT")

	http.HandleFunc("/ask", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Only POST allowed", http.StatusMethodNotAllowed)
			return
		}

		// Parse JSON body from frontend
		var payload RequestPayload
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		// Marshal payload to JSON to send request to <apiURL>
		reqBody, err := json.Marshal(payload)
		if err != nil {
			http.Error(w, "Error marshaling request", http.StatusInternalServerError)
			return
		}

		// Create request to <apiURL>
		req, err := http.NewRequest("POST", apiURL, bytes.NewBuffer(reqBody))
		if err != nil {
			http.Error(w, "Error creating request", http.StatusInternalServerError)
			return
		}

		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", "Bearer "+apiKey)

		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			http.Error(w, "Error calling OpenRouter", http.StatusBadGateway)
			return
		}
		defer resp.Body.Close()

		// Read response and write back to frontend
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			http.Error(w, "Error reading response", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(resp.StatusCode)
		w.Write(body)
	})

	fmt.Println("Server running on http://localhost:"+port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}