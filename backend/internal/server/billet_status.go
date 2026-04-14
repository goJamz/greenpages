// backend/internal/server/billet_status.go
package server

import (
	"strings"
)

// API-facing billet status values. These are the title-case strings returned
// by the API regardless of how status is stored in the database.
const BilletStatusFilled = "Filled"
const BilletStatusVacant = "Vacant"
const BilletStatusUnknown = "Unknown"

// normalizeBilletStatus converts stored database values into API display values.
// Any unrecognized value is treated as Unknown.
func normalizeBilletStatus(rawStatus string) string {
	var loweredStatus string // Lowercased billet status from the database.

	loweredStatus = strings.ToLower(strings.TrimSpace(rawStatus))

	switch loweredStatus {
	case "filled":
		return BilletStatusFilled
	case "vacant":
		return BilletStatusVacant
	case "unknown":
		return BilletStatusUnknown
	default:
		return BilletStatusUnknown
	}
}

// isValidExplorerStatus returns true when the explorer status filter is a supported value.
// Filter values are lowercase to match the database storage format.
func isValidExplorerStatus(statusValue string) bool {
	return statusValue == "filled" || statusValue == "vacant" || statusValue == "unknown"
}