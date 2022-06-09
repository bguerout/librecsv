#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function usage {
  echo "LibreCSV"
  echo ""
  echo "Convert ODS and XLS files to CSV files"
  echo ""
  echo "Usage: "
  echo "  naval_fate.py ship new <name>..."
  echo ""
  echo "Options: "
  echo "   --field-separator <value> The field separator (default: ',')"
  echo "   --text-delimiter <value> The text delimiter (default: '\"')"
  echo "   --character-set <value> The character set used in the file"
  echo "   --cell-format <value> A sequence of column/formatting code"
  echo "   --language <value> A local name (eg. 'fr_FR')"
  echo "   --quoted-field-as-text <value> This option is the equivalent of the check box 'Quoted field as text'"
  echo "   --store-number-cells-as-numbers <value> <description>"
  echo "   --save-cell-contents-as-shown <value> <description>"
  echo "   --export-cell-formulas <value> Export cell formulas (default: false)"
  echo "   --sheet Convert the entire document to individual sheets .csv files or a specified sheet."
  echo ""
}

#from https://help.libreoffice.org/latest/km/text/shared/guide/csv_params.html?&DbPAR=SHARED&System=UNIX#hd_id591634740467955
declare -A characters_set
characters_set+=(
  ["Unknown"]="0"
  ["Windows-1252/WinLatin "]="1"
  ["Apple Macintosh (Western)"]="2"
  ["DOS/OS2-437/US"]="3"
  ["DOS/OS2-850/International"]="4"
  ["DOS/OS2-860/Portuguese"]="5"
  ["DOS/OS2-861/Icelandic"]="6"
  ["DOS/OS2-863/Canadian-French"]="7"
  ["DOS/OS2-865/Nordic"]="8"
  ["System default"]="9"
  ["Symbol"]="10"
  ["ASCII/US"]="11"
  ["ISO-8859-1"]="12"
  ["ISO-8859-2"]="13"
  ["ISO-8859-3"]="14"
  ["ISO-8859-4"]="15"
  ["ISO-8859-5"]="16"
  ["ISO-8859-6"]="17"
  ["ISO-8859-7"]="18"
  ["ISO-8859-8"]="19"
  ["ISO-8859-9"]="20"
  ["ISO-8859-14"]="21"
  ["ISO-8859-15/EURO"]="22"
  ["DOS/OS2-737"]="23"
  ["DOS/OS2-775"]="24"
  ["DOS/OS2-852"]="25"
  ["DOS/OS2-855"]="26"
  ["DOS/OS2-857"]="27"
  ["DOS/OS2-862"]="28"
  ["DOS/OS2-864"]="29"
  ["DOS/OS2-866/Russian"]="30"
  ["DOS/OS2-869/Modern"]="31"
  ["DOS/Windows-874"]="32"
  ["Windows-1250"]="33"
  ["Windows-1251"]="34"
  ["Windows-1253"]="35"
  ["Windows-1254"]="36"
  ["Windows-1255"]="37"
  ["Windows-1256"]="38"
  ["Windows-1257"]="39"
  ["Windows-1258"]="40"
  ["Apple Macintosh (Arabic)"]="41"
  ["Apple Macintosh (Central European)"]="42"
  ["Apple Macintosh/Croatian (Central European)"]="43"
  ["Apple Macintosh (Cyrillic)"]="44"
  ["Apple Macintosh (Greek)"]="47"
  ["Apple Macintosh (Hebrew)"]="50"
  ["Apple Macintosh/Icelandic"]="51"
  ["Apple Macintosh/Romanian"]="52"
  ["Apple Macintosh (Thai)"]="53"
  ["Apple Macintosh (Turkish)"]="54"
  ["Apple Macintosh/Ukrainian"]="55"
  ["Apple Macintosh (Chinese Simplified)"]="56"
  ["Apple Macintosh (Chinese Traditional)"]="57"
  ["Apple Macintosh (Japanese)"]="58"
  ["Apple Macintosh (Korean)"]="59"
  ["Windows-932"]="60"
  ["Windows-936"]="61"
  ["Windows-Wansung-949"]="62"
  ["Windows-950"]="63"
  ["Shift-JIS"]="64"
  ["GB-2312"]="65"
  ["GBT-12345"]="66"
  ["GBK/GB-2312-80"]="67"
  ["BIG5"]="68"
  ["EUC-JP"]="69"
  ["EUC-CN"]="70"
  ["EUC-TW"]="71"
  ["ISO-2022-JP"]="72"
  ["ISO-2022-CN"]="73"
  ["KOI8-R"]="74"
  ["UTF-7"]="75"
  ["UTF-8"]="76"
  ["ISO-8859-10"]="77"
  ["ISO-8859-13"]="78"
  ["EUC-KR"]="79"
  ["ISO-2022-KR"]="80"
  ["JIS 0201"]="81"
  ["JIS 0208"]="82"
  ["JIS 0212"]="83"
  ["Windows-Johab-1361"]="84"
  ["GB-18030"]="85"
  ["BIG5-HKSCS"]="86"
  ["TIS 620"]="87"
  ["KOI8-U"]="88"
  ["ISCII Devanagari"]="89"
  ["Unicode"]="90"
  ["Adobe Standard"]="91"
  ["Adobe Symbol"]="92"
  ["PT 154"]="93"
  ["Unicode UCS4"]="65534"
  ["Unicode UCS2"]="65535"
)

