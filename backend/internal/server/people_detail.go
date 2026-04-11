package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
)

const personDetailQuery = `
SELECT
    p.person_id,
    p.display_name,
    COALESCE(p.rank, '') AS rank,
    COALESCE(p.work_email, '') AS work_email,
    COALESCE(p.work_phone, '') AS work_phone,
    COALESCE(p.office_symbol, '') AS office_symbol,
    COALESCE(p.dod_id, '') AS dod_id
FROM people p
WHERE p.person_id = $1
  AND p.is_current = TRUE;
`

const personAssignmentsQuery = `
SELECT
    COALESCE(bo.is_primary, FALSE) AS is_primary,
    b.billet_id,
    b.billet_title,
    COALESCE(b.grade_code, '') AS billet_grade_code,
    COALESCE(b.position_number, '') AS position_number,
    COALESCE(b.branch_code, '') AS branch_code,
    COALESCE(b.mos_code, '') AS mos_code,
    COALESCE(b.aoc_code, '') AS aoc_code,
    COALESCE(b.component, '') AS component,
    COALESCE(b.occupancy_status, 'unknown') AS billet_status,
    s.section_id,
    COALESCE(s.section_code, '') AS section_code,
    COALESCE(s.display_name, '') AS section_display_name,
    o.organization_id,
    COALESCE(o.organization_name, '') AS organization_name,
    COALESCE(o.short_name, '') AS organization_short_name,
    COALESCE(b.uic, '') AS uic,
    COALESCE(b.paragraph_number, '') AS paragraph_number,
    COALESCE(b.line_number, '') AS line_number,
    COALESCE(b.duty_location, '') AS duty_location,
    COALESCE(b.state_code, '') AS state_code
FROM billet_occupants bo
INNER JOIN billets b
    ON b.billet_id = bo.billet_id
   AND b.is_current = TRUE
INNER JOIN sections s
    ON s.section_id = b.section_id
   AND s.is_current = TRUE
INNER JOIN organizations o
    ON o.organization_id = b.organization_id
   AND o.is_current = TRUE
WHERE bo.person_id = $1
  AND bo.assignment_status = 'active'
ORDER BY
    bo.is_primary DESC,
    o.organization_name ASC,
    s.display_name ASC,
    b.billet_title ASC;
`

// personDetail represents the person metadata returned by the detail endpoint.
type personDetail struct {
	PersonID     int64  `json:"person_id"`     // Primary key of the person.
	DisplayName  string `json:"display_name"`  // Human-readable person name.
	Rank         string `json:"rank"`          // Rank like COL, MAJ, or SFC.
	WorkEmail    string `json:"work_email"`    // Work email address when available.
	WorkPhone    string `json:"work_phone"`    // Work phone number when available.
	OfficeSymbol string `json:"office_symbol"` // Office symbol when available.
	DodID        string `json:"dod_id"`        // DoD ID when available.
}

// personAssignment represents one current assignment tied to the person.
type personAssignment struct {
	IsPrimary             bool   `json:"is_primary"`              // Whether this is the person's primary current assignment.
	BilletID              int64  `json:"billet_id"`               // Current billet ID.
	BilletTitle           string `json:"billet_title"`            // Current billet title.
	BilletGradeCode       string `json:"billet_grade_code"`       // Grade code of the billet.
	PositionNumber        string `json:"position_number"`         // Position number of the billet.
	BranchCode            string `json:"branch_code"`             // Branch code of the billet.
	MOSCode               string `json:"mos_code"`                // MOS code of the billet.
	AOCCode               string `json:"aoc_code"`                // AOC code of the billet.
	Component             string `json:"component"`               // Component like Active, Guard, or Reserve.
	BilletStatus          string `json:"billet_status"`           // Filled, Vacant, or Unknown.
	SectionID             int64  `json:"section_id"`              // Current section ID.
	SectionCode           string `json:"section_code"`            // Section code like G6.
	SectionDisplayName    string `json:"section_display_name"`    // Current section display name.
	OrganizationID        int64  `json:"organization_id"`         // Current organization ID.
	OrganizationName      string `json:"organization_name"`       // Current organization name.
	OrganizationShortName string `json:"organization_short_name"` // Current organization short name.
	UIC                   string `json:"uic"`                     // Unit Identification Code.
	ParagraphNumber       string `json:"paragraph_number"`        // Paragraph number.
	LineNumber            string `json:"line_number"`             // Line number.
	DutyLocation          string `json:"duty_location"`           // Duty location.
	StateCode             string `json:"state_code"`              // State code.
}

