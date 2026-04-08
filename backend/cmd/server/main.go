package main

import (
	"log"
	"net/http"
)

func main() {
	var applicationAddress string        // Network address the HTTP server listens on.
	var requestHandler http.Handler      // Root HTTP handler for all incoming requests.
	var serverError error                // Error returned when the HTTP server stops unexpectedly.

	applicationAddress = ":8080"

	requestHandler = http.HandlerFunc(func(responseWriter http.ResponseWriter, request *http.Request) {
		_, _ = responseWriter.Write([]byte("greenpages backend is running\n"))
	})

	log.Printf("starting server on %s", applicationAddress)

	serverError = http.ListenAndServe(applicationAddress, requestHandler)
	if serverError != nil {
		log.Fatal(serverError)
	}
}