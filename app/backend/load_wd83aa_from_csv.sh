#!/usr/bin/env bash
set -euo pipefail

# Manual WD83AA Vantage-to-Postgres loader.
#
# Required:
#   export DATABASE_URL='postgres://USER:PASSWORD@HOST:5432/DBNAME?sslmode=require'
#
# Optional:
#   export DATA_DIR='/path/to/csvs'
#   export PEOPLE_CSV='/path/to/greenpages_people_wd83aa_prototype.csv'
#   export BILLETS_CSV='/path/to/greenpages_billets_wd83aa_prototype.csv'
#   export OCCUPANTS_CSV='/path/to/greenpages_billet_occupants_wd83aa_prototype.csv'

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
database_connection="${DATABASE_URL:-}"
data_directory="${DATA_DIR:-$PWD}"
people_csv="${PEOPLE_CSV:-$data_directory/greenpages_people_wd83aa_prototype.csv}"
billets_csv="${BILLETS_CSV:-$data_directory/greenpages_billets_wd83aa_prototype.csv}"
occupants_csv="${OCCUPANTS_CSV:-$data_directory/greenpages_billet_occupants_wd83aa_prototype.csv}"

if [[ -z "$database_connection" ]]; then
  echo "ERROR: DATABASE_URL is required."
  exit 1
fi

for required_file in "$people_csv" "$billets_csv" "$occupants_csv"; do
  if [[ ! -f "$required_file" ]]; then
    echo "ERROR: required CSV file not found: $required_file"
    exit 1
  fi
done

echo "Creating WD83AA staging tables..."
psql "$database_connection" \
  -v ON_ERROR_STOP=1 \
  -f "$script_directory/load_wd83aa_staging.sql"

echo "Copying CSV files into staging..."
psql "$database_connection" \
  -v ON_ERROR_STOP=1 \
  -c "\copy staging.greenpages_people_wd83aa FROM '${people_csv}' WITH (FORMAT csv, HEADER true)"

psql "$database_connection" \
  -v ON_ERROR_STOP=1 \
  -c "\copy staging.greenpages_billets_wd83aa FROM '${billets_csv}' WITH (FORMAT csv, HEADER true)"

psql "$database_connection" \
  -v ON_ERROR_STOP=1 \
  -c "\copy staging.greenpages_billet_occupants_wd83aa FROM '${occupants_csv}' WITH (FORMAT csv, HEADER true)"

echo "Validating staging data and merging WD83AA into live tables..."
psql "$database_connection" \
  -v ON_ERROR_STOP=1 \
  -f "$script_directory/load_wd83aa_merge.sql"

echo "WD83AA load completed successfully."

