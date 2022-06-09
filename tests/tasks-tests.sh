readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
readonly OUTPUT_DIR="${PROJECT_DIR}/output/test"
readonly TEST_DIR="${PROJECT_DIR}/tests"
source "${TEST_DIR}/assert.sh"

function run_test_suite {
  log_task "Running tasks test suite..."
  before_all
  should_convert_ods_into_csv
  should_convert_xls_into_csv
  should_configure_field_separator
  should_configure_text_delimiter
  should_select_sheet
  after_all
}

function before_all {
  log_header "Starting testing suite"
  rm -r "${OUTPUT_DIR}" || true
}

function after_all {
  echo ""
}

function before_each {
  log_header "${FUNCNAME[1]}"
}

function after_each {
  log_success "${FUNCNAME[1]} passed"
}

function assert_first_line {
  assert_eq "$(head -1 "${1}")" "${2}" "Content mismatched"
}

function assert_second_line {
  assert_eq "$(tail -n "+2" "${1}")" "${2}" "Content mismatched"
}

function convert(){
  bash "${PROJECT_DIR}/convert-to-csv.sh" --output_dir "${OUTPUT_DIR}" "$@"
}

function should_convert_ods_into_csv {
  before_each
  local output_file="${OUTPUT_DIR}/openoffice.csv"

  convert "${TEST_DIR}/files/openoffice.ods"

  assert_first_line "${output_file}" "col1,col2"
  assert_second_line "${output_file}" "Line 1,Data 1"
  after_each
}

function should_convert_xls_into_csv {
  before_each
  local output_file="${OUTPUT_DIR}/excel.csv"

  convert "${TEST_DIR}/files/excel.xlsx"

  assert_first_line "${output_file}" "col1,col2"
  assert_second_line "${output_file}" "Line 1,Data 1"
  after_each
}

function should_configure_field_separator {
  before_each

  convert --field-separator ";" "${TEST_DIR}/files/openoffice.ods"

  assert_second_line "${OUTPUT_DIR}/openoffice.csv" "Line 1;Data 1"
  after_each
}

function should_configure_text_delimiter {
  before_each

  convert  --text-delimiter _ --quoted-field-as-text "${TEST_DIR}/files/openoffice.ods"

  assert_second_line "${OUTPUT_DIR}/openoffice.csv" "_Line 1_,_Data 1_"
  after_each
}

function should_select_sheet {
  before_each

  convert --sheet 2 "${TEST_DIR}/files/sheets.ods"

  assert_second_line "${OUTPUT_DIR}/sheets-data.csv" "Line 1,Data 1"
  after_each
}

run_test_suite