// personDetailResponse is the payload for GET /api/people/{personID}.
type personDetailResponse struct {
	Person      personDetail       `json:"person"`      // Core person identity.
	Assignments []personAssignment `json:"assignments"` // Current assignments for the person.
}

// handlePersonDetail handles GET /api/people/{personID}.
func (applicationServer *Server) handlePersonDetail(responseWriter http.ResponseWriter, request *http.Request) {
	var rawPersonID string                   // Raw person ID path value from the request URL.
	var parsedPersonID int64                 // Parsed numeric person ID used for database lookups.
	var parseError error                     // Error returned while parsing the person ID.
	var foundPerson personDetail             // Person metadata returned from the database.
	var foundAssignments []personAssignment  // Current assignments returned for the person.
	var detailError error                    // Error returned while loading the person detail.
	var responsePayload personDetailResponse // JSON response payload.

	responseWriter.Header().Set("Content-Type", "application/json")

	rawPersonID = request.PathValue("personID")
	if rawPersonID == "" {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "personID path parameter is required",
		})
		return
	}

	parsedPersonID, parseError = strconv.ParseInt(rawPersonID, 10, 64)
	if parseError != nil {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "personID must be a valid integer",
		})
		return
	}

	foundPerson, foundAssignments, detailError = applicationServer.getPersonDetail(
		request.Context(),
		parsedPersonID,
	)
	if detailError != nil {
		if errors.Is(detailError, sql.ErrNoRows) {
			responseWriter.WriteHeader(http.StatusNotFound)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "person not found",
			})
			return
		}

		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to load person detail",
		})
		return
	}

	responsePayload = personDetailResponse{
		Person:      foundPerson,
		Assignments: foundAssignments,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(responsePayload)
}

// getPersonDetail loads one person and their current assignments.
func (applicationServer *Server) getPersonDetail(
	requestContext context.Context,
	personID int64,
) (personDetail, []personAssignment, error) {
	var detailResult personDetail            // Person metadata loaded from the database.
	var assignmentRows *sql.Rows             // Result set of current assignments for the person.
	var assignmentResults []personAssignment // Collected assignment results.
	var currentAssignment personAssignment   // Current assignment row being scanned.
	var queryError error                     // Error returned by the queries.

	queryError = applicationServer.db.QueryRowContext(
		requestContext,
		personDetailQuery,
		personID,
	).Scan(
		&detailResult.PersonID,
		&detailResult.DisplayName,
		&detailResult.Rank,
		&detailResult.WorkEmail,
		&detailResult.WorkPhone,
		&detailResult.OfficeSymbol,
		&detailResult.DodID,
	)
	if queryError != nil {
		return personDetail{}, nil, queryError
	}

	assignmentRows, queryError = applicationServer.db.QueryContext(
		requestContext,
		personAssignmentsQuery,
		personID,
	)
	if queryError != nil {
		return personDetail{}, nil, queryError
	}
	defer assignmentRows.Close()

	assignmentResults = make([]personAssignment, 0)

	for assignmentRows.Next() {
		currentAssignment = personAssignment{}

		queryError = assignmentRows.Scan(
			&currentAssignment.IsPrimary,
			&currentAssignment.BilletID,
			&currentAssignment.BilletTitle,
			&currentAssignment.BilletGradeCode,
			&currentAssignment.PositionNumber,
			&currentAssignment.BranchCode,
			&currentAssignment.MOSCode,
			&currentAssignment.AOCCode,
			&currentAssignment.Component,
			&currentAssignment.BilletStatus,
			&currentAssignment.SectionID,
			&currentAssignment.SectionCode,
			&currentAssignment.SectionDisplayName,
			&currentAssignment.OrganizationID,
			&currentAssignment.OrganizationName,
			&currentAssignment.OrganizationShortName,
			&currentAssignment.UIC,
			&currentAssignment.ParagraphNumber,
			&currentAssignment.LineNumber,
			&currentAssignment.DutyLocation,
			&currentAssignment.StateCode,
		)
		if queryError != nil {
			return personDetail{}, nil, queryError
		}

		currentAssignment.BilletStatus = normalizeBilletStatus(currentAssignment.BilletStatus)

		assignmentResults = append(assignmentResults, currentAssignment)
	}

	queryError = assignmentRows.Err()
	if queryError != nil {
		return personDetail{}, nil, queryError
	}

	return detailResult, assignmentResults, nil
}