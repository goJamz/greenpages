package server

import (
	"database/sql"
	"encoding/csv"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// explorerExportMaxRows caps the first CSV export implementation so one request cannot stream an unbounded result set.
const explorerExportMaxRows = 10000

// handleExportExplorerPositionsCSV handles GET /api/exports/positions.
func (applicationServer *Server) handleExportExplorerPositionsCSV(responseWriter http.ResponseWriter, request *http.Request) {
	var cleanedFilters explorerPositionFilters // Cleaned filters used by the export query.
	var normalizedOrganization string          // Normalized organization filter for fuzzy matching.
	var exportedRows []explorerPositionResult  // Explorer rows included in the CSV export.
	var exportError error                      // Error returned while loading or writing the export.
	var fileName string                        // Suggested download filename for the CSV export.
	var csvWriter *csv.Writer                  // Standard library CSV writer bound to the response.
	var headerRow []string                     // CSV header row.
	var currentRow []string                    // Current CSV data row.
	var index int                              // Loop index for the exported rows.
	var positionResult explorerPositionResult  // Current explorer result being written.

	cleanedFilters = explorerPositionFilters{
		Component:    strings.TrimSpace(request.URL.Query().Get("component")),
		Grade:        strings.TrimSpace(request.URL.Query().Get("grade")),
		Branch:       strings.TrimSpace(request.URL.Query().Get("branch")),
		MOS:          strings.TrimSpace(request.URL.Query().Get("mos")),
		AOC:          strings.TrimSpace(request.URL.Query().Get("aoc")),
		State:        strings.TrimSpace(request.URL.Query().Get("state")),
		Status:       strings.ToLower(strings.TrimSpace(request.URL.Query().Get("status"))),
		Organization: strings.TrimSpace(request.URL.Query().Get("organization")),
	}

	if cleanedFilters.Status != "" && !isValidExplorerStatus(cleanedFilters.Status) {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "status must be one of: filled, vacant, unknown",
		})
		return
	}

	normalizedOrganization = normalizeSearchInput(cleanedFilters.Organization)

	exportedRows, exportError = applicationServer.searchExplorerPositions(
		request.Context(),
		cleanedFilters,
		normalizedOrganization,
		explorerExportMaxRows,
		0,
	)
	if exportError != nil {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to export explorer positions",
		})
		return
	}

	fileName = fmt.Sprintf("greenpages_explorer_positions_%s.csv", time.Now().UTC().Format("20060102_150405"))

	responseWriter.Header().Set("Content-Type", "text/csv; charset=utf-8")
	responseWriter.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%q", fileName))
	responseWriter.WriteHeader(http.StatusOK)

	csvWriter = csv.NewWriter(responseWriter)
	defer csvWriter.Flush()

	headerRow = []string{
		"billet_id",
		"position_number",
		"billet_title",
		"grade_code",
		"branch_code",
		"mos_code",
		"aoc_code",
		"component",
		"uic",
		"paragraph_number",
		"line_number",
		"duty_location",
		"state_code",
		"status",
		"organization_id",
		"organization_name",
		"organization_short_name",
		"section_id",
		"section_display_name",
		"primary_person_id",
		"primary_person_rank",
		"primary_person_display_name",
	}

	exportError = csvWriter.Write(headerRow)
	if exportError != nil {
		return
	}

	for index = 0; index < len(exportedRows); index++ {
		positionResult = exportedRows[index]

		currentRow = []string{
			strconv.FormatInt(positionResult.BilletID, 10),
			positionResult.PositionNumber,
			positionResult.BilletTitle,
			positionResult.GradeCode,
			positionResult.BranchCode,
			positionResult.MOSCode,
			positionResult.AOCCode,
			positionResult.Component,
			positionResult.UIC,
			positionResult.ParagraphNumber,
			positionResult.LineNumber,
			positionResult.DutyLocation,
			positionResult.StateCode,
			positionResult.Status,
			strconv.FormatInt(positionResult.OrganizationID, 10),
			positionResult.OrganizationName,
			positionResult.OrganizationShortName,
			strconv.FormatInt(positionResult.SectionID, 10),
			positionResult.SectionDisplayName,
			strconv.FormatInt(positionResult.PrimaryPersonID, 10),
			positionResult.PrimaryPersonRank,
			positionResult.PrimaryPersonDisplayName,
		}

		exportError = csvWriter.Write(currentRow)
		if exportError != nil {
			return
		}
	}
}

