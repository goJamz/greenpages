package main

import (
	"log"
	"net/http"
)

func main() {
	var applicationAddress string   // Network address the HTTP server listens on.
	var requestMultiplexer *http.ServeMux // Routes incoming requests to the correct handler by method and path.
	var serverError error          // Error returned when the HTTP server stops unexpectedly.

	applicationAddress = ":8080"

	requestMultiplexer = http.NewServeMux()

	requestMultiplexer.HandleFunc("GET /api/health", func(responseWriter http.ResponseWriter, request *http.Request) {
		responseWriter.Header().Set("Content-Type", "application/json")
		_, _ = responseWriter.Write([]byte(`{"status":"ok"}`))
	})

	log.Printf("starting server on %s", applicationAddress)

	serverError = http.ListenAndServe(applicationAddress, requestMultiplexer)
	if serverError != nil {
		log.Fatal(serverError)
	}
}