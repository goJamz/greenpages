// backend/cmd/server/main.go
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net"
	"net/url"
	"os"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib" // Registers "pgx" as a database/sql driver.

	internalserver "code.cdso.army.mil/ai2c/greenpages/app/backend/internal/server"
)

func main() {
	var applicationAddress string                // Network address the HTTP server listens on.
	var databaseURL string                       // PostgreSQL connection string.
	var database *sql.DB                         // Database handle shared across all handlers.
	var applicationServer *internalserver.Server // Application server with routes and shared dependencies.
	var startupError error                       // Error returned during startup or server run.

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

	startupError = waitForDatabase(database)
	if startupError != nil {
		log.Fatalf("unable to reach database: %v", startupError)
	}

	applicationServer = internalserver.New(applicationAddress, database)

	log.Printf("starting server on %s", applicationAddress)

	startupError = applicationServer.Start()
	if startupError != nil {
		log.Fatal(startupError)
	}
}

// waitForDatabase pings the database until it responds or the retry budget is exhausted.
func waitForDatabase(database *sql.DB) error {
	var retryDeadline time.Time       // Absolute time at which to stop retrying.
	var pingContext context.Context   // Timeout context for a single ping attempt.
	var cancelPing context.CancelFunc // Cancels the per-attempt ping context.
	var pingError error               // Error returned by the most recent ping attempt.

	log.Println("waiting for database to become ready")

	retryDeadline = time.Now().Add(30 * time.Second)

	for {
		pingContext, cancelPing = context.WithTimeout(context.Background(), 2*time.Second)
		pingError = database.PingContext(pingContext)
		cancelPing()

		if pingError == nil {
			log.Println("database connection established")
			return nil
		}

		if time.Now().After(retryDeadline) {
			return fmt.Errorf("database did not become reachable within 30 seconds: %w", pingError)
		}

		time.Sleep(1 * time.Second)
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
// If DB_PASSWORD is not present, it retrieves the password from Azure Key Vault.
func loadDatabaseURL() (string, error) {
	var databaseURL string                      // Full connection string, either from env or assembled.
	var databaseHost string                     // PostgreSQL hostname.
	var databasePort string                     // PostgreSQL port.
	var databaseUser string                     // PostgreSQL username.
	var databasePassword string                 // PostgreSQL password from env or Key Vault.
	var databaseName string                     // PostgreSQL database name.
	var databaseSSLMode string                  // PostgreSQL SSL mode.
	var databasePasswordLoadedFromKeyVault bool // Tracks whether password came from Key Vault.
	var passwordError error                     // Error returned while loading the database password.

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

	if databaseHost == "" || databasePort == "" || databaseUser == "" || databaseName == "" {
		return "", fmt.Errorf("DATABASE_URL or DB_HOST, DB_PORT, DB_USER, and DB_NAME are required")
	}

	databasePasswordLoadedFromKeyVault = false

	if databasePassword == "" {
		databasePassword, passwordError = loadDatabasePasswordFromKeyVault()
		if passwordError != nil {
			return "", fmt.Errorf("DB_PASSWORD is empty and Key Vault password lookup failed: %w", passwordError)
		}

		databasePasswordLoadedFromKeyVault = true
	}

	if databaseSSLMode == "" {
		if databasePasswordLoadedFromKeyVault {
			return "", fmt.Errorf("DB_SSL_MODE is required when DB_PASSWORD is loaded from Key Vault")
		}

		databaseSSLMode = "disable"
	}

	databaseURL = assembleDatabaseURL(
		databaseHost,
		databasePort,
		databaseUser,
		databasePassword,
		databaseName,
		databaseSSLMode,
	)

	return databaseURL, nil
}

// assembleDatabaseURL builds a PostgreSQL URL from database connection parts.
// Username, password, host, port, and query values are handled through net/url
// helpers so special characters in passwords do not break the connection string.
func assembleDatabaseURL(
	databaseHost string,
	databasePort string,
	databaseUser string,
	databasePassword string,
	databaseName string,
	databaseSSLMode string,
) string {
	var connectionURL url.URL  // Structured PostgreSQL connection URL.
	var queryValues url.Values // Query values appended to the connection URL.

	connectionURL = url.URL{
		Scheme: "postgres",
		User:   url.UserPassword(databaseUser, databasePassword),
		Host:   net.JoinHostPort(databaseHost, databasePort),
		Path:   "/" + databaseName,
	}

	queryValues = url.Values{}
	queryValues.Set("sslmode", databaseSSLMode)
	connectionURL.RawQuery = queryValues.Encode()

	return connectionURL.String()
}