// handleExportSectionCSV handles GET /api/exports/section/{sectionID}.
func (applicationServer *Server) handleExportSectionCSV(responseWriter http.ResponseWriter, request *http.Request) {
	var rawSectionID string           // Raw section ID path value from the request URL.
	var parsedSectionID int64         // Parsed numeric section ID used for the export lookup.
	var parseError error              // Error returned while parsing the section ID.
	var foundSection sectionDetail    // Section metadata returned from the database.
	var foundBillets []billetResult   // Billets returned for the section export.
	var exportError error             // Error returned while loading or writing the export.
	var fileName string               // Suggested download filename for the CSV export.
	var csvWriter *csv.Writer         // Standard library CSV writer bound to the response.
	var headerRow []string            // CSV header row.
	var billetIndex int               // Loop index for billets.
	var occupantIndex int             // Loop index for occupants.
	var billetRecord billetResult     // Current billet record being written.
	var occupantRecord billetOccupant // Current occupant record being written.
	var currentRow []string           // Current CSV data row.

	rawSectionID = request.PathValue("sectionID")
	if rawSectionID == "" {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "sectionID path parameter is required",
		})
		return
	}

	parsedSectionID, parseError = strconv.ParseInt(rawSectionID, 10, 64)
	if parseError != nil {
		responseWriter.Header().Set("Content-Type", "application/json")
		responseWriter.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "sectionID must be a valid integer",
		})
		return
	}

	foundSection, foundBillets, exportError = applicationServer.getSectionDetail(
		request.Context(),
		parsedSectionID,
	)
	if exportError != nil {
		responseWriter.Header().Set("Content-Type", "application/json")

		if errors.Is(exportError, sql.ErrNoRows) {
			responseWriter.WriteHeader(http.StatusNotFound)
			_ = json.NewEncoder(responseWriter).Encode(map[string]string{
				"error": "section not found",
			})
			return
		}

		responseWriter.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(responseWriter).Encode(map[string]string{
			"error": "failed to export section roster",
		})
		return
	}

	fileName = fmt.Sprintf(
		"greenpages_section_%d_%s.csv",
		foundSection.SectionID,
		time.Now().UTC().Format("20060102_150405"),
	)

	responseWriter.Header().Set("Content-Type", "text/csv; charset=utf-8")
	responseWriter.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%q", fileName))
	responseWriter.WriteHeader(http.StatusOK)

	csvWriter = csv.NewWriter(responseWriter)
	defer csvWriter.Flush()

	headerRow = []string{
		"section_id",
		"section_display_name",
		"section_code",
		"organization_id",
		"organization_name",
		"organization_short_name",
		"billet_id",
		"position_number",
		"billet_title",
		"grade_code",
		"rank_group",
		"branch_code",
		"mos_code",
		"aoc_code",
		"component",
		"uic",
		"paragraph_number",
		"line_number",
		"duty_location",
		"state_code",
		"status",
		"occupant_person_id",
		"occupant_rank",
		"occupant_display_name",
		"occupant_work_email",
		"occupant_work_phone",
		"occupant_office_symbol",
		"occupant_is_primary",
	}

	exportError = csvWriter.Write(headerRow)
	if exportError != nil {
		return
	}

	for billetIndex = 0; billetIndex < len(foundBillets); billetIndex++ {
		billetRecord = foundBillets[billetIndex]

		if len(billetRecord.Occupants) == 0 {
			currentRow = []string{
				strconv.FormatInt(foundSection.SectionID, 10),
				foundSection.DisplayName,
				foundSection.SectionCode,
				strconv.FormatInt(foundSection.OrganizationID, 10),
				foundSection.OrganizationName,
				foundSection.OrganizationShortName,
				strconv.FormatInt(billetRecord.BilletID, 10),
				billetRecord.PositionNumber,
				billetRecord.BilletTitle,
				billetRecord.GradeCode,
				billetRecord.RankGroup,
				billetRecord.BranchCode,
				billetRecord.MOSCode,
				billetRecord.AOCCode,
				billetRecord.Component,
				billetRecord.UIC,
				billetRecord.ParagraphNumber,
				billetRecord.LineNumber,
				billetRecord.DutyLocation,
				billetRecord.StateCode,
				billetRecord.Status,
				"",
				"",
				"",
				"",
				"",
				"",
				"",
			}

			exportError = csvWriter.Write(currentRow)
			if exportError != nil {
				return
			}

			continue
		}

		for occupantIndex = 0; occupantIndex < len(billetRecord.Occupants); occupantIndex++ {
			occupantRecord = billetRecord.Occupants[occupantIndex]

			currentRow = []string{
				strconv.FormatInt(foundSection.SectionID, 10),
				foundSection.DisplayName,
				foundSection.SectionCode,
				strconv.FormatInt(foundSection.OrganizationID, 10),
				foundSection.OrganizationName,
				foundSection.OrganizationShortName,
				strconv.FormatInt(billetRecord.BilletID, 10),
				billetRecord.PositionNumber,
				billetRecord.BilletTitle,
				billetRecord.GradeCode,
				billetRecord.RankGroup,
				billetRecord.BranchCode,
				billetRecord.MOSCode,
				billetRecord.AOCCode,
				billetRecord.Component,
				billetRecord.UIC,
				billetRecord.ParagraphNumber,
				billetRecord.LineNumber,
				billetRecord.DutyLocation,
				billetRecord.StateCode,
				billetRecord.Status,
				strconv.FormatInt(occupantRecord.PersonID, 10),
				occupantRecord.Rank,
				occupantRecord.DisplayName,
				occupantRecord.WorkEmail,
				occupantRecord.WorkPhone,
				occupantRecord.OfficeSymbol,
				strconv.FormatBool(occupantRecord.IsPrimary),
			}

			exportError = csvWriter.Write(currentRow)
			if exportError != nil {
				return
			}
		}
	}
}
