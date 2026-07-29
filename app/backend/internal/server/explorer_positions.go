package server

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

const explorerPositionsQuery = `
WITH explorer_base AS (
    SELECT
        b.billet_id,
        COALESCE(b.position_number, '') AS position_number,
        COALESCE(b.billet_title, '') AS billet_title,
        COALESCE(b.grade_code, '') AS grade_code,
        COALESCE(b.branch_code, '') AS branch_code,
        COALESCE(b.mos_code, '') AS mos_code,
        COALESCE(b.aoc_code, '') AS aoc_code,
        COALESCE(b.component, '') AS component,
        COALESCE(b.uic, '') AS uic,
        COALESCE(b.paragraph_number, '') AS paragraph_number,
        COALESCE(b.line_number, '') AS line_number,
        COALESCE(b.duty_location, '') AS duty_location,
        COALESCE(b.state_code, '') AS state_code,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM billet_occupants bo_any
                WHERE bo_any.billet_id = b.billet_id
                  AND bo_any.assignment_status = 'active'
            ) THEN 'filled'
            ELSE COALESCE(b.occupancy_status, 'unknown')
        END AS billet_status,
        o.organization_id,
        COALESCE(o.organization_name, '') AS organization_name,
        COALESCE(o.short_name, '') AS organization_short_name,
        s.section_id,
        COALESCE(s.display_name, '') AS section_display_name,
        COALESCE(p.person_id, 0) AS primary_person_id,
        COALESCE(p.display_name, '') AS primary_person_display_name,
        COALESCE(p.rank, '') AS primary_person_rank
    FROM billets b
    INNER JOIN organizations o
        ON o.organization_id = b.organization_id
       AND o.is_current = TRUE
    INNER JOIN sections s
        ON s.section_id = b.section_id
       AND s.is_current = TRUE
    LEFT JOIN billet_occupants bo_primary
        ON bo_primary.billet_id = b.billet_id
       AND bo_primary.assignment_status = 'active'
       AND bo_primary.is_primary = TRUE
    LEFT JOIN people p
        ON p.person_id = bo_primary.person_id
       AND p.is_current = TRUE
    WHERE b.is_current = TRUE
)
SELECT
    billet_id,
    position_number,
    billet_title,
    grade_code,
    branch_code,
    mos_code,
    aoc_code,
    component,
    uic,
    paragraph_number,
    line_number,
    duty_location,
    state_code,
    billet_status,
    organization_id,
    organization_name,
    organization_short_name,
    section_id,
    section_display_name,
    primary_person_id,
    primary_person_display_name,
    primary_person_rank
FROM explorer_base
WHERE
    ($1 = '' OR LOWER(component) = LOWER($1))
    AND ($2 = '' OR LOWER(grade_code) = LOWER($2))
    AND ($3 = '' OR LOWER(branch_code) = LOWER($3))
    AND ($4 = '' OR LOWER(mos_code) = LOWER($4))
    AND ($5 = '' OR LOWER(aoc_code) = LOWER($5))
    AND ($6 = '' OR LOWER(state_code) = LOWER($6))
    AND ($7 = '' OR LOWER(billet_status) = LOWER($7))
    AND (
        $8 = ''
        OR regexp_replace(LOWER(organization_name), '[^a-z0-9]+', '', 'g') LIKE '%' || $8 || '%'
        OR regexp_replace(LOWER(organization_short_name), '[^a-z0-9]+', '', 'g') LIKE '%' || $8 || '%'
    )
ORDER BY
    component ASC,
    organization_name ASC,
    section_display_name ASC,
    grade_code ASC,
    billet_title ASC
LIMIT $9 OFFSET $10;
`

