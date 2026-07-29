#!/usr/bin/env bash
set -euo pipefail

script_directory_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root_path="${script_directory_path}"

echo "==> Running goimports on all Go files"
find "${repository_root_path}" \
  -type f \
  -name '*.go' \
  -not -path '*/vendor/*' \
  -not -path '*/node_modules/*' \
  -print0 | xargs -0 goimports -w

echo
echo "==> Discovering Go modules"
find "${repository_root_path}" \
  -type f \
  -name 'go.mod' \
  -not -path '*/vendor/*' \
  -not -path '*/node_modules/*' \
  | sort | while IFS= read -r go_module_file_path; do

    go_module_directory_path="$(dirname "${go_module_file_path}")"

    echo
    echo "==> go vet in ${go_module_directory_path}"
    (
        cd "${go_module_directory_path}"
        go vet ./...
    )

    echo "==> staticcheck in ${go_module_directory_path}"
    (
        cd "${go_module_directory_path}"
        staticcheck ./...
    )
done

echo
echo "Done."
