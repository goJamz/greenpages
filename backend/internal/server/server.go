package server

import (
	"net/http"
	"time"
)

// Server holds the HTTP server and future shared application dependencies.
type Server struct {
	address     string      // Network address the server listens on.
	httpServer *http.Server // Underlying HTTP server with routing and timeouts.
}

// New creates a configured application server.
func New(applicationAddress string) *Server {
	var requestMultiplexer *http.ServeMux // Routes incoming requests to the correct handler by method and path.
	var applicationServer  *Server        // Application server with shared dependencies and HTTP server.
	var standardHTTPServer *http.Server   // Standard library HTTP server configured with routing and timeouts.

	requestMultiplexer = http.NewServeMux()

	applicationServer = &Server{
		address: applicationAddress,
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

// handleHealth responds with the application health status.
func (applicationServer *Server) handleHealth(responseWriter http.ResponseWriter, request *http.Request) {
	responseWriter.Header().Set("Content-Type", "application/json")
	responseWriter.WriteHeader(http.StatusOK)
	_, _ = responseWriter.Write([]byte("{\"status\":\"ok\"}\n"))
}