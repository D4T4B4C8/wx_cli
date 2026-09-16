#!/usr/bin/env bash
#
# generate_forensic.sh
#
# Converts a marked-up plain-text file into the "WHITEX FORENSIC"
# two-column HTML template (the style used in ytdlp(1).html), then
# saves it as <folder>/<output_name>.html
#
# ------------------------------------------------------------
# INPUT FILE SYNTAX  (default: cmd_forensic.txt)
# ------------------------------------------------------------
#   %FRAME_TITLE% WHITEX FORENSIC          -> top-left header text
#   %FRAME_INDEX% Case File // 002         -> top-right header text
#   %TITLE% YT-DLP                         -> one line per big title word
#   %TITLE% Youtube-DL                        (repeat for each span)
#   %SUBTITLE% Media Extraction Protocol...-> subtitle line
#
#   %BLOCK% YT-DLP                         -> starts a new column/section
#   %STEP% Install                         -> starts a new step inside block
#   %CMD% sudo pacman -S yt-dlp            -> a command (repeat for
#   %CMD% pip install 'yt-dlp>=2022.1.21'     multiple = joined with "— or —")
#   %NOTE% **102** = quality number...     -> optional note under the step
#                                              (**text** becomes bold)
#
#   %BLOCK% Youtube-DL                     -> next column/section
#   %STEP% ...
#   %CMD% ...
#
#   %FOOTER% Link Status:Encrypted         -> footer entry "Label:Value"
#   %FOOTER% Protocol:Stable                  (repeat as needed)
#
# Blank lines are ignored. Order matters: TITLE/SUBTITLE/FRAME lines
# should come before the first %BLOCK%, and %FOOTER% lines are best
# placed at the end (they can appear anywhere though).
#
# ------------------------------------------------------------
# USAGE
# ------------------------------------------------------------
#   ./generate_forensic.sh cmd_forensic.txt
#   -> asks for a folder name (searched recursively via `find`)
#   -> asks for an output file name, e.g. "abc"
#   -> saves as <folder>/abc.html
#
set -euo pipefail

INPUT="${1:-cmd_forensic.txt}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

# ------------------------------------------------------------
# Parse the input file
# ------------------------------------------------------------

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

bold_transform() {
    local s="$1"
    while [[ "$s" == *'**'*'**'* ]]; do
        s=$(sed -E 's/\*\*([^*]+)\*\*/<b>\1<\/b>/' <<< "$s")
    done
    printf '%s' "$s"
}

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

while IFS= read -r line || [[ -n "$line" ]]; do

    [[ -z "$line" ]] && continue

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
            subtitle="${line#%SUBTITLE% }"
            ;;
        "%BLOCK% "*)
            flush_block
            block_title="${line#%BLOCK% }"
            in_block=true
            ;;
        "%STEP% "*)
            flush_step
            step_label="${line#%STEP% }"
            in_step=true
            ;;
        "%CMD% "*)
            step_cmds+=("${line#%CMD% }")
            ;;
        "%NOTE% "*)
            step_note="${line#%NOTE% }"
            ;;
        "%FOOTER% "*)
            entry="${line#%FOOTER% }"
            label="${entry%%:*}"
            value="${entry#*:}"
            footer_html+="    <span>${label}: <b>${value}</b></span>"$'\n'
            ;;
        *)
            echo "Warning: ignoring unrecognized line: $line" >&2
            ;;
    esac

done < "$INPUT"

flush_block

# ------------------------------------------------------------
# Ask for the folder name and find it
# ------------------------------------------------------------

read -rp "Enter folder name, e.g. youtube: " foldername

echo "Searching for folder '${foldername}' ..."
mapfile -t folder_matches < <(find . -type d -iname "${foldername}" 2>/dev/null)

if [ "${#folder_matches[@]}" -eq 0 ]; then
    echo "No folder named '${foldername}' found."
    exit 1
elif [ "${#folder_matches[@]}" -eq 1 ]; then
    targetdir="${folder_matches[0]}"
else
    echo "Multiple matching folders found:"
    select choice in "${folder_matches[@]}"; do
        if [ -n "$choice" ]; then
            targetdir="$choice"
            break
        fi
    done
fi

echo "Found folder: $targetdir"

# ------------------------------------------------------------
# Ask for the output file name
# ------------------------------------------------------------

read -rp "Enter output file name (without .html): " outname
outname="${outname%.html}"
outfile="${targetdir}/${outname}.html"

# ------------------------------------------------------------
# Assemble the final HTML
# ------------------------------------------------------------

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
  .block:first-child{
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

echo "Done. Saved as $outfile"
