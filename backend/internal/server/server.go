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
	var applicationServer  *Server        // Application server with shared dependencies and HTTP server.
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
	var pingError      error  // Error returned if the database is unreachable.
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
	_ = json.NewEncoder(responseWriter).Encode(map[string]string{
		"status":   "ready",
		"database": databaseStatus,
	})
}

// sectionResult represents a single section returned by the search endpoint.
type sectionResult struct {
	SectionID        int64  `json:"section_id"`        // Primary key of the section.
	SectionCode      string `json:"section_code"`      // Short code like G6, S3.
	SectionName      string `json:"section_name"`      // Section name like G-6.
	DisplayName      string `json:"display_name"`      // Full display name like "XVIII Airborne Corps G-6".
	OrganizationID   int64  `json:"organization_id"`   // Parent organization primary key.
	OrganizationName string `json:"organization_name"` // Parent organization name.
}

// handleSectionsSearch finds sections matching the query parameter q.
// Uses trigram similarity against section and organization names.
func (applicationServer *Server) handleSectionsSearch(responseWriter http.ResponseWriter, request *http.Request) {
	var queryParam string          // Raw search query from the URL.
	var rows       *sql.Rows       // Result set from the database query.
	var queryError error           // Error returned by the database query.
	var results    []sectionResult // Collected search results.
	var section    sectionResult   // Current row being scanned.
	var scanError  error           // Error returned when scanning a row.

	queryParam = request.URL.Query().Get("q")
	if queryParam == "" {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "q parameter is required",
		})
		return
	}

	rows, queryError = applicationServer.db.QueryContext(request.Context(), `
		SELECT
			s.section_id,
			s.section_code,
			s.section_name,
			COALESCE(s.display_name, s.section_name) AS display_name,
			o.organization_id,
			o.organization_name
		FROM sections s
		JOIN organizations o ON s.organization_id = o.organization_id
		WHERE
			s.normalized_section_name % LOWER($1)
			OR LOWER(COALESCE(s.display_name, '')) LIKE '%' || LOWER($1) || '%'
			OR o.normalized_name % LOWER($1)
			OR LOWER(o.organization_name) LIKE '%' || LOWER($1) || '%'
		ORDER BY
			similarity(s.normalized_section_name, LOWER($1)) DESC,
			o.organization_name ASC
		LIMIT 20
	`, queryParam)

	if queryError != nil {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "search query failed",
		})
		return
	}
	defer rows.Close()

	results = make([]sectionResult, 0)

	for rows.Next() {
		scanError = rows.Scan(
			&section.SectionID,
			&section.SectionCode,
			&section.SectionName,
			&section.DisplayName,
			&section.OrganizationID,
			&section.OrganizationName,
		)
		if scanError != nil {
			responseWriter.Header().Set("Content-Type", "application/json")
			responseWriter.WriteHeader(http.StatusInternalServerError)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "failed to read results",
			})
			return
		}
		results = append(results, section)
	}

	responseWriter.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(responseWriter).Encode(results)
}