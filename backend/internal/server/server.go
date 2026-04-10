// backend/internal/server/server.go
package server

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"time"
)

// Server holds the HTTP server and shared application dependencies.
type Server struct {
	httpServer *http.Server // Underlying HTTP server with routing and timeouts.
	db         *sql.DB      // Database handle shared across handlers.
}

// New creates a configured application server with database access.
func New(applicationAddress string, database *sql.DB) *Server {
	var requestMultiplexer *http.ServeMux // Routes incoming requests to the correct handler by method and path.
	var applicationServer *Server         // Application server with shared dependencies and HTTP server.
	var standardHTTPServer *http.Server   // Standard library HTTP server configured with routing and timeouts.

	requestMultiplexer = http.NewServeMux()

	applicationServer = &Server{
		db: database,
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
	requestMultiplexer.HandleFunc("GET /api/readyz", applicationServer.handleReadyz)
	requestMultiplexer.HandleFunc("GET /api/sections/search", applicationServer.handleSectionsSearch)
}

// handleHealth responds with the application process status.
// Used as a Kubernetes liveness probe. Does not check dependencies.
func (applicationServer *Server) handleHealth(responseWriter http.ResponseWriter, request *http.Request) {
	responseWriter.Header().Set("Content-Type", "application/json")
	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(map[string]string{
		"status": "ok",
	})
}

// handleReadyz responds with the application readiness status.
// Used as a Kubernetes readiness probe. Checks database connectivity.
func (applicationServer *Server) handleReadyz(responseWriter http.ResponseWriter, request *http.Request) {
	var pingError error       // Error returned if the database is unreachable.
	var databaseStatus string // Current database connectivity status.

	pingError = applicationServer.db.PingContext(request.Context())
	if pingError != nil {
		databaseStatus = "unreachable"
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusServiceUnavailable)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"status":   "not ready",
			"database": databaseStatus,
		})
		return
	}

	databaseStatus = "ok"
	responseWriter.Header().Set("Content-Type", "application/json")
	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(map[string]string{
		"status":   "ready",
		"database": databaseStatus,
	})
}