// explorerFacetQueryTemplate returns distinct values for a single column.
// The target column name is injected via fmt.Sprintf only after being whitelisted
// by buildExplorerFacetQuery.
// Uses a lighter CTE than explorerPositionsQuery — no person or occupant joins
// since facet computation only needs billet, organization, and section data.
// The %% in the LIKE pattern produces a literal % after Sprintf formatting.
const explorerFacetQueryTemplate = `
WITH facet_base AS (
    SELECT
        COALESCE(b.grade_code, '') AS grade_code,
        COALESCE(b.branch_code, '') AS branch_code,
        COALESCE(b.mos_code, '') AS mos_code,
        COALESCE(b.aoc_code, '') AS aoc_code,
        COALESCE(b.component, '') AS component,
        COALESCE(b.state_code, '') AS state_code,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM billet_occupants bo_any
                WHERE bo_any.billet_id = b.billet_id
                  AND bo_any.assignment_status = 'active'
            ) THEN 'filled'
            ELSE COALESCE(b.occupancy_status, 'unknown')
        END AS billet_status,
        COALESCE(o.organization_name, '') AS organization_name,
        COALESCE(o.short_name, '') AS organization_short_name
    FROM billets b
    INNER JOIN organizations o
        ON o.organization_id = b.organization_id
       AND o.is_current = TRUE
    INNER JOIN sections s
        ON s.section_id = b.section_id
       AND s.is_current = TRUE
    WHERE b.is_current = TRUE
)
SELECT DISTINCT %s
FROM facet_base
WHERE
    ($1 = '' OR LOWER(component) = LOWER($1))
    AND ($2 = '' OR LOWER(grade_code) = LOWER($2))
    AND ($3 = '' OR LOWER(branch_code) = LOWER($3))
    AND ($4 = '' OR LOWER(mos_code) = LOWER($4))
    AND ($5 = '' OR LOWER(aoc_code) = LOWER($5))
    AND ($6 = '' OR LOWER(state_code) = LOWER($6))
    AND ($7 = '' OR LOWER(billet_status) = LOWER($7))
    AND (
        $8 = ''
        OR regexp_replace(LOWER(organization_name), '[^a-z0-9]+', '', 'g') LIKE '%%' || $8 || '%%'
        OR regexp_replace(LOWER(organization_short_name), '[^a-z0-9]+', '', 'g') LIKE '%%' || $8 || '%%'
    )
    AND %s != ''
ORDER BY %s ASC;
`

// explorerPositionFilters captures the supported explorer filter inputs.
type explorerPositionFilters struct {
	Component    string `json:"component"`    // Army component like Active, Guard, or Reserve.
	Grade        string `json:"grade"`        // Billet grade like CPT, MAJ, or SFC.
	Branch       string `json:"branch"`       // Branch code like SC.
	MOS          string `json:"mos"`          // MOS code like 25B.
	AOC          string `json:"aoc"`          // AOC code like 25A.
	State        string `json:"state"`        // State code like NC or TX.
	Status       string `json:"status"`       // Billet status like filled, vacant, or unknown.
	Organization string `json:"organization"` // Organization name or short-name filter.
}

// explorerPositionResult represents one billet row returned by the explorer.
type explorerPositionResult struct {
	BilletID                 int64  `json:"billet_id"`                   // Primary key of the billet.
	PositionNumber           string `json:"position_number"`             // Position number inside the section.
	BilletTitle              string `json:"billet_title"`                // Billet title shown to users.
	GradeCode                string `json:"grade_code"`                  // Grade code like COL, MAJ, or SFC.
	BranchCode               string `json:"branch_code"`                 // Branch code like SC.
	MOSCode                  string `json:"mos_code"`                    // MOS code when present.
	AOCCode                  string `json:"aoc_code"`                    // AOC code when present.
	Component                string `json:"component"`                   // Army component like Active, Guard, or Reserve.
	UIC                      string `json:"uic"`                         // Unit Identification Code.
	ParagraphNumber          string `json:"paragraph_number"`            // Paragraph number when present.
	LineNumber               string `json:"line_number"`                 // Line number when present.
	DutyLocation             string `json:"duty_location"`               // Duty location when present.
	StateCode                string `json:"state_code"`                  // State code when present.
	Status                   string `json:"status"`                      // Filled, Vacant, or Unknown.
	OrganizationID           int64  `json:"organization_id"`             // Organization ID for future drill-in links.
	OrganizationName         string `json:"organization_name"`           // Canonical organization name.
	OrganizationShortName    string `json:"organization_short_name"`     // Organization short name.
	SectionID                int64  `json:"section_id"`                  // Section ID for drill-in links.
	SectionDisplayName       string `json:"section_display_name"`        // Section display name like XVIII Airborne Corps G-6.
	PrimaryPersonID          int64  `json:"primary_person_id"`           // Primary occupant person ID, 0 when none.
	PrimaryPersonDisplayName string `json:"primary_person_display_name"` // Primary occupant display name when present.
	PrimaryPersonRank        string `json:"primary_person_rank"`         // Primary occupant rank when present.
}

