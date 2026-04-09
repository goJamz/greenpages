package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib" // Registers "pgx" as a database/sql driver.

	internalserver "github.com/goJamz/greenpages/backend/internal/server"
)

func main() {
	var applicationAddress string                // Network address the HTTP server listens on.
	var databaseURL        string                // PostgreSQL connection string.
	var database           *sql.DB               // Database handle shared across all handlers.
	var applicationServer  *internalserver.Server // Application server with routes and shared dependencies.
	var startupContext     context.Context        // Timeout context for initial database connectivity check.
	var cancelStartup      context.CancelFunc     // Cancels the startup timeout context.
	var startupError       error                  // Error returned during startup or server run.

	applicationAddress = loadApplicationAddress()

	databaseURL, startupError = loadDatabaseURL()
	if startupError != nil {
		log.Fatalf("database configuration error: %v", startupError)
	}

	database, startupError = sql.Open("pgx", databaseURL)
	if startupError != nil {
		log.Fatalf("unable to open database: %v", startupError)
	}
	defer database.Close()

	startupContext, cancelStartup = context.WithTimeout(context.Background(), 5*time.Second)
	defer cancelStartup()

	startupError = database.PingContext(startupContext)
	if startupError != nil {
		log.Fatalf("unable to reach database: %v", startupError)
	}

	log.Println("database connection established")

	applicationServer = internalserver.New(applicationAddress, database)

	log.Printf("starting server on %s", applicationAddress)

	startupError = applicationServer.Start()
	if startupError != nil {
		log.Fatal(startupError)
	}
}

// loadApplicationAddress reads the listen port from the APP_PORT environment
// variable and returns it as a network address. Defaults to port 8080.
func loadApplicationAddress() string {
	var port string // Port value from environment.

	port = os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	return ":" + port
}

// loadDatabaseURL builds a PostgreSQL connection string. It checks for a
// DATABASE_URL override first. If not set, it assembles one from individual
// DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, and DB_SSL_MODE variables.
func loadDatabaseURL() (string, error) {
	var databaseURL      string // Full connection string, either from env or assembled.
	var databaseHost     string // PostgreSQL hostname.
	var databasePort     string // PostgreSQL port.
	var databaseUser     string // PostgreSQL username.
	var databasePassword string // PostgreSQL password.
	var databaseName     string // PostgreSQL database name.
	var databaseSSLMode  string // PostgreSQL SSL mode.

	// Prefer a single connection string if provided.
	databaseURL = os.Getenv("DATABASE_URL")
	if databaseURL != "" {
		return databaseURL, nil
	}

	// Fall back to individual connection variables.
	databaseHost = os.Getenv("DB_HOST")
	databasePort = os.Getenv("DB_PORT")
	databaseUser = os.Getenv("DB_USER")
	databasePassword = os.Getenv("DB_PASSWORD")
	databaseName = os.Getenv("DB_NAME")
	databaseSSLMode = os.Getenv("DB_SSL_MODE")

	if databaseHost == "" || databasePort == "" || databaseUser == "" || databasePassword == "" || databaseName == "" {
		return "", fmt.Errorf("DATABASE_URL or DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, and DB_NAME are required")
	}

	if databaseSSLMode == "" {
		databaseSSLMode = "disable"
	}

	databaseURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		databaseUser, databasePassword, databaseHost, databasePort, databaseName, databaseSSLMode)

	return databaseURL, nil
}