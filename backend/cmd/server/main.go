package main

import (
	"log"

	internalserver "github.com/goJamz/greenpages/backend/internal/server"
)

func main() {
	var applicationAddress string                // Network address the HTTP server listens on.
	var applicationServer *internalserver.Server // Application server with routes and shared dependencies.
	var serverError        error                 // Error returned when the HTTP server stops unexpectedly.

	applicationAddress = ":8080"

	applicationServer = internalserver.New(applicationAddress)

	log.Printf("starting server on %s", applicationAddress)

	serverError = applicationServer.Start()
	if serverError != nil {
		log.Fatal(serverError)
	}
}