# from https://docs.microsoft.com/fr-fr/deployoffice/office2016/language-identifiers-and-optionstate-id-values-in-office-2016
declare -A language_identifiers
language_identifiers+=(
  ["user interface"]="0"
  ["ar-SA"]="1025"
  ["bg-BG"]="1026"
  ["zh-CN"]="2052"
  ["zh-TW"]="1028"
  ["hr-HR"]="1050"
  ["cs-CZ"]="1029"
  ["da-DK"]="1030"
  ["nl-NL"]="1043"
  ["fr-FR"]="1033"
  ["et-EE"]="1061"
  ["fi-FI"]="1035"
  ["fr-FR"]="1036"
  ["de-DE"]="1031"
  ["el-GR"]="1032"
  ["he-IL"]="1037"
  ["hi-IN"]="1081"
  ["hu-HU"]="1038"
  ["id-ID"]="1057"
  ["it-IT"]="1040"
  ["ja-JP"]="1041"
  ["kz-KZ"]="1087"
  ["ko-KR"]="1042"
  ["lv-LV"]="1062"
  ["lt-LT"]="1063"
  ["ms-MY"]="1086"
  ["nb-NO"]="1044"
  ["pl-PL"]="1045"
  ["pt-BR"]="1046"
  ["pt-PT"]="2070"
  ["ro-RO"]="1048"
  ["ru-RU"]="1049"
  ["sr-latn-RS"]="2074"
  ["sk-SK"]="1051"
  ["sl-SI"]="1060"
  ["es-ES"]="3082"
  ["sv-SE"]="1053"
  ["th-TH"]="1054"
  ["tr-TR"]="1055"
  ["uk-UA"]="1058"
  ["vi-VN"]="1066"
)

function toAscii() {
  LC_CTYPE=C printf '%d' "'$1"
}

function convert_to_csv() {
  #See https://help.libreoffice.org/latest/km/text/shared/guide/csv_params.html?&DbPAR=SHARED&System=UNIX

  local positional=()

  #Convert options
  local field_separator
  field_separator="$(toAscii ',')"
  local text_delimiter
  text_delimiter="$(toAscii '"')"
  local character_set="${language_identifiers["user interface"]}"
  local cell_format=""
  local language_identifier="${characters_set["Unknown"]}"
  local quoted_field_as_text=false
  local store_number_cells_as_numbers=false
  local save_cell_contents_as_shown=false
  local export_cell_formulas=false
  local sheet="0"
  local output_dir="${SCRIPT_DIR}/output"

  # Unused import options
  # https://ask.libreoffice.org/t/how-to-convert-csv-from-command-line-and-ignore-first-lines/77114/4
  local number_of_first_row="0"
  local remove_spaces_trim_leading_and_trailing_spaces=false

  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    --field-separator)
      readonly field_separator="$(toAscii "${2}")"
      shift
      shift
      ;;
    --text-delimiter)
      readonly text_delimiter="$(toAscii "${2}")"
      shift
      shift
      ;;
    --character-set)
      readonly character_set="${2}"
      shift
      shift
      ;;
    --cell-format)
      readonly cell_format="${2}"
      shift
      shift
      ;;
    --language)
      readonly language_identifier="${2}"
      shift
      shift
      ;;
    --quoted-field-as-text)
      readonly quoted_field_as_text=true
      shift
      ;;
    --store-number-cells-as-numbers)
      readonly store_number_cells_as_numbers=true
      shift
      ;;
    --save-cell-contents-as-shown)
      readonly save_cell_contents_as_shown=true
      shift
      ;;
    --export-cell-formulas)
      readonly export_cell_formulas=true
      shift
      ;;
    --sheet)
      readonly sheet="${2}"
      shift
      shift
      ;;
    --output_dir)
      readonly output_dir="${2}"
      shift
      shift
      ;;
    -? | --help)
      usage
      exit 0
      ;;
    *)
      positional+=("$1")
      shift
      ;;
    esac
  done
  set -- "${positional[@]}"

  local options="Text - txt - csv (StarCalc): \
${field_separator},\
${text_delimiter},\
${character_set},\
${number_of_first_row},\
${cell_format},\
${language_identifier},\
${quoted_field_as_text},\
${store_number_cells_as_numbers},\
${save_cell_contents_as_shown},\
${export_cell_formulas},\
${remove_spaces_trim_leading_and_trailing_spaces},\
${sheet}"

  libreoffice --headless --convert-to csv:"${options}" --outdir "${output_dir}" "$@"

}

convert_to_csv "$@"