// explorerAvailableOptions contains the distinct values available for each
// filter dimension given the current set of other active filters.
// Each slice is computed with its own filter excluded so the user can always
// change their mind without getting trapped inside one selected value.
type explorerAvailableOptions struct {
	Components []string `json:"components"` // Available component values like Active, Guard, Reserve.
	Grades     []string `json:"grades"`     // Available grade codes like CPT, MAJ, SFC.
	Branches   []string `json:"branches"`   // Available branch codes like SC, IN.
	MOSCodes   []string `json:"mos_codes"`  // Available MOS codes like 25B, 11B.
	AOCCodes   []string `json:"aoc_codes"`  // Available AOC codes like 25A, 17A.
	States     []string `json:"states"`     // Available state codes like NC, TX, AE.
	Statuses   []string `json:"statuses"`   // Available billet statuses like filled, vacant, unknown.
}

// explorerPositionsResponse is the payload for GET /api/explorer/positions.
type explorerPositionsResponse struct {
	Filters          explorerPositionFilters  `json:"filters"`           // Applied explorer filters.
	Count            int                      `json:"count"`             // Number of rows returned in this page.
	Limit            int                      `json:"limit"`             // Applied page size.
	Offset           int                      `json:"offset"`            // Applied page offset.
	AvailableOptions explorerAvailableOptions `json:"available_options"` // Distinct values available for each filter dimension.
	Results          []explorerPositionResult `json:"results"`           // Matching billet rows.
}

// handleExplorerPositions handles GET /api/explorer/positions.
func (applicationServer *Server) handleExplorerPositions(responseWriter http.ResponseWriter, request *http.Request) {
	var rawComponent string                       // Raw component filter from the URL.
	var rawGrade string                           // Raw grade filter from the URL.
	var rawBranch string                          // Raw branch filter from the URL.
	var rawMOS string                             // Raw MOS filter from the URL.
	var rawAOC string                             // Raw AOC filter from the URL.
	var rawState string                           // Raw state filter from the URL.
	var rawStatus string                          // Raw status filter from the URL.
	var rawOrganization string                    // Raw organization filter from the URL.
	var rawLimit string                           // Raw limit value from the URL.
	var rawOffset string                          // Raw offset value from the URL.
	var parsedLimit int                           // Parsed limit value before clamping.
	var parsedOffset int                          // Parsed offset value.
	var limit int                                 // Final limit used by the query.
	var offset int                                // Final offset used by the query.
	var parseError error                          // Error returned while parsing numeric filters.
	var cleanedFilters explorerPositionFilters    // Cleaned filters used by the query and echoed to the client.
	var normalizedOrganization string             // Normalized organization filter for fuzzy matching.
	var results []explorerPositionResult          // Explorer rows returned by the database.
	var availableOptions explorerAvailableOptions // Available filter values for dynamic dropdown population.
	var queryError error                          // Error returned while loading explorer results.
	var responsePayload explorerPositionsResponse // JSON response payload.

	responseWriter.Header().Set("Content-Type", "application/json")

	rawComponent = request.URL.Query().Get("component")
	rawGrade = request.URL.Query().Get("grade")
	rawBranch = request.URL.Query().Get("branch")
	rawMOS = request.URL.Query().Get("mos")
	rawAOC = request.URL.Query().Get("aoc")
	rawState = request.URL.Query().Get("state")
	rawStatus = request.URL.Query().Get("status")
	rawOrganization = request.URL.Query().Get("organization")
	rawLimit = request.URL.Query().Get("limit")
	rawOffset = request.URL.Query().Get("offset")

	cleanedFilters = explorerPositionFilters{
		Component:    strings.TrimSpace(rawComponent),
		Grade:        strings.TrimSpace(rawGrade),
		Branch:       strings.TrimSpace(rawBranch),
		MOS:          strings.TrimSpace(rawMOS),
		AOC:          strings.TrimSpace(rawAOC),
		State:        strings.TrimSpace(rawState),
		Status:       strings.ToLower(strings.TrimSpace(rawStatus)),
		Organization: strings.TrimSpace(rawOrganization),
	}

	if cleanedFilters.Status != "" && !isValidBilletStatusValue(cleanedFilters.Status) {
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "status must be one of: filled, vacant, unknown",
		})
		return
	}

	limit = 50
	if rawLimit != "" {
		parsedLimit, parseError = strconv.Atoi(strings.TrimSpace(rawLimit))
		if parseError != nil || parsedLimit < 1 {
			responseWriter.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "limit must be a positive integer",
			})
			return
		}

		if parsedLimit > 200 {
			parsedLimit = 200
		}

		limit = parsedLimit
	}

	offset = 0
	if rawOffset != "" {
		parsedOffset, parseError = strconv.Atoi(strings.TrimSpace(rawOffset))
		if parseError != nil || parsedOffset < 0 {
			responseWriter.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "offset must be a non-negative integer",
			})
			return
		}

		offset = parsedOffset
	}

	normalizedOrganization = normalizeSearchInput(cleanedFilters.Organization)

	results, queryError = applicationServer.searchExplorerPositions(
		request.Context(),
		cleanedFilters,
		normalizedOrganization,
		limit,
		offset,
	)
	if queryError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to load explorer positions",
		})
		return
	}

	availableOptions, queryError = applicationServer.getExplorerAvailableOptions(
		request.Context(),
		cleanedFilters,
		normalizedOrganization,
	)
	if queryError != nil {
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to load available filter options",
		})
		return
	}

	responsePayload = explorerPositionsResponse{
		Filters:          cleanedFilters,
		Count:            len(results),
		Limit:            limit,
		Offset:           offset,
		AvailableOptions: availableOptions,
		Results:          results,
	}

	responseWriter.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(responseWriter).Encode(responsePayload)
}

