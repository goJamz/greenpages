package main

import (
	"log"
	"net/http"

	internalserver "github.com/goJamz/greenpages/backend/internal/server"
)

func main() {
	var applicationAddress string        // Network address the HTTP server listens on.
	var applicationServer *http.Server   // Configured HTTP server instance for the backend.
	var serverError error                // Error returned when the HTTP server stops unexpectedly.

	applicationAddress = ":8080"

	applicationServer = internalserver.New(applicationAddress)

	log.Printf("starting server on %s", applicationAddress)

	serverError = applicationServer.ListenAndServe()
	if serverError != nil {
		log.Fatal(serverError)
	}
}