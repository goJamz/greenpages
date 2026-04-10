package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
)

const sectionDetailQuery = `
SELECT
    s.section_id,
    s.organization_id,
    o.organization_name,
    COALESCE(o.short_name, '') AS organization_short_name,
    s.section_code,
    s.section_name,
    s.display_name
FROM sections s
INNER JOIN organizations o
    ON o.organization_id = s.organization_id
WHERE s.section_id = $1
  AND o.is_current = TRUE
  AND s.is_current = TRUE;
`

const sectionBilletsQuery = `
SELECT
    b.billet_id,
    COALESCE(b.position_number, '') AS position_number,
    b.billet_title,
    COALESCE(b.grade_code, '') AS grade_code,
    COALESCE(b.rank_group, '') AS rank_group,
    COALESCE(b.branch_code, '') AS branch_code,
    COALESCE(b.mos_code, '') AS mos_code,
    COALESCE(b.aoc_code, '') AS aoc_code,
    COALESCE(b.component, '') AS component,
    COALESCE(b.uic, '') AS uic,
    COALESCE(b.paragraph_number, '') AS paragraph_number,
    COALESCE(b.line_number, '') AS line_number,
    COALESCE(b.duty_location, '') AS duty_location,
    COALESCE(b.state_code, '') AS state_code
FROM billets b
WHERE b.section_id = $1
  AND b.is_current = TRUE
ORDER BY
    b.position_number ASC,
    b.billet_title ASC;
`

// sectionDetail represents the metadata for one section detail response.
type sectionDetail struct {
	SectionID             int64  `json:"section_id"`              // Primary key of the section.
	OrganizationID        int64  `json:"organization_id"`         // Parent organization primary key.
	OrganizationName      string `json:"organization_name"`       // Parent organization name.
	OrganizationShortName string `json:"organization_short_name"` // Parent organization short name.
	SectionCode           string `json:"section_code"`            // Section code like G6.
	SectionName           string `json:"section_name"`            // Human-readable section name.
	DisplayName           string `json:"display_name"`            // Full section label for display.
}

// billetResult represents a single billet returned in a section detail response.
type billetResult struct {
	BilletID        int64  `json:"billet_id"`        // Primary key of the billet.
	PositionNumber  string `json:"position_number"`  // Position number within the section.
	BilletTitle     string `json:"billet_title"`     // Human-readable billet title.
	GradeCode       string `json:"grade_code"`       // Grade like MAJ or SFC.
	RankGroup       string `json:"rank_group"`       // Officer, Enlisted, or other grouping.
	BranchCode      string `json:"branch_code"`      // Branch code like SC.
	MOSCode         string `json:"mos_code"`         // MOS code when present.
	AOCCode         string `json:"aoc_code"`         // AOC code when present.
	Component       string `json:"component"`        // Active, Guard, or Reserve.
	UIC             string `json:"uic"`              // Unit Identification Code.
	ParagraphNumber string `json:"paragraph_number"` // Force structure paragraph number.
	LineNumber      string `json:"line_number"`      // Force structure line number.
	DutyLocation    string `json:"duty_location"`    // Duty location.
	StateCode       string `json:"state_code"`       // State code.
}

// sectionDetailResponse is the payload for GET /api/sections/{sectionID}.
type sectionDetailResponse struct {
	Section sectionDetail  `json:"section"` // Section metadata.
	Billets []billetResult `json:"billets"` // Billets in the section.
}

// handleSectionDetail handles GET /api/sections/{sectionID}.
func (applicationServer *Server) handleSectionDetail(responseWriter http.ResponseWriter, request *http.Request) {
	var rawSectionID string                   // Raw section ID path value from the request URL.
	var parsedSectionID int64                 // Parsed numeric section ID used for database lookups.
	var parseError error                      // Error returned while parsing the section ID.
	var foundSection sectionDetail            // Section metadata returned from the database.
	var foundBillets []billetResult           // Billets returned for the section.
	var detailError error                     // Error returned while loading the section detail.
	var responsePayload sectionDetailResponse // JSON response payload.

	responseWriter.Header().Set("Content-Type", "application/json")

	rawSectionID = request.PathValue("sectionID")
	if rawSectionID == "" {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "sectionID path parameter is required",
		})
		return
	}

	parsedSectionID, parseError = strconv.ParseInt(rawSectionID, 10, 64)
	if parseError != nil {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "sectionID must be a valid integer",
		})
		return
	}

	foundSection, foundBillets, detailError = applicationServer.getSectionDetail(
		request.Context(),
		parsedSectionID,
	)
	if detailError != nil {
		if errors.Is(detailError, sql.ErrNoRows) {
			responseWriter.WriteHeader(http.StatusNotFound)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "section not found",
			})
			return
		}

		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to load section detail",
		})
		return
	}

	responsePayload = sectionDetailResponse{
		Section: foundSection,
		Billets: foundBillets,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(responsePayload)
}

// getSectionDetail loads one section and all billets currently attached to it.
func (applicationServer *Server) getSectionDetail(
	requestContext context.Context,
	sectionID int64,
) (sectionDetail, []billetResult, error) {
	var detailResult sectionDetail   // Section metadata loaded from the database.
	var billetRows *sql.Rows         // Result set of billets for the section.
	var billetResults []billetResult // Collected billet results.
	var currentBillet billetResult   // Current billet row being scanned.
	var queryError error             // Error returned by the queries.

	queryError = applicationServer.db.QueryRowContext(
		requestContext,
		sectionDetailQuery,
		sectionID,
	).Scan(
		&detailResult.SectionID,
		&detailResult.OrganizationID,
		&detailResult.OrganizationName,
		&detailResult.OrganizationShortName,
		&detailResult.SectionCode,
		&detailResult.SectionName,
		&detailResult.DisplayName,
	)
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}

	billetRows, queryError = applicationServer.db.QueryContext(
		requestContext,
		sectionBilletsQuery,
		sectionID,
	)
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}
	defer billetRows.Close()

	billetResults = make([]billetResult, 0)

	for billetRows.Next() {
		currentBillet = billetResult{}

		queryError = billetRows.Scan(
			&currentBillet.BilletID,
			&currentBillet.PositionNumber,
			&currentBillet.BilletTitle,
			&currentBillet.GradeCode,
			&currentBillet.RankGroup,
			&currentBillet.BranchCode,
			&currentBillet.MOSCode,
			&currentBillet.AOCCode,
			&currentBillet.Component,
			&currentBillet.UIC,
			&currentBillet.ParagraphNumber,
			&currentBillet.LineNumber,
			&currentBillet.DutyLocation,
			&currentBillet.StateCode,
		)
		if queryError != nil {
			return sectionDetail{}, nil, queryError
		}

		billetResults = append(billetResults, currentBillet)
	}

	queryError = billetRows.Err()
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}

	return detailResult, billetResults, nil
}