// searchExplorerPositions loads billet rows for the position explorer.
func (applicationServer *Server) searchExplorerPositions(
	requestContext context.Context,
	filters explorerPositionFilters,
	normalizedOrganization string,
	limit int,
	offset int,
) ([]explorerPositionResult, error) {
	var explorerRows *sql.Rows                    // Result set returned by the explorer query.
	var explorerResults []explorerPositionResult  // Collected explorer rows.
	var currentExplorerRow explorerPositionResult // Current row being scanned.
	var queryError error                          // Error returned by the query or row scan.

	explorerRows, queryError = applicationServer.db.QueryContext(
		requestContext,
		explorerPositionsQuery,
		filters.Component,
		filters.Grade,
		filters.Branch,
		filters.MOS,
		filters.AOC,
		filters.State,
		filters.Status,
		normalizedOrganization,
		limit,
		offset,
	)
	if queryError != nil {
		return nil, queryError
	}
	defer explorerRows.Close()

	explorerResults = make([]explorerPositionResult, 0)

	for explorerRows.Next() {
		currentExplorerRow = explorerPositionResult{}

		queryError = explorerRows.Scan(
			&currentExplorerRow.BilletID,
			&currentExplorerRow.PositionNumber,
			&currentExplorerRow.BilletTitle,
			&currentExplorerRow.GradeCode,
			&currentExplorerRow.BranchCode,
			&currentExplorerRow.MOSCode,
			&currentExplorerRow.AOCCode,
			&currentExplorerRow.Component,
			&currentExplorerRow.UIC,
			&currentExplorerRow.ParagraphNumber,
			&currentExplorerRow.LineNumber,
			&currentExplorerRow.DutyLocation,
			&currentExplorerRow.StateCode,
			&currentExplorerRow.Status,
			&currentExplorerRow.OrganizationID,
			&currentExplorerRow.OrganizationName,
			&currentExplorerRow.OrganizationShortName,
			&currentExplorerRow.SectionID,
			&currentExplorerRow.SectionDisplayName,
			&currentExplorerRow.PrimaryPersonID,
			&currentExplorerRow.PrimaryPersonDisplayName,
			&currentExplorerRow.PrimaryPersonRank,
		)
		if queryError != nil {
			return nil, queryError
		}

		currentExplorerRow.Status = normalizeBilletStatus(currentExplorerRow.Status)

		explorerResults = append(explorerResults, currentExplorerRow)
	}

	queryError = explorerRows.Err()
	if queryError != nil {
		return nil, queryError
	}

	return explorerResults, nil
}

