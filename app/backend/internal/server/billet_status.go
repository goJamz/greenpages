// backend/internal/server/billet_status.go
package server

import "strings"

const (
	billetStatusFilledValue    = "filled"  // Canonical stored/filter value for a filled billet.
	billetStatusVacantValue    = "vacant"  // Canonical stored/filter value for a vacant billet.
	billetStatusUnknownValue   = "unknown" // Canonical stored/filter value for an unknown billet.
	billetStatusFilledDisplay  = "Filled"  // API display value for a filled billet.
	billetStatusVacantDisplay  = "Vacant"  // API display value for a vacant billet.
	billetStatusUnknownDisplay = "Unknown" // API display value for an unknown billet.
)

// normalizeBilletStatus converts stored database values into API display values.
// Any unrecognized value is treated as Unknown.
func normalizeBilletStatus(rawStatus string) string {
	var loweredStatus = strings.ToLower(strings.TrimSpace(rawStatus)) // Lowercased billet status from the database.

	switch loweredStatus {
	case billetStatusFilledValue:
		return billetStatusFilledDisplay
	case billetStatusVacantValue:
		return billetStatusVacantDisplay
	case billetStatusUnknownValue:
		return billetStatusUnknownDisplay
	default:
		return billetStatusUnknownDisplay
	}
}

// isValidBilletStatusValue returns true when the billet status filter is a supported value.
// Callers are expected to pass already-lowercased and trimmed input.
func isValidBilletStatusValue(statusValue string) bool {
	return statusValue == billetStatusFilledValue ||
		statusValue == billetStatusVacantValue ||
		statusValue == billetStatusUnknownValue
}