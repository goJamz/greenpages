#!/bin/ash
set -eu

audit_file_path="${1:-/tmp/govulncheck.json}"

echo "GOVULNCHECK SETUP: installing govulncheck"

GOBIN=/usr/local/bin go install golang.org/x/vuln/cmd/govulncheck@latest

echo "GOVULNCHECK SETUP: govulncheck installed"
echo "GOVULNCHECK SUMMARY: starting JSON scan"

govulncheck -json ./... > "${audit_file_path}" || true

if [ ! -s "${audit_file_path}" ]; then
  echo "GOVULNCHECK SUMMARY: unable to read govulncheck JSON output"
  exit 0
fi

finding_count="$(jq -s '[.[] | select(.finding != null) | .finding.osv] | unique | length' "${audit_file_path}")"
finding_ids="$(jq -rs '[.[] | select(.finding != null) | .finding.osv] | unique | join(",")' "${audit_file_path}")"

if [ "${finding_count}" = "0" ]; then
  echo "GOVULNCHECK SUMMARY: findings=0"
  echo "GOVULNCHECK FINDINGS: none"
  exit 0
fi

echo "GOVULNCHECK SUMMARY: findings=${finding_count} osv_ids=${finding_ids}"

jq -r '
  . as $message
  | select($message.finding != null)
  | "GOVULNCHECK FINDING: osv=\($message.finding.osv) fixed_version=\($message.finding.fixed_version // "unknown")"
' "${audit_file_path}" | sort -u

echo "GOVULNCHECK DETAILS: printing trace output"

govulncheck -show=traces ./... 2>&1 \
  | sed 's/^/GOVULNCHECK: /' \
  || true

echo "GOVULNCHECK SUMMARY: scan complete"