package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
)

// explorerPositionsQuery returns billets matching optional filter criteria.
// Each filter parameter uses the ($N = '' OR column = $N) pattern so that
// an empty string means "no filter on this column." The query joins the
// primary active occupant when one exists.
const explorerPositionsQuery = `
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
    b.occupancy_status,
    o.organization_id,
    COALESCE(o.organization_name, '') AS organization_name,
    COALESCE(o.short_name, '') AS organization_short_name,
    s.section_id,
    COALESCE(s.display_name, '') AS section_display_name,
    COALESCE(p.person_id, 0) AS occupant_person_id,
    COALESCE(p.display_name, '') AS occupant_display_name,
    COALESCE(p.rank, '') AS occupant_rank
FROM billets b
INNER JOIN organizations o
    ON o.organization_id = b.organization_id
   AND o.is_current = TRUE
INNER JOIN sections s
    ON s.section_id = b.section_id
   AND s.is_current = TRUE
LEFT JOIN billet_occupants bo
    ON bo.billet_id = b.billet_id
   AND bo.assignment_status = 'active'
   AND bo.is_primary = TRUE
LEFT JOIN people p
    ON p.person_id = bo.person_id
   AND p.is_current = TRUE
WHERE b.is_current = TRUE
  AND ($1 = '' OR b.component = $1)
  AND ($2 = '' OR b.grade_code = $2)
  AND ($3 = '' OR b.branch_code = $3)
  AND ($4 = '' OR b.mos_code = $4)
  AND ($5 = '' OR b.aoc_code = $5)
  AND ($6 = '' OR b.state_code = $6)
  AND ($7 = '' OR b.occupancy_status = $7)
ORDER BY
    o.organization_name ASC,
    s.display_name ASC,
    b.grade_code ASC,
    b.billet_title ASC
LIMIT $8 OFFSET $9;
`

// explorerPositionResult represents a single billet row in the explorer.
type explorerPositionResult struct {
	BilletID              int64  `json:"billet_id"`               // Primary key of the billet.
	PositionNumber        string `json:"position_number"`         // Position number within the section.
	BilletTitle           string `json:"billet_title"`            // Human-readable billet title.
	GradeCode             string `json:"grade_code"`              // Grade like COL, MAJ, SFC.
	RankGroup             string `json:"rank_group"`              // Officer or Enlisted.
	BranchCode            string `json:"branch_code"`             // Branch code like SC, IN.
	MOSCode               string `json:"mos_code"`                // MOS code like 25B, 11B.
	AOCCode               string `json:"aoc_code"`                // AOC code like 25A, 17A.
	Component             string `json:"component"`               // Active, Guard, or Reserve.
	UIC                   string `json:"uic"`                     // Unit Identification Code.
	ParagraphNumber       string `json:"paragraph_number"`        // Paragraph number.
	LineNumber            string `json:"line_number"`             // Line number.
	DutyLocation          string `json:"duty_location"`           // Duty station name.
	StateCode             string `json:"state_code"`              // State code.
	Status                string `json:"status"`                  // Filled, Vacant, or Unknown.
	OrganizationID        int64  `json:"organization_id"`         // Parent organization ID.
	OrganizationName      string `json:"organization_name"`       // Parent organization name.
	OrganizationShortName string `json:"organization_short_name"` // Organization short name.
	SectionID             int64  `json:"section_id"`              // Parent section ID.
	SectionDisplayName    string `json:"section_display_name"`    // Section display name.
	OccupantPersonID      int64  `json:"occupant_person_id"`      // Primary occupant person ID, 0 if none.
	OccupantDisplayName   string `json:"occupant_display_name"`   // Primary occupant name.
	OccupantRank          string `json:"occupant_rank"`           // Primary occupant rank.
}

// explorerPositionFilters echoes the applied filter values back to the caller.
type explorerPositionFilters struct {
	Component string `json:"component"`   // Component filter value, empty if not applied.
	GradeCode string `json:"grade_code"`  // Grade filter value, empty if not applied.
	BranchCode string `json:"branch_code"` // Branch filter value, empty if not applied.
	MOSCode   string `json:"mos_code"`    // MOS filter value, empty if not applied.
	AOCCode   string `json:"aoc_code"`    // AOC filter value, empty if not applied.
	StateCode string `json:"state_code"`  // State filter value, empty if not applied.
	Status    string `json:"status"`      // Status filter value, empty if not applied.
}

// explorerPositionsResponse wraps explorer results with filter echo, count, and pagination.
type explorerPositionsResponse struct {
	Filters explorerPositionFilters  `json:"filters"` // Applied filter values.
	Count   int                      `json:"count"`   // Number of results returned.
	Limit   int                      `json:"limit"`   // Max results per page.
	Offset  int                      `json:"offset"`  // Current offset.
	Results []explorerPositionResult `json:"results"` // Matching billets.
}

