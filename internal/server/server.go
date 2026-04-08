package server

import (
	"net/http"
	"time"
)

func New(applicationAddress string) *http.Server {
	var requestMultiplexer *http.ServeMux // Routes incoming requests to the correct handler by method and path.
	var applicationServer *http.Server    // Configured HTTP server instance returned to the caller.

	requestMultiplexer = http.NewServeMux()

	requestMultiplexer.HandleFunc("GET /api/health", func(responseWriter http.ResponseWriter, request *http.Request) {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusOK)
		_, _ = responseWriter.Write([]byte("{\"status\":\"ok\"}\n"))
	})

	applicationServer = &http.Server{
		Addr:         applicationAddress,
		Handler:      requestMultiplexer,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	return applicationServer
}