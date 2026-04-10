package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"
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
    COALESCE(b.state_code, '') AS state_code,
    COALESCE(b.occupancy_status, 'unknown') AS occupancy_status,
    p.person_id,
    COALESCE(p.display_name, '') AS occupant_name,
    COALESCE(p.rank, '') AS occupant_rank,
    COALESCE(p.work_email, '') AS occupant_email,
    COALESCE(p.work_phone, '') AS occupant_phone,
    COALESCE(p.office_symbol, '') AS occupant_office_symbol,
    COALESCE(bo.is_primary, FALSE) AS occupant_is_primary
FROM billets b
LEFT JOIN billet_occupants bo
    ON bo.billet_id = b.billet_id
   AND bo.assignment_status = 'active'
LEFT JOIN people p
    ON p.person_id = bo.person_id
   AND p.is_current = TRUE
WHERE b.section_id = $1
  AND b.is_current = TRUE
ORDER BY
    COALESCE(b.position_number, '') ASC,
    b.billet_title ASC,
    bo.is_primary DESC,
    p.display_name ASC;
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

// billetOccupant represents a person currently occupying a billet.
type billetOccupant struct {
	PersonID     int64  `json:"person_id"`     // Primary key of the person.
	DisplayName  string `json:"display_name"`  // Person name.
	Rank         string `json:"rank"`          // Rank like COL, MAJ, MSG.
	WorkEmail    string `json:"work_email"`    // Work email address.
	WorkPhone    string `json:"work_phone"`    // Work phone number.
	OfficeSymbol string `json:"office_symbol"` // Office symbol like AFNC-G6.
	IsPrimary    bool   `json:"is_primary"`    // Whether this is the primary occupant.
}

// billetResult represents a single billet returned in a section detail response.
type billetResult struct {
	BilletID        int64            `json:"billet_id"`        // Primary key of the billet.
	PositionNumber  string           `json:"position_number"`  // Position number within the section.
	BilletTitle     string           `json:"billet_title"`     // Human-readable billet title.
	GradeCode       string           `json:"grade_code"`       // Grade like MAJ or SFC.
	RankGroup       string           `json:"rank_group"`       // Officer, Enlisted, or other grouping.
	BranchCode      string           `json:"branch_code"`      // Branch code like SC.
	MOSCode         string           `json:"mos_code"`         // MOS code when present.
	AOCCode         string           `json:"aoc_code"`         // AOC code when present.
	Component       string           `json:"component"`        // Active, Guard, or Reserve.
	UIC             string           `json:"uic"`              // Unit Identification Code.
	ParagraphNumber string           `json:"paragraph_number"` // Force structure paragraph number.
	LineNumber      string           `json:"line_number"`      // Force structure line number.
	DutyLocation    string           `json:"duty_location"`    // Duty location.
	StateCode       string           `json:"state_code"`       // State code.
	Status          string           `json:"status"`           // Filled, Vacant, or Unknown.
	Occupants       []billetOccupant `json:"occupants"`        // People currently occupying this billet.
}

// sectionDetailResponse is the payload for GET /api/sections/{sectionID}.
type sectionDetailResponse struct {
	Section sectionDetail  `json:"section"` // Section metadata.
	Billets []billetResult `json:"billets"` // Billets in the section with occupants.
}

// normalizeBilletStatus converts stored database values into API display values.
func normalizeBilletStatus(rawStatus string) string {
	var loweredStatus string // Lowercased billet status from the database.

	loweredStatus = strings.ToLower(strings.TrimSpace(rawStatus))

	switch loweredStatus {
	case "filled":
		return "Filled"
	case "vacant":
		return "Vacant"
	case "unknown":
		return "Unknown"
	default:
		return "Unknown"
	}
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

// getSectionDetail loads one section and all billets with their occupants.
func (applicationServer *Server) getSectionDetail(
	requestContext context.Context,
	sectionID int64,
) (sectionDetail, []billetResult, error) {
	var detailResult sectionDetail          // Section metadata loaded from the database.
	var billetRows *sql.Rows                // Result set of billets and occupants for the section.
	var billetResults []billetResult        // Final ordered list of billets.
	var currentBillet billetResult          // Current billet being assembled from one or more rows.
	var currentOccupant billetOccupant      // Current occupant built from the scanned row.
	var currentBilletID int64               // Billet ID from the current row.
	var currentPositionNumber string        // Position number from the current row.
	var currentBilletTitle string           // Billet title from the current row.
	var currentGradeCode string             // Grade code from the current row.
	var currentRankGroup string             // Rank group from the current row.
	var currentBranchCode string            // Branch code from the current row.
	var currentMOSCode string               // MOS code from the current row.
	var currentAOCCode string               // AOC code from the current row.
	var currentComponent string             // Component from the current row.
	var currentUIC string                   // UIC from the current row.
	var currentParagraphNumber string       // Paragraph number from the current row.
	var currentLineNumber string            // Line number from the current row.
	var currentDutyLocation string          // Duty location from the current row.
	var currentStateCode string             // State code from the current row.
	var currentOccupancyStatus string       // Billet occupancy status from the current row.
	var currentPersonID sql.NullInt64       // Person ID from the current row when an occupant exists.
	var currentOccupantName string          // Occupant display name from the current row.
	var currentOccupantRank string          // Occupant rank from the current row.
	var currentOccupantEmail string         // Occupant email from the current row.
	var currentOccupantPhone string         // Occupant phone from the current row.
	var currentOccupantOfficeSymbol string  // Occupant office symbol from the current row.
	var currentOccupantIsPrimary bool       // Primary flag from the current row.
	var previousBilletID int64              // Previous billet ID processed in the loop.
	var haveCurrentBillet bool              // Tracks whether a billet is currently being assembled.
	var queryError error                    // Error returned by the queries.

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
	haveCurrentBillet = false
	previousBilletID = 0

	for billetRows.Next() {
		queryError = billetRows.Scan(
			&currentBilletID,
			&currentPositionNumber,
			&currentBilletTitle,
			&currentGradeCode,
			&currentRankGroup,
			&currentBranchCode,
			&currentMOSCode,
			&currentAOCCode,
			&currentComponent,
			&currentUIC,
			&currentParagraphNumber,
			&currentLineNumber,
			&currentDutyLocation,
			&currentStateCode,
			&currentOccupancyStatus,
			&currentPersonID,
			&currentOccupantName,
			&currentOccupantRank,
			&currentOccupantEmail,
			&currentOccupantPhone,
			&currentOccupantOfficeSymbol,
			&currentOccupantIsPrimary,
		)
		if queryError != nil {
			return sectionDetail{}, nil, queryError
		}

		if !haveCurrentBillet || previousBilletID != currentBilletID {
			if haveCurrentBillet {
				billetResults = append(billetResults, currentBillet)
			}

			currentBillet = billetResult{
				BilletID:        currentBilletID,
				PositionNumber:  currentPositionNumber,
				BilletTitle:     currentBilletTitle,
				GradeCode:       currentGradeCode,
				RankGroup:       currentRankGroup,
				BranchCode:      currentBranchCode,
				MOSCode:         currentMOSCode,
				AOCCode:         currentAOCCode,
				Component:       currentComponent,
				UIC:             currentUIC,
				ParagraphNumber: currentParagraphNumber,
				LineNumber:      currentLineNumber,
				DutyLocation:    currentDutyLocation,
				StateCode:       currentStateCode,
				Status:          normalizeBilletStatus(currentOccupancyStatus),
				Occupants:       make([]billetOccupant, 0),
			}

			haveCurrentBillet = true
			previousBilletID = currentBilletID
		}

		if currentPersonID.Valid {
			currentOccupant = billetOccupant{
				PersonID:     currentPersonID.Int64,
				DisplayName:  currentOccupantName,
				Rank:         currentOccupantRank,
				WorkEmail:    currentOccupantEmail,
				WorkPhone:    currentOccupantPhone,
				OfficeSymbol: currentOccupantOfficeSymbol,
				IsPrimary:    currentOccupantIsPrimary,
			}

			currentBillet.Occupants = append(currentBillet.Occupants, currentOccupant)
			currentBillet.Status = "Filled"
		}
	}

	queryError = billetRows.Err()
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}

	if haveCurrentBillet {
		billetResults = append(billetResults, currentBillet)
	}

	return detailResult, billetResults, nil
}