// getExplorerAvailableOptions computes the distinct values available for each
// filter dimension. Each dimension is computed with its own filter excluded
// so the user can always change their selection without getting trapped.
func (applicationServer *Server) getExplorerAvailableOptions(
	requestContext context.Context,
	filters explorerPositionFilters,
	normalizedOrganization string,
) (explorerAvailableOptions, error) {
	var componentFilters explorerPositionFilters // Filters with component excluded for the component facet.
	var gradeFilters explorerPositionFilters     // Filters with grade excluded for the grade facet.
	var branchFilters explorerPositionFilters    // Filters with branch excluded for the branch facet.
	var mosFilters explorerPositionFilters       // Filters with MOS excluded for the MOS facet.
	var aocFilters explorerPositionFilters       // Filters with AOC excluded for the AOC facet.
	var stateFilters explorerPositionFilters     // Filters with state excluded for the state facet.
	var statusFilters explorerPositionFilters    // Filters with status excluded for the status facet.
	var components []string                      // Distinct component values.
	var grades []string                          // Distinct grade code values.
	var branches []string                        // Distinct branch code values.
	var mosCodes []string                        // Distinct MOS code values.
	var aocCodes []string                        // Distinct AOC code values.
	var states []string                          // Distinct state code values.
	var statuses []string                        // Distinct billet status values.
	var facetError error                         // Error returned by any facet query.

	componentFilters = filters
	componentFilters.Component = ""
	components, facetError = applicationServer.getExplorerFacetValues(requestContext, "component", componentFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	gradeFilters = filters
	gradeFilters.Grade = ""
	grades, facetError = applicationServer.getExplorerFacetValues(requestContext, "grade_code", gradeFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	branchFilters = filters
	branchFilters.Branch = ""
	branches, facetError = applicationServer.getExplorerFacetValues(requestContext, "branch_code", branchFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	mosFilters = filters
	mosFilters.MOS = ""
	mosCodes, facetError = applicationServer.getExplorerFacetValues(requestContext, "mos_code", mosFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	aocFilters = filters
	aocFilters.AOC = ""
	aocCodes, facetError = applicationServer.getExplorerFacetValues(requestContext, "aoc_code", aocFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	stateFilters = filters
	stateFilters.State = ""
	states, facetError = applicationServer.getExplorerFacetValues(requestContext, "state_code", stateFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	statusFilters = filters
	statusFilters.Status = ""
	statuses, facetError = applicationServer.getExplorerFacetValues(requestContext, "billet_status", statusFilters, normalizedOrganization)
	if facetError != nil {
		return explorerAvailableOptions{}, facetError
	}

	return explorerAvailableOptions{
		Components: components,
		Grades:     grades,
		Branches:   branches,
		MOSCodes:   mosCodes,
		AOCCodes:   aocCodes,
		States:     states,
		Statuses:   statuses,
	}, nil
}

// getExplorerFacetValues returns the distinct non-empty values for a single
// whitelisted column in the explorer dataset, filtered by all active filters.
func (applicationServer *Server) getExplorerFacetValues(
	requestContext context.Context,
	targetColumn string,
	filters explorerPositionFilters,
	normalizedOrganization string,
) ([]string, error) {
	var facetQuery string    // Formatted SQL query for this specific column.
	var facetRows *sql.Rows  // Result set returned by the facet query.
	var facetValues []string // Collected distinct values.
	var currentValue string  // Current value being scanned from the result set.
	var queryError error     // Error returned by the query or row scan.

	facetQuery, queryError = buildExplorerFacetQuery(targetColumn)
	if queryError != nil {
		return nil, queryError
	}

	facetRows, queryError = applicationServer.db.QueryContext(
		requestContext,
		facetQuery,
		filters.Component,
		filters.Grade,
		filters.Branch,
		filters.MOS,
		filters.AOC,
		filters.State,
		filters.Status,
		normalizedOrganization,
	)
	if queryError != nil {
		return nil, queryError
	}
	defer facetRows.Close()

	facetValues = make([]string, 0)

	for facetRows.Next() {
		currentValue = ""

		queryError = facetRows.Scan(&currentValue)
		if queryError != nil {
			return nil, queryError
		}

		facetValues = append(facetValues, currentValue)
	}

	queryError = facetRows.Err()
	if queryError != nil {
		return nil, queryError
	}

	return facetValues, nil
}

// buildExplorerFacetQuery returns a facet query for one known facet column.
func buildExplorerFacetQuery(targetColumn string) (string, error) {
	switch targetColumn {
	case "component", "grade_code", "branch_code", "mos_code", "aoc_code", "state_code", "billet_status":
		return fmt.Sprintf(explorerFacetQueryTemplate, targetColumn, targetColumn, targetColumn), nil
	default:
		return "", fmt.Errorf("unsupported explorer facet column: %s", targetColumn)
	}
}
