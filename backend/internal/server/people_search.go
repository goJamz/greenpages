package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
)

// peopleSearchQuery finds people by normalized person fields first, but it also
// searches assignment context so users can find someone by combinations like
// "johnson g6", "netcom harris", or an office symbol.
const peopleSearchQuery = `
WITH searchable AS (
    SELECT
        p.person_id,
        p.display_name,
        COALESCE(p.rank, '') AS rank,
        COALESCE(p.work_email, '') AS work_email,
        COALESCE(p.work_phone, '') AS work_phone,
        COALESCE(p.office_symbol, '') AS office_symbol,
        b.billet_id,
        COALESCE(b.billet_title, '') AS billet_title,
        COALESCE(b.occupancy_status, 'unknown') AS billet_status,
        s.section_id,
        COALESCE(s.display_name, '') AS section_display_name,
        o.organization_id,
        COALESCE(o.organization_name, '') AS organization_name,
        COALESCE(o.short_name, '') AS organization_short_name,
        COALESCE(bo.is_primary, FALSE) AS is_primary,
        regexp_replace(LOWER(p.display_name), '[^a-z0-9]+', '', 'g') AS norm_person,
        regexp_replace(LOWER(COALESCE(p.work_email, '')), '[^a-z0-9]+', '', 'g') AS norm_email,
        regexp_replace(LOWER(COALESCE(p.office_symbol, '')), '[^a-z0-9]+', '', 'g') AS norm_office_symbol,
        regexp_replace(LOWER(COALESCE(b.billet_title, '')), '[^a-z0-9]+', '', 'g') AS norm_billet,
        regexp_replace(LOWER(COALESCE(s.display_name, '')), '[^a-z0-9]+', '', 'g') AS norm_section,
        regexp_replace(LOWER(COALESCE(o.organization_name, '')), '[^a-z0-9]+', '', 'g') AS norm_org,
        regexp_replace(LOWER(COALESCE(o.short_name, '')), '[^a-z0-9]+', '', 'g') AS norm_org_short
    FROM people p
    LEFT JOIN billet_occupants bo
        ON bo.person_id = p.person_id
       AND bo.assignment_status = 'active'
    LEFT JOIN billets b
        ON b.billet_id = bo.billet_id
       AND b.is_current = TRUE
    LEFT JOIN sections s
        ON s.section_id = b.section_id
       AND s.is_current = TRUE
    LEFT JOIN organizations o
        ON o.organization_id = s.organization_id
       AND o.is_current = TRUE
    WHERE p.is_current = TRUE
),
matched AS (
    SELECT
        person_id,
        display_name,
        rank,
        work_email,
        work_phone,
        office_symbol,
        billet_id,
        billet_title,
        billet_status,
        section_id,
        section_display_name,
        organization_id,
        organization_name,
        organization_short_name,
        is_primary,
        CASE
            WHEN norm_person = $1 THEN 1
            WHEN norm_email = $1 THEN 2
            WHEN norm_office_symbol = $1 THEN 3
            WHEN (norm_org || norm_person) = $1 THEN 4
            WHEN (norm_org_short || norm_person) = $1 THEN 5
            WHEN (norm_section || norm_person) = $1 THEN 6
            WHEN norm_person LIKE $1 || '%' THEN 7
            ELSE 8
        END AS match_rank
    FROM searchable
    WHERE
        norm_person LIKE '%' || $1 || '%'
        OR norm_email LIKE '%' || $1 || '%'
        OR norm_office_symbol LIKE '%' || $1 || '%'
        OR norm_billet LIKE '%' || $1 || '%'
        OR norm_section LIKE '%' || $1 || '%'
        OR norm_org LIKE '%' || $1 || '%'
        OR norm_org_short LIKE '%' || $1 || '%'
        OR (norm_org || norm_person) LIKE '%' || $1 || '%'
        OR (norm_org_short || norm_person) LIKE '%' || $1 || '%'
        OR (norm_section || norm_person) LIKE '%' || $1 || '%'
),
deduped AS (
    SELECT
        person_id,
        display_name,
        rank,
        work_email,
        work_phone,
        office_symbol,
        billet_id,
        billet_title,
        billet_status,
        section_id,
        section_display_name,
        organization_id,
        organization_name,
        organization_short_name,
        match_rank,
        ROW_NUMBER() OVER (
            PARTITION BY person_id
            ORDER BY
                match_rank ASC,
                is_primary DESC,
                organization_name ASC,
                section_display_name ASC,
                billet_title ASC
        ) AS person_row_rank
    FROM matched
)
SELECT
    person_id,
    display_name,
    rank,
    work_email,
    work_phone,
    office_symbol,
    billet_id,
    billet_title,
    billet_status,
    section_id,
    section_display_name,
    organization_id,
    organization_name,
    organization_short_name
FROM deduped
WHERE person_row_rank = 1
ORDER BY
    match_rank ASC,
    display_name ASC,
    organization_name ASC,
    section_display_name ASC
LIMIT 25;
`

// personSearchResult represents one person returned by the people search endpoint.
type personSearchResult struct {
	PersonID              int64  `json:"person_id"`               // Primary key of the person.
	DisplayName           string `json:"display_name"`            // Person display name.
	Rank                  string `json:"rank"`                    // Military rank like COL or SFC.
	WorkEmail             string `json:"work_email"`              // Work email address when available.
	WorkPhone             string `json:"work_phone"`              // Work phone number when available.
	OfficeSymbol          string `json:"office_symbol"`           // Office symbol when available.
	BilletID              int64  `json:"billet_id"`               // Current billet ID when available.
	BilletTitle           string `json:"billet_title"`            // Current billet title when available.
	BilletStatus          string `json:"billet_status"`           // Filled, Vacant, or Unknown.
	SectionID             int64  `json:"section_id"`              // Current section ID when available.
	SectionDisplayName    string `json:"section_display_name"`    // Current section display name when available.
	OrganizationID        int64  `json:"organization_id"`         // Current organization ID when available.
	OrganizationName      string `json:"organization_name"`       // Current organization name when available.
	OrganizationShortName string `json:"organization_short_name"` // Current organization short name when available.
}

// personSearchResponse wraps the people search results with the original query and count.
type personSearchResponse struct {
	Query   string               `json:"query"`   // Original search input from the user.
	Count   int                  `json:"count"`   // Number of results returned.
	Results []personSearchResult `json:"results"` // Matching people.
}

// handlePeopleSearch handles GET /api/people/search?q=...
func (applicationServer *Server) handlePeopleSearch(responseWriter http.ResponseWriter, request *http.Request) {
	var rawQuery string               // Raw q parameter from the URL.
	var normalizedQuery string        // Normalized search term used for database matching.
	var results []personSearchResult  // Search results returned from the database.
	var searchError error             // Error returned while searching for people.
	var response personSearchResponse // JSON response payload.

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

	results, searchError = applicationServer.searchPeople(request.Context(), normalizedQuery)
	if searchError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "search query failed",
		})
		return
	}

	response = personSearchResponse{
		Query:   rawQuery,
		Count:   len(results),
		Results: results,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(response)
}

// searchPeople queries the database for people matching the normalized search term.
func (applicationServer *Server) searchPeople(
	requestContext context.Context,
	normalizedQuery string,
) ([]personSearchResult, error) {
	var rows *sql.Rows               // Result set from the database query.
	var results []personSearchResult // Collected search results.
	var current personSearchResult   // Current row being scanned.
	var billetID sql.NullInt64       // Current billet ID when present.
	var sectionID sql.NullInt64      // Current section ID when present.
	var organizationID sql.NullInt64 // Current organization ID when present.
	var queryError error             // Error returned by the query or row scan.

	rows, queryError = applicationServer.db.QueryContext(
		requestContext,
		peopleSearchQuery,
		normalizedQuery,
	)
	if queryError != nil {
		return nil, queryError
	}
	defer rows.Close()

	results = make([]personSearchResult, 0)

	for rows.Next() {
		current = personSearchResult{}

		queryError = rows.Scan(
			&current.PersonID,
			&current.DisplayName,
			&current.Rank,
			&current.WorkEmail,
			&current.WorkPhone,
			&current.OfficeSymbol,
			&billetID,
			&current.BilletTitle,
			&current.BilletStatus,
			&sectionID,
			&current.SectionDisplayName,
			&organizationID,
			&current.OrganizationName,
			&current.OrganizationShortName,
		)
		if queryError != nil {
			return nil, queryError
		}

		if billetID.Valid {
			current.BilletID = billetID.Int64
		}

		if sectionID.Valid {
			current.SectionID = sectionID.Int64
		}

		if organizationID.Valid {
			current.OrganizationID = organizationID.Int64
		}

		results = append(results, current)
	}

	queryError = rows.Err()
	if queryError != nil {
		return nil, queryError
	}

	return results, nil
}