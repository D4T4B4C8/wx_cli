#!/usr/bin/env bash
#
# sort_topics.sh
#
# Reads a cmd.txt file (same block format used by final_auto.sh) and
# groups every "*HEADING" line under its "#folder" line, then prints
# them sorted alphabetically by folder, with headings sorted
# alphabetically within each folder.
#
# Blocks are separated by a line of "=" signs (e.g.
# "========================================"), same as final_auto.sh.
# Only the first "#" and first "*" seen in a block are treated as the
# folder/heading markers; anything after that is ignored for this
# purpose (so stray "#" lines inside a body don't get picked up).
#
# USAGE:
#   ./sort_topics.sh [input_file]
#   (input_file defaults to cmd.txt if omitted)
#
set -euo pipefail

INPUT="${1:-cmd.txt}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

folder=""
heading=""

# Map folder -> newline-separated list of headings
declare -A groups

flush_block() {
    if [[ -n "$folder" && -n "$heading" ]]; then
        groups["$folder"]+="${heading}"$'\n'
    fi
    folder=""
    heading=""
}

while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="$(trim "$line")"

    if [[ "$trimmed" =~ ^=+$ ]]; then
        flush_block
        continue
    fi

    if [[ -z "$trimmed" ]]; then
        continue
    fi

    case "$line" in
        "#"*)
            [[ -z "$folder" ]] && folder="$(trim "${line#\#}")"
            ;;
        "*"*)
            [[ -z "$heading" ]] && heading="$(trim "${line#\*}")"
            ;;
        *) : ;;  # ignore body lines ($outname, -commands, [labels], plain text)
    esac
done < "$INPUT"

# flush the last block (file may not end with a divider)
flush_block

# ---- print grouped + sorted output ----
if [[ "${#groups[@]}" -eq 0 ]]; then
    echo "No #folder / *heading pairs found in $INPUT" >&2
    exit 0
fi

for folder in $(printf '%s\n' "${!groups[@]}" | sort -f); do
    echo "== ${folder} =="
    printf '%s' "${groups[$folder]}" | sort -f | sed '/^$/d;s/^/  - /'
    echo
done
