package server

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"time"
)

// Server holds the HTTP server and shared application dependencies.
type Server struct {
	address    string       // Network address the server listens on.
	httpServer *http.Server // Underlying HTTP server with routing and timeouts.
	db         *sql.DB      // Database handle shared across handlers.
}

// New creates a configured application server with database access.
func New(applicationAddress string, database *sql.DB) *Server {
	var requestMultiplexer *http.ServeMux // Routes incoming requests to the correct handler by method and path.
	var applicationServer  *Server        // Application server with shared dependencies and HTTP server.
	var standardHTTPServer *http.Server   // Standard library HTTP server configured with routing and timeouts.

	requestMultiplexer = http.NewServeMux()

	applicationServer = &Server{
		address: applicationAddress,
		db:      database,
	}

	applicationServer.registerRoutes(requestMultiplexer)

	standardHTTPServer = &http.Server{
		Addr:         applicationAddress,
		Handler:      requestMultiplexer,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	applicationServer.httpServer = standardHTTPServer

	return applicationServer
}

// Start begins listening and serving HTTP requests.
func (applicationServer *Server) Start() error {
	return applicationServer.httpServer.ListenAndServe()
}

// registerRoutes attaches all routes for the application.
func (applicationServer *Server) registerRoutes(requestMultiplexer *http.ServeMux) {
	requestMultiplexer.HandleFunc("GET /api/health", applicationServer.handleHealth)
}

// handleHealth responds with application and database health status.
func (applicationServer *Server) handleHealth(responseWriter http.ResponseWriter, request *http.Request) {
	var pingError      error  // Error returned if the database is unreachable.
	var databaseStatus string // Current database connectivity status.

	pingError = applicationServer.db.PingContext(request.Context())
	if pingError != nil {
		databaseStatus = "unreachable"
	} else {
		databaseStatus = "ok"
	}

	responseWriter.Header().Set("Content-Type", "application/json")

	json.NewEncoder(responseWriter).Encode(map[string]string{
		"status":   "ok",
		"database": databaseStatus,
	})
}