// handleExplorerPositions handles GET /api/explorer/positions with optional filter params.
func (applicationServer *Server) handleExplorerPositions(responseWriter http.ResponseWriter, request *http.Request) {
	var componentFilter string                // Component filter from query params.
	var gradeFilter string                    // Grade filter from query params.
	var branchFilter string                   // Branch filter from query params.
	var mosFilter string                      // MOS filter from query params.
	var aocFilter string                      // AOC filter from query params.
	var stateFilter string                    // State filter from query params.
	var statusFilter string                   // Status filter from query params.
	var limitParam string                     // Raw limit parameter from query params.
	var offsetParam string                    // Raw offset parameter from query params.
	var limit int                             // Parsed result limit.
	var offset int                            // Parsed result offset.
	var parseError error                      // Error from parsing limit or offset.
	var results []explorerPositionResult      // Results from the database query.
	var queryError error                      // Error returned by the query function.
	var response explorerPositionsResponse    // JSON response payload.

	responseWriter.Header().Set("Content-Type", "application/json")

	componentFilter = strings.TrimSpace(request.URL.Query().Get("component"))
	gradeFilter = strings.TrimSpace(request.URL.Query().Get("grade"))
	branchFilter = strings.TrimSpace(request.URL.Query().Get("branch"))
	mosFilter = strings.TrimSpace(request.URL.Query().Get("mos"))
	aocFilter = strings.TrimSpace(request.URL.Query().Get("aoc"))
	stateFilter = strings.TrimSpace(request.URL.Query().Get("state"))
	statusFilter = strings.ToLower(strings.TrimSpace(request.URL.Query().Get("status")))

	limit = 50
	limitParam = request.URL.Query().Get("limit")
	if limitParam != "" {
		limit, parseError = strconv.Atoi(limitParam)
		if parseError != nil || limit < 1 {
			limit = 50
		}
		if limit > 200 {
			limit = 200
		}
	}

	offset = 0
	offsetParam = request.URL.Query().Get("offset")
	if offsetParam != "" {
		offset, parseError = strconv.Atoi(offsetParam)
		if parseError != nil || offset < 0 {
			offset = 0
		}
	}

	results, queryError = applicationServer.queryExplorerPositions(
		request.Context(),
		componentFilter,
		gradeFilter,
		branchFilter,
		mosFilter,
		aocFilter,
		stateFilter,
		statusFilter,
		limit,
		offset,
	)
	if queryError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "explorer query failed",
		})
		return
	}

	response = explorerPositionsResponse{
		Filters: explorerPositionFilters{
			Component:  componentFilter,
			GradeCode:  gradeFilter,
			BranchCode: branchFilter,
			MOSCode:    mosFilter,
			AOCCode:    aocFilter,
			StateCode:  stateFilter,
			Status:     statusFilter,
		},
		Count:   len(results),
		Limit:   limit,
		Offset:  offset,
		Results: results,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(response)
}

// queryExplorerPositions runs the explorer query with the given filters and pagination.
func (applicationServer *Server) queryExplorerPositions(
	requestContext context.Context,
	componentFilter string,
	gradeFilter string,
	branchFilter string,
	mosFilter string,
	aocFilter string,
	stateFilter string,
	statusFilter string,
	limit int,
	offset int,
) ([]explorerPositionResult, error) {
	var rows *sql.Rows                   // Result set from the database query.
	var results []explorerPositionResult  // Collected position results.
	var current explorerPositionResult    // Current row being scanned.
	var rawStatus string                 // Raw occupancy status before normalization.
	var queryError error                 // Error returned by the query or row scan.

	rows, queryError = applicationServer.db.QueryContext(
		requestContext,
		explorerPositionsQuery,
		componentFilter,
		gradeFilter,
		branchFilter,
		mosFilter,
		aocFilter,
		stateFilter,
		statusFilter,
		limit,
		offset,
	)
	if queryError != nil {
		return nil, queryError
	}
	defer rows.Close()

	results = make([]explorerPositionResult, 0)

	for rows.Next() {
		current = explorerPositionResult{}

		queryError = rows.Scan(
			&current.BilletID,
			&current.PositionNumber,
			&current.BilletTitle,
			&current.GradeCode,
			&current.RankGroup,
			&current.BranchCode,
			&current.MOSCode,
			&current.AOCCode,
			&current.Component,
			&current.UIC,
			&current.ParagraphNumber,
			&current.LineNumber,
			&current.DutyLocation,
			&current.StateCode,
			&rawStatus,
			&current.OrganizationID,
			&current.OrganizationName,
			&current.OrganizationShortName,
			&current.SectionID,
			&current.SectionDisplayName,
			&current.OccupantPersonID,
			&current.OccupantDisplayName,
			&current.OccupantRank,
		)
		if queryError != nil {
			return nil, queryError
		}

		current.Status = normalizeBilletStatus(rawStatus)

		if current.OccupantPersonID != 0 {
			current.Status = "Filled"
		}

		results = append(results, current)
	}

	queryError = rows.Err()
	if queryError != nil {
		return nil, queryError
	}

	return results, nil
}