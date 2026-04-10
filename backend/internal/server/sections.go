package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"regexp"
	"strings"
)

// alphaNumericPattern strips everything except lowercase letters and digits.
// Used to normalize search input so "G-6", "G 6", and "g6" all match the same way.
var alphaNumericPattern = regexp.MustCompile(`[^a-z0-9]+`)

// sectionsSearchQuery finds sections by matching the normalized search input
// against section codes, section names, display names, and organization names.
// Concatenated fields allow queries like "XVIII Airborne Corps G6" to match.
const sectionsSearchQuery = `
WITH searchable AS (
    SELECT
        s.section_id,
        s.organization_id,
        o.organization_name,
        COALESCE(o.short_name, '')                AS organization_short_name,
        s.section_code,
        s.section_name,
        s.display_name,
        regexp_replace(LOWER(o.organization_name),           '[^a-z0-9]+', '', 'g') AS norm_org,
        regexp_replace(LOWER(COALESCE(o.short_name, '')),    '[^a-z0-9]+', '', 'g') AS norm_org_short,
        regexp_replace(LOWER(s.section_code),                '[^a-z0-9]+', '', 'g') AS norm_code,
        regexp_replace(LOWER(s.section_name),                '[^a-z0-9]+', '', 'g') AS norm_name,
        regexp_replace(LOWER(COALESCE(s.display_name, '')),  '[^a-z0-9]+', '', 'g') AS norm_display
    FROM sections s
    INNER JOIN organizations o ON o.organization_id = s.organization_id
    WHERE o.is_current = TRUE
      AND s.is_current = TRUE
)
SELECT
    section_id,
    organization_id,
    organization_name,
    organization_short_name,
    section_code,
    section_name,
    display_name
FROM searchable
WHERE
    norm_code LIKE '%' || $1 || '%'
    OR norm_name LIKE '%' || $1 || '%'
    OR norm_display LIKE '%' || $1 || '%'
    OR norm_org LIKE '%' || $1 || '%'
    OR norm_org_short LIKE '%' || $1 || '%'
    OR (norm_org || norm_code) LIKE '%' || $1 || '%'
    OR (norm_org_short || norm_code) LIKE '%' || $1 || '%'
    OR (norm_org || norm_display) LIKE '%' || $1 || '%'
    OR (norm_org_short || norm_display) LIKE '%' || $1 || '%'
ORDER BY
    CASE
        WHEN norm_code = $1 THEN 1
        WHEN norm_name = $1 THEN 2
        WHEN norm_display = $1 THEN 3
        WHEN (norm_org || norm_code) = $1 THEN 4
        WHEN (norm_org_short || norm_code) = $1 THEN 5
        WHEN (norm_org || norm_display) = $1 THEN 6
        WHEN (norm_org_short || norm_display) = $1 THEN 7
        ELSE 8
    END,
    organization_name ASC,
    display_name ASC
LIMIT 25;
`

// sectionSearchResult represents a single section returned by the search endpoint.
type sectionSearchResult struct {
	SectionID             int64  `json:"section_id"`              // Primary key of the section.
	OrganizationID        int64  `json:"organization_id"`         // Parent organization primary key.
	OrganizationName      string `json:"organization_name"`       // Parent organization name.
	OrganizationShortName string `json:"organization_short_name"` // Short name like "18 ABN Corps".
	SectionCode           string `json:"section_code"`            // Section code like "G-6" or "S-3".
	SectionName           string `json:"section_name"`            // Human-readable section name like "Signal".
	DisplayName           string `json:"display_name"`            // Section display label like "G-6".
}

// sectionSearchResponse wraps the search results with the original query and count.
type sectionSearchResponse struct {
	Query   string                `json:"query"`   // Original search input from the user.
	Count   int                   `json:"count"`   // Number of results returned.
	Results []sectionSearchResult `json:"results"` // Matching sections.
}

// normalizeSearchInput strips whitespace, lowercases, and removes non-alphanumeric
// characters so that "G-6", "G 6", and "g6" all produce the same search term.
func normalizeSearchInput(rawInput string) string {
	var lowered string // Input converted to lowercase.
	var normalized string // Input reduced to alphanumeric characters only.

	lowered = strings.ToLower(strings.TrimSpace(rawInput))
	normalized = alphaNumericPattern.ReplaceAllString(lowered, "")

	return normalized
}

// handleSectionsSearch handles GET /api/sections/search?q=...
func (applicationServer *Server) handleSectionsSearch(responseWriter http.ResponseWriter, request *http.Request) {
	var rawQuery string // Raw q parameter from the URL.
	var normalizedQuery string // Cleaned search term for database matching.
	var results []sectionSearchResult // Results from the database search.
	var searchError error // Error returned by the search function.
	var response sectionSearchResponse // JSON response payload.

	responseWriter.Header().Set("Content-Type", "application/json")

	rawQuery = request.URL.Query().Get("q")
	normalizedQuery = normalizeSearchInput(rawQuery)

	if normalizedQuery == "" {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "q parameter is required",
		})
		return
	}

	results, searchError = applicationServer.searchSections(request.Context(), normalizedQuery)
	if searchError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "search query failed",
		})
		return
	}

	response = sectionSearchResponse{
		Query:   rawQuery,
		Count:   len(results),
		Results: results,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(response)
}

// searchSections queries the database for sections matching the normalized search term.
func (applicationServer *Server) searchSections(requestContext context.Context, normalizedQuery string) ([]sectionSearchResult, error) {
	var rows *sql.Rows // Result set from the database query.
	var results []sectionSearchResult // Collected search results.
	var current sectionSearchResult // Current row being scanned.
	var queryError error // Error returned by the query or row scan.

	rows, queryError = applicationServer.db.QueryContext(requestContext, sectionsSearchQuery, normalizedQuery)
	if queryError != nil {
		return nil, queryError
	}
	defer rows.Close()

	results = make([]sectionSearchResult, 0)

	for rows.Next() {
		current = sectionSearchResult{}

		queryError = rows.Scan(
			&current.SectionID,
			&current.OrganizationID,
			&current.OrganizationName,
			&current.OrganizationShortName,
			&current.SectionCode,
			&current.SectionName,
			&current.DisplayName,
		)
		if queryError != nil {
			return nil, queryError
		}

		results = append(results, current)
	}

	queryError = rows.Err()
	if queryError != nil {
		return nil, queryError
	}

	return results, nil
}