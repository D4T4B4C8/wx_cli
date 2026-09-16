#!/usr/bin/env bash
#
# generate_forensic.sh (batch mode)
#
# Reads a single input file containing MANY "WHITEX FORENSIC" page
# definitions, separated by divider lines, and for EACH block:
#   1) Generates the two-column forensic-style HTML page.
#   2) Saves it inside the given folder as <folder>/<outputname>.html.
#
# No manual prompts needed -- everything comes from the file, and
# unlike kv_create/final_auto.sh, this script does NOT insert any
# sidebar buttons into a menu file. It only creates the page files.
#
# ------------------------------------------------------------
# INPUT FILE SYNTAX  (default: cmd_forensic.txt)
# ------------------------------------------------------------
# Each block starts with the destination folder + output filename,
# then the page content, and ends with a divider line of "=" signs:
#
#   #foldername                            -> folder to save the page
#                                              into (searched via `find`)
#   $outputname                            -> output file name (page
#                                              becomes <foldername>/<outputname>.html)
#
#   %FRAME_TITLE% WHITEX FORENSIC          -> top-left header text
#   %FRAME_INDEX% Case File // 002         -> top-right header text
#   %TITLE% YT-DLP                         -> one line per big title word
#   %TITLE% Youtube-DL                        (repeat for each span)
#   %SUBTITLE% Media Extraction Protocol...-> subtitle line
#
#   *YT-DLP                                -> starts a new column/section
#   [Install]                              -> starts a new step inside block
#   -sudo pacman -S yt-dlp                 -> a command (repeat for
#   -pip install 'yt-dlp>=2022.1.21'          multiple = joined with "— or —")
#   **102** = quality number...            -> plain text = note under the
#                                              step (**text** becomes bold)
#
#   *Youtube-DL                            -> next column/section
#   [...]
#   -...
#
#   %FOOTER% Link Status:Encrypted         -> footer entry "Label:Value"
#   %FOOTER% Protocol:Stable                  (repeat as needed)
#
#   ========================================   <- ends this block
#
# Blank lines are ignored. Order matters: TITLE/SUBTITLE/FRAME lines
# should come before the first * block, and %FOOTER% lines are best
# placed at the end (they can appear anywhere though).
#
# ------------------------------------------------------------
# USAGE
# ------------------------------------------------------------
#   ./generate_forensic.sh [input_file]
#   (input_file defaults to cmd_forensic.txt if omitted)
#
set -euo pipefail

INPUT="${1:-cmd_forensic.txt}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

# ------------------------------------------------------------------
# Where to look for the topic folders (forensics/, arch/, ...).
#
# This script may live inside a "generate" subfolder alongside the
# input file, while the actual topic folders live one level up (the
# project root). So we search starting from the parent directory of
# this script, not from "." (which would only be "generate" itself).
#
# Override by exporting SEARCH_DIR before running the script, e.g.:
#   SEARCH_DIR=/path/to/project ./generate_forensic.sh
# ------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SEARCH_DIR="${SEARCH_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

bold_transform() {
    local s="$1"
    while [[ "$s" == *'**'*'**'* ]]; do
        s=$(sed -E 's/\*\*([^*]+)\*\*/<b>\1<\/b>/' <<< "$s")
    done
    printf '%s' "$s"
}

# ------------------------------------------------------------
# Writes the full HTML page for one block to $1 (outfile), using
# the frame_title / frame_index / title_spans / subtitle /
# blocks_html / footer_html globals set up by process_page().
# ------------------------------------------------------------
write_page() {
    local outfile="$1"

    {
cat <<HEAD
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Knowledge Terminal — Media Extraction Protocol</title>
<link rel="stylesheet" href="https://use.typekit.net/fiv8wyx.css">

<style>

*,
*::after,
*::before{
  box-sizing:border-box;
}

:root{
  font-size:12px;
  --color-text: rgba(255,255,255,0.95);
  --color-bg: #0c0b10;
  --color-link: rgb(124 20 244 / 90%);
  --color-bg-date: rgb(96 56 178 / 48%);
  --color-link-hover: rgb(94 54 176 / 75%);
  --color-border: rgba(177,177,177,0.3);
}

body{
  margin:0;
  color:var(--color-text);
  background-color:var(--color-bg);
  font-family:"ocr-a-std", monospace;
  text-transform:uppercase;
  -webkit-font-smoothing:antialiased;
  -moz-osx-font-smoothing:grayscale;
}

a{
  text-decoration:none;
  color:var(--color-link);
  outline:none;
  cursor:pointer;
}

a:hover{
  color:var(--color-link-hover);
}

.frame{
  position:relative;
  z-index:10;
  width:100%;
  display:grid;
  grid-template-columns:1fr auto;
  align-items:center;
  padding:2rem;
  gap:1rem;
}

.frame__title{
  font-size:1.25rem;
  margin:0;
  font-weight:400;
  letter-spacing:0.05em;
}

.frame__index{
  font-size:0.9rem;
  color:var(--color-text);
  opacity:0.5;
  justify-self:end;
  text-align:right;
}

.title{
  font-weight:400;
  font-size:clamp(2rem,8.5vw,6.5rem);
  line-height:1.05;
  text-align:center;
  margin:10vh auto 4vh;
  padding-bottom:2vh;
  display:flex;
  flex-direction:column;
  align-items:center;
  width:min-content;
  min-width:80%;
  border-bottom:1px solid var(--color-border);
}

.title span::first-letter{
  opacity:0.5;
}

.subtitle{
  text-align:center;
  font-size:1rem;
  letter-spacing:0.15em;
  opacity:0.6;
  margin-bottom:8vh;
}

.section-grid{
  display:grid;
  grid-template-columns:1fr;
  border-top:1px solid var(--color-border);
  margin-bottom:6vh;
}

@media screen and (min-width:60em){
  .section-grid{
    grid-template-columns:1fr 1fr;
  }
  .block:nth-child(odd){
    border-right:1px solid var(--color-border);
  }
}

.block{
  padding:4vw;
  border-bottom:1px solid var(--color-border);
}

.block__head{
  display:flex;
  align-items:center;
  margin-bottom:2.5rem;
}

.block__head::before{
  content:'';
  width:15px;
  height:15px;
  flex:none;
  border:1px solid var(--color-link);
  background:var(--color-bg-date);
  margin-right:12px;
}

.block__title{
  font-weight:400;
  font-size:clamp(1.5rem,4vw,2.25rem);
  margin:0;
  letter-spacing:0.05em;
}

.step{
  margin-bottom:2.6rem;
}

.step:last-child{
  margin-bottom:0;
}

.step__label{
  display:flex;
  align-items:center;
  font-size:0.95rem;
  opacity:0.55;
  letter-spacing:0.15em;
  margin-bottom:0.9rem;
}

.step__label::before{
  content:'';
  width:6px;
  height:6px;
  margin-right:10px;
  background:var(--color-link);
}

.cmd{
  position:relative;
  display:block;
  padding:1.1rem 1.2rem 1.1rem 2rem;
  border:1px solid var(--color-border);
  font-size:1.05rem;
  letter-spacing:0.02em;
  color:var(--color-text);
  transition:background-color 0.3s ease, border-color 0.3s ease, color 0.3s ease;
}

.cmd::before{
  content:'+';
  position:absolute;
  left:0.8rem;
  color:var(--color-link);
}

.cmd:hover{
  background-color:var(--color-bg-date);
  border-color:var(--color-link);
  color:var(--color-text);
}

.cmd:hover::before{
  color:#fff;
}

.or{
  text-align:center;
  font-size:0.85rem;
  opacity:0.4;
  letter-spacing:0.2em;
  margin:0.9rem 0;
}

.note{
  font-size:0.85rem;
  opacity:0.45;
  letter-spacing:0.05em;
  margin-top:0.8rem;
}

.note b{
  opacity:1;
  color:var(--color-text);
}

.foot{
  display:flex;
  justify-content:space-between;
  padding:2rem;
  border-top:1px solid var(--color-border);
  font-size:0.85rem;
  opacity:0.5;
  letter-spacing:0.15em;
}

.foot span b{
  opacity:1;
  color:var(--color-link);
  font-weight:400;
}

@media screen and (max-width:33em){
  .foot{
    flex-direction:column;
    gap:0.6rem;
  }
}

</style>
</head>
<body>

<div class="frame">
  <h1 class="frame__title">${frame_title}</h1>
  <span class="frame__index">${frame_index}</span>
</div>

<main>

  <h1 class="title">
${title_spans}  </h1>
  <p class="subtitle">${subtitle}</p>

  <div class="section-grid">
${blocks_html}  </div>

  <div class="foot">
${footer_html}  </div>

</main>

</body>
</html>
HEAD
    } > "$outfile"
}

# ------------------------------------------------------------
# Parses one block's lines (the %FRAME_TITLE%/%BLOCK%/%STEP%/...
# content for a single page) and writes the resulting HTML file
# into the matching folder under $SEARCH_DIR. No button/menu
# insertion happens here -- just the file gets created.
# ------------------------------------------------------------
process_page() {
    local foldername="$1" outname="$2"
    shift 2
    local content_lines=("$@")

    if [[ -z "$foldername" || -z "$outname" ]]; then
        echo "Skipping incomplete block (missing #folder or \$name)." >&2
        return
    fi

    # ---- reset per-page state ----
    frame_title=""
    frame_index=""
    title_spans=""
    subtitle=""
    blocks_html=""
    footer_html=""

    block_title=""
    block_steps=""

    step_label=""
    step_cmds=()
    step_note=""
    in_step=false
    in_block=false

    flush_step() {
        if ! $in_step; then return 0; fi
        local cmds_html="" i=0
        for c in "${step_cmds[@]}"; do
            if [[ $i -gt 0 ]]; then
                cmds_html+="        <div class=\"or\">— or —</div>"$'\n'
            fi
            cmds_html+="        <a class=\"cmd\">${c}</a>"$'\n'
            i=$((i+1))
        done

        local note_html=""
        if [[ -n "$step_note" ]]; then
            note_html="        <div class=\"note\">$(bold_transform "$step_note")</div>"$'\n'
        fi

        block_steps+="      <div class=\"step\">"$'\n'
        block_steps+="        <div class=\"step__label\">${step_label}</div>"$'\n'
        block_steps+="${cmds_html}${note_html}"
        block_steps+="      </div>"$'\n'

        step_label=""
        step_cmds=()
        step_note=""
        in_step=false
    }

    flush_block() {
        if ! $in_block; then return 0; fi
        flush_step
        blocks_html+="    <section class=\"block\">"$'\n'
        blocks_html+="      <div class=\"block__head\">"$'\n'
        blocks_html+="        <h2 class=\"block__title\">${block_title}</h2>"$'\n'
        blocks_html+="      </div>"$'\n'
        blocks_html+="${block_steps}"
        blocks_html+="    </section>"$'\n'
        block_title=""
        block_steps=""
        in_block=false
    }

    local line
    for line in "${content_lines[@]}"; do
        case "$line" in
            "%FRAME_TITLE% "*)
                frame_title="${line#%FRAME_TITLE% }"
                ;;
            "%FRAME_INDEX% "*)
                frame_index="${line#%FRAME_INDEX% }"
                ;;
            "%TITLE% "*)
                title_spans+="    <span>${line#%TITLE% }</span>"$'\n'
                ;;
            "%SUBTITLE% "*)
                if [[ -n "$subtitle" ]]; then
                    subtitle+="<br>"
                fi
                subtitle+="${line#%SUBTITLE% }"
                ;;
            "%FOOTER% "*)
                entry="${line#%FOOTER% }"
                label="${entry%%:*}"
                value="${entry#*:}"
                footer_html+="    <span>${label}: <b>${value}</b></span>"$'\n'
                ;;
            "*"*)
                # *TEXT -> new BLOCK (column/section), e.g. *EO1 (ENCASE)
                flush_block
                block_title="$(trim "${line#\*}")"
                in_block=true
                ;;
            "["*)
                # [TEXT] -> new STEP inside the current block, e.g. [TOOLS]
                flush_step
                step_label="${line#[}"
                step_label="${step_label%]}"
                step_label="$(trim "$step_label")"
                in_step=true
                ;;
            "-"*)
                # -TEXT -> a CMD under the current step. Consecutive -cmd
                # lines auto-join with "— or —" between them.
                if ! $in_step; then
                    flush_step
                    step_label=""
                    in_step=true
                fi
                step_cmds+=("$(trim "${line#-}")")
                ;;
            OR|or)
                # A lone "OR" line is decorative -- consecutive -cmd lines
                # already get "— or —" inserted between them automatically.
                ;;
            *)
                # Plain text -> NOTE attached to the current step. If no
                # step is open yet (text right after a *BLOCK title),
                # open an unlabeled step to hold it.
                if ! $in_step; then
                    if ! $in_block; then
                        echo "Warning: ignoring text with no open block/step in '${outname}': $line" >&2
                        continue
                    fi
                    step_label=""
                    in_step=true
                fi
                if [[ -n "$step_note" ]]; then
                    step_note+=" ${line}"
                else
                    step_note="$line"
                fi
                ;;
        esac
    done

    flush_block

    # ---- find the destination folder ----
    mapfile -t folder_matches < <(find "$SEARCH_DIR" -type d -iname "${foldername}" 2>/dev/null)

    local targetdir
    if [ "${#folder_matches[@]}" -eq 0 ]; then
        echo "No folder named '${foldername}' found. Skipping '${outname}'." >&2
        return
    elif [ "${#folder_matches[@]}" -eq 1 ]; then
        targetdir="${folder_matches[0]}"
    else
        echo "Multiple matching folders found for '${foldername}':"
        select choice in "${folder_matches[@]}"; do
            [ -n "$choice" ] && { targetdir="$choice"; break; }
        done
    fi

    local outfile="${targetdir}/${outname}.html"
    write_page "$outfile"
    echo "Saved: $outfile"
    echo "---"
}

# ==============================================================
# Main: split input file into blocks separated by divider lines
# ==============================================================

folder=""
outname=""
content=()
page_count=0

flush_page() {
    if [[ -n "$folder" || -n "$outname" || ${#content[@]} -gt 0 ]]; then
        page_count=$((page_count + 1))
        process_page "$folder" "$outname" "${content[@]}"
    fi
    folder=""; outname=""; content=()
}

while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="$(trim "$line")"

    # A divider line (e.g. "========================================")
    # marks the end of the current block/page.
    if [[ "$trimmed" =~ ^=+$ ]]; then
        flush_page
        continue
    fi

    # Blank lines are just spacing inside a block, ignore them.
    if [[ -z "$trimmed" ]]; then
        continue
    fi

    case "$line" in
        "#"*)
            if [[ -z "$folder" ]]; then
                folder="$(trim "${line#\#}")"
            else
                content+=("$line")
            fi
            ;;
        "\$"*)
            if [[ -z "$outname" ]]; then
                outname="$(trim "${line#\$}")"
            else
                content+=("$line")
            fi
            ;;
        *) content+=("$line") ;;
    esac
done < "$INPUT"

# flush the last block (file may not end with a divider)
flush_page

echo "Finished. Processed ${page_count} page block(s) from $INPUT."
