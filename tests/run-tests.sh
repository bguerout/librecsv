#!/usr/bin/env bash
set -xeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OUTPUT_DIR="${SCRIPT_DIR}/../output"

cd "${SCRIPT_DIR}/.."
bash "convert-to-csv.sh" --output_dir "${OUTPUT_DIR}/openoffice" tests/files/openoffice.ods
bash "convert-to-csv.sh" --output_dir "${OUTPUT_DIR}/excel" tests/files/excel.xlsx
bash "convert-to-csv.sh" --output_dir "${OUTPUT_DIR}/field-separator" --field-separator ";" tests/files/openoffice.ods
bash "convert-to-csv.sh" --output_dir "${OUTPUT_DIR}/sheets" --sheet 2 tests/files/sheets.ods
bash "convert-to-csv.sh" --output_dir "${OUTPUT_DIR}/text-delimiter" --text-delimiter _ --quoted-field-as-text tests/files/openoffice.ods
cd ..
