package main

import (
	"log"

	"github.com/goJamz/greenpages/backend/internal/server"
)

func main() {
	var srv *server.Server // Configured HTTP server ready to listen.
	var serverError error  // Error returned when the server stops unexpectedly.

	srv = server.New()

	log.Printf("starting server on %s", srv.Addr)

	serverError = srv.Start()
	if serverError != nil {
		log.Fatal(serverError)
	}
}