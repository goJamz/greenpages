package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"regexp"
	"strings"
)

var alphaNumericCleanupPattern = regexp.MustCompile(`[^a-z0-9]+`)

const sectionsSearchQuery = `
WITH searchable_sections AS (
    SELECT
        sections.section_id,
        sections.organization_id,
        organizations.organization_name,
        COALESCE(organizations.short_name, '') AS organization_short_name,
        sections.section_code,
        sections.section_name,
        sections.display_name,
        trim(both ' ' from organizations.organization_name || ' ' || sections.display_name) AS full_display_name,
        regexp_replace(lower(organizations.organization_name), '[^a-z0-9]+', '', 'g') AS normalized_organization_name,
        regexp_replace(lower(COALESCE(organizations.short_name, '')), '[^a-z0-9]+', '', 'g') AS normalized_organization_short_name,
        regexp_replace(lower(sections.section_code), '[^a-z0-9]+', '', 'g') AS normalized_section_code,
        regexp_replace(lower(sections.section_name), '[^a-z0-9]+', '', 'g') AS normalized_section_name,
        regexp_replace(lower(sections.display_name), '[^a-z0-9]+', '', 'g') AS normalized_display_name
    FROM sections
    INNER JOIN organizations
        ON organizations.organization_id = sections.organization_id
    WHERE organizations.is_current = TRUE
      AND sections.is_current = TRUE
)
SELECT
    searchable_sections.section_id,
    searchable_sections.organization_id,
    searchable_sections.organization_name,
    searchable_sections.organization_short_name,
    searchable_sections.section_code,
    searchable_sections.section_name,
    searchable_sections.display_name,
    searchable_sections.full_display_name
FROM searchable_sections
WHERE
    searchable_sections.normalized_section_code LIKE '%' || $1 || '%'
    OR searchable_sections.normalized_section_name LIKE '%' || $1 || '%'
    OR searchable_sections.normalized_display_name LIKE '%' || $1 || '%'
    OR searchable_sections.normalized_organization_name LIKE '%' || $1 || '%'
    OR searchable_sections.normalized_organization_short_name LIKE '%' || $1 || '%'
    OR (searchable_sections.normalized_organization_name || searchable_sections.normalized_display_name) LIKE '%' || $1 || '%'
    OR (searchable_sections.normalized_organization_short_name || searchable_sections.normalized_display_name) LIKE '%' || $1 || '%'
    OR (searchable_sections.normalized_organization_name || searchable_sections.normalized_section_code) LIKE '%' || $1 || '%'
    OR (searchable_sections.normalized_organization_short_name || searchable_sections.normalized_section_code) LIKE '%' || $1 || '%'
ORDER BY
    CASE
        WHEN (searchable_sections.normalized_organization_name || searchable_sections.normalized_display_name) = $1 THEN 1
        WHEN (searchable_sections.normalized_organization_short_name || searchable_sections.normalized_display_name) = $1 THEN 2
        WHEN (searchable_sections.normalized_organization_name || searchable_sections.normalized_section_code) = $1 THEN 3
        WHEN (searchable_sections.normalized_organization_short_name || searchable_sections.normalized_section_code) = $1 THEN 4
        WHEN searchable_sections.normalized_display_name = $1 THEN 5
        WHEN searchable_sections.normalized_section_code = $1 THEN 6
        ELSE 7
    END,
    searchable_sections.organization_name ASC,
    searchable_sections.display_name ASC
LIMIT 25;
`

type sectionSearchRecord struct {
	SectionID             int64
	OrganizationID        int64
	OrganizationName      string
	OrganizationShortName string
	SectionCode           string
	SectionName           string
	DisplayName           string
	FullDisplayName       string
}

type SectionSearchResult struct {
	SectionID             int64  `json:"section_id"`
	OrganizationID        int64  `json:"organization_id"`
	OrganizationName      string `json:"organization_name"`
	OrganizationShortName string `json:"organization_short_name"`
	SectionCode           string `json:"section_code"`
	SectionName           string `json:"section_name"`
	DisplayName           string `json:"display_name"`
	FullDisplayName       string `json:"full_display_name"`
}

type SectionSearchResponse struct {
	Query   string                `json:"query"`
	Count   int                   `json:"count"`
	Results []SectionSearchResult `json:"results"`
}

func normalizeSearchInput(rawInput string) string {
	var trimmedInput string // User input after trimming leading and trailing whitespace.
	var lowerCasedInput string // Search input converted to lowercase for consistent matching.
	var normalizedInput string // Search input reduced to alphanumeric characters for forgiving search behavior.

	trimmedInput = strings.TrimSpace(rawInput)
	lowerCasedInput = strings.ToLower(trimmedInput)
	normalizedInput = alphaNumericCleanupPattern.ReplaceAllString(lowerCasedInput, "")

	return normalizedInput
}

func (applicationServer *Server) handleSectionSearch(responseWriter http.ResponseWriter, request *http.Request) {
	var rawSearchQuery string // Raw q parameter received from the incoming request.
	var normalizedSearchQuery string // Normalized q value used for database matching.
	var sectionSearchResults []SectionSearchResult // Results returned from the database-backed search.
	var sectionSearchError error // Error returned while executing the section search.
	var responsePayload SectionSearchResponse // Success response payload encoded as JSON.

	responseWriter.Header().Set("Content-Type", "application/json")

	rawSearchQuery = request.URL.Query().Get("q")
	normalizedSearchQuery = normalizeSearchInput(rawSearchQuery)

	if normalizedSearchQuery == "" {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "query parameter q is required",
		})
		return
	}

	sectionSearchResults, sectionSearchError = applicationServer.searchSections(request.Context(), normalizedSearchQuery)
	if sectionSearchError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to search sections",
		})
		return
	}

	responsePayload = SectionSearchResponse{
		Query:   rawSearchQuery,
		Count:   len(sectionSearchResults),
		Results: sectionSearchResults,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(responsePayload)
}

func (applicationServer *Server) searchSections(
	requestContext context.Context,
	normalizedSearchQuery string,
) ([]SectionSearchResult, error) {
	var queryRows *sql.Rows // Database result set returned for the section search query.
	var currentSectionRecord sectionSearchRecord // Single scanned database row from the current iteration.
	var currentSectionResult SectionSearchResult // API response item built from the scanned database row.
	var sectionSearchResults []SectionSearchResult // Full set of API response items collected from the query.
	var sectionSearchError error // Error returned by the database query or row scanning.

	queryRows, sectionSearchError = applicationServer.db.QueryContext(
		requestContext,
		sectionsSearchQuery,
		normalizedSearchQuery,
	)
	if sectionSearchError != nil {
		return nil, sectionSearchError
	}
	defer queryRows.Close()

	sectionSearchResults = make([]SectionSearchResult, 0)

	for queryRows.Next() {
		currentSectionRecord = sectionSearchRecord{}

		sectionSearchError = queryRows.Scan(
			&currentSectionRecord.SectionID,
			&currentSectionRecord.OrganizationID,
			&currentSectionRecord.OrganizationName,
			&currentSectionRecord.OrganizationShortName,
			&currentSectionRecord.SectionCode,
			&currentSectionRecord.SectionName,
			&currentSectionRecord.DisplayName,
			&currentSectionRecord.FullDisplayName,
		)
		if sectionSearchError != nil {
			return nil, sectionSearchError
		}

		currentSectionResult = SectionSearchResult{
			SectionID:             currentSectionRecord.SectionID,
			OrganizationID:        currentSectionRecord.OrganizationID,
			OrganizationName:      currentSectionRecord.OrganizationName,
			OrganizationShortName: currentSectionRecord.OrganizationShortName,
			SectionCode:           currentSectionRecord.SectionCode,
			SectionName:           currentSectionRecord.SectionName,
			DisplayName:           currentSectionRecord.DisplayName,
			FullDisplayName:       currentSectionRecord.FullDisplayName,
		}

		sectionSearchResults = append(sectionSearchResults, currentSectionResult)
	}

	sectionSearchError = queryRows.Err()
	if sectionSearchError != nil {
		return nil, sectionSearchError
	}

	return sectionSearchResults, nil
}