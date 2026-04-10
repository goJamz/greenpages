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

// sectionBilletsQuery returns every billet in a section with its primary
// occupant if one exists. Billets without an occupant row return NULLs
// for the person columns, which the handler interprets as Vacant.
const sectionBilletsQuery = `
SELECT
    b.billet_id,
    COALESCE(b.position_number, '')  AS position_number,
    b.billet_title,
    COALESCE(b.grade_code, '')       AS grade_code,
    COALESCE(b.rank_group, '')       AS rank_group,
    COALESCE(b.branch_code, '')      AS branch_code,
    COALESCE(b.mos_code, '')         AS mos_code,
    COALESCE(b.aoc_code, '')         AS aoc_code,
    COALESCE(b.component, '')        AS component,
    COALESCE(b.uic, '')              AS uic,
    COALESCE(b.paragraph_number, '') AS paragraph_number,
    COALESCE(b.line_number, '')      AS line_number,
    COALESCE(b.duty_location, '')    AS duty_location,
    COALESCE(b.state_code, '')       AS state_code,
    p.person_id,
    p.display_name                   AS occupant_name,
    p.rank                           AS occupant_rank,
    p.work_email                     AS occupant_email,
    p.work_phone                     AS occupant_phone,
    p.office_symbol                  AS occupant_office_symbol,
    bo.is_primary                    AS occupant_is_primary
FROM billets b
LEFT JOIN billet_occupants bo
    ON bo.billet_id = b.billet_id
    AND bo.occupancy_status = 'active'
LEFT JOIN people p
    ON p.person_id = bo.person_id
    AND p.is_current = TRUE
WHERE b.section_id = $1
  AND b.is_current = TRUE
ORDER BY
    b.position_number ASC,
    b.billet_title ASC,
    bo.is_primary DESC;
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
	DisplayName  string `json:"display_name"`  // Person name like "Johnson, Michael R.".
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
	var detailResult sectionDetail   // Section metadata loaded from the database.
	var billetRows *sql.Rows         // Result set of billets for the section.
	var billetMap map[int64]*billetResult // Groups occupants by billet ID.
	var billetOrder []int64          // Preserves the original query order of billet IDs.
	var billetResults []billetResult // Final ordered list of billets.
	var queryError error             // Error returned by the queries.

	// Load section metadata.
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

	// Load billets with occupants.
	billetRows, queryError = applicationServer.db.QueryContext(
		requestContext,
		sectionBilletsQuery,
		sectionID,
	)
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}
	defer billetRows.Close()

	billetMap = make(map[int64]*billetResult)
	billetOrder = make([]int64, 0)

	for billetRows.Next() {
		var billetID        int64          // Current billet ID from the row.
		var positionNumber  string         // Billet position number.
		var billetTitle     string         // Billet title.
		var gradeCode       string         // Grade code.
		var rankGroup       string         // Rank group.
		var branchCode      string         // Branch code.
		var mosCode         string         // MOS code.
		var aocCode         string         // AOC code.
		var component       string         // Component.
		var uic             string         // UIC.
		var paragraphNumber string         // Paragraph number.
		var lineNumber      string         // Line number.
		var dutyLocation    string         // Duty location.
		var stateCode       string         // State code.
		var personID        sql.NullInt64  // Person ID, NULL if no occupant.
		var occupantName    sql.NullString // Occupant display name.
		var occupantRank    sql.NullString // Occupant rank.
		var occupantEmail   sql.NullString // Occupant work email.
		var occupantPhone   sql.NullString // Occupant work phone.
		var occupantOffice  sql.NullString // Occupant office symbol.
		var occupantPrimary sql.NullBool   // Whether this is the primary occupant.

		queryError = billetRows.Scan(
			&billetID,
			&positionNumber,
			&billetTitle,
			&gradeCode,
			&rankGroup,
			&branchCode,
			&mosCode,
			&aocCode,
			&component,
			&uic,
			&paragraphNumber,
			&lineNumber,
			&dutyLocation,
			&stateCode,
			&personID,
			&occupantName,
			&occupantRank,
			&occupantEmail,
			&occupantPhone,
			&occupantOffice,
			&occupantPrimary,
		)
		if queryError != nil {
			return sectionDetail{}, nil, queryError
		}

		// First time seeing this billet — create the entry.
		if billetMap[billetID] == nil {
			billetMap[billetID] = &billetResult{
				BilletID:        billetID,
				PositionNumber:  positionNumber,
				BilletTitle:     billetTitle,
				GradeCode:       gradeCode,
				RankGroup:       rankGroup,
				BranchCode:      branchCode,
				MOSCode:         mosCode,
				AOCCode:         aocCode,
				Component:       component,
				UIC:             uic,
				ParagraphNumber: paragraphNumber,
				LineNumber:      lineNumber,
				DutyLocation:    dutyLocation,
				StateCode:       stateCode,
				Status:          "Vacant",
				Occupants:       make([]billetOccupant, 0),
			}
			billetOrder = append(billetOrder, billetID)
		}

		// If there is an occupant on this row, attach them.
		if personID.Valid {
			billetMap[billetID].Status = "Filled"
			billetMap[billetID].Occupants = append(billetMap[billetID].Occupants, billetOccupant{
				PersonID:     personID.Int64,
				DisplayName:  occupantName.String,
				Rank:         occupantRank.String,
				WorkEmail:    occupantEmail.String,
				WorkPhone:    occupantPhone.String,
				OfficeSymbol: occupantOffice.String,
				IsPrimary:    occupantPrimary.Bool,
			})
		}
	}

	queryError = billetRows.Err()
	if queryError != nil {
		return sectionDetail{}, nil, queryError
	}

	// Build the final ordered slice from the map.
	billetResults = make([]billetResult, 0, len(billetOrder))
	for _, id := range billetOrder {
		billetResults = append(billetResults, *billetMap[id])
	}

	return detailResult, billetResults, nil
}