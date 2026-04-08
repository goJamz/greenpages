package server

import (
	"net/http"
	"time"
)

// Server wraps an http.Server with application-specific configuration.
type Server struct {
	httpServer *http.Server // Underlying HTTP server with timeouts and routing.
	Addr       string       // Network address the server listens on.
}

// New creates a Server with routes registered and timeouts configured.
func New() *Server {
	var mux *http.ServeMux       // Routes incoming requests to the correct handler by method and path.
	var addr string              // Network address the server will listen on.
	var httpServer *http.Server  // Standard library HTTP server with timeout settings.

	addr = ":8080"

	mux = http.NewServeMux()
	registerRoutes(mux)

	httpServer = &http.Server{
		Addr:         addr,
		Handler:      mux,
		ReadTimeout:  10 * time.Second,  // Max time to read the full request including body.
		WriteTimeout: 30 * time.Second,  // Max time to write the full response.
		IdleTimeout:  120 * time.Second, // Max time to keep idle keep-alive connections open.
	}

	return &Server{
		httpServer: httpServer,
		Addr:       addr,
	}
}

// Start begins listening and serving HTTP requests. It blocks until the server
// encounters an error or is shut down.
func (s *Server) Start() error {
	return s.httpServer.ListenAndServe()
}

// registerRoutes adds all application routes to the provided mux.
func registerRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /api/health", handleHealth)
}

// handleHealth responds with the application health status.
func handleHealth(responseWriter http.ResponseWriter, request *http.Request) {
	responseWriter.Header().Set("Content-Type", "application/json")
	_, _ = responseWriter.Write([]byte(`{"status":"ok"}`))
}