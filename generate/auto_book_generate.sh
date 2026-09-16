#!/usr/bin/env bash
#
# kv_create.sh (batch mode)
#
# Reads a single cmd.txt file containing MANY page definitions,
# separated by blank lines, and for EACH block:
#   1) Generates a Knowledge Terminal HTML page inside the given
#      folder.
#   2) Inserts a sidebar button for that page into <folder>.html.
#
# No manual prompts needed -- everything comes from the file.
#
# cmd.txt block format (one block per page, separated by a blank line):
#   #foldername        -> folder to save the page into (and name of
#                          the menu file: <foldername>.html)
#   $outputname         -> output file name (page becomes
#                          <foldername>/<outputname>.html)
#   *HEADING TEXT        -> used as both the sidebar button text and
#                          the page's <h1>
#   -some command         -> rendered as a command badge (<span>)
#   [SOME LABEL]           -> rendered as a <h4>
#   @img.png               -> rendered as an <img> (alt defaults to filename)
#   @img.png|Alt text      -> same, with a custom alt attribute
#   %file.py                -> rendered as a download link
#                              (label defaults to "Download file.py")
#   %file.py|Label text      -> same, with a custom link label
#   +https://example.com    -> rendered as an external link
#                              (label defaults to "Visit Website")
#   +https://example.com|Label -> same, with a custom link label
#   any other plain text -> rendered as a <p>
#
# USAGE:
#   ./kv_create.sh [input_file]
#   (input_file defaults to cmd.txt if omitted)
#
set -euo pipefail

INPUT="${1:-cmd.txt}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

# ------------------------------------------------------------------
# Where to look for the topic folders (arch/, hardware/, os/, ...)
# and their menu files (arch.html, hardware.html, ...).
#
# This script now lives inside a "generate" subfolder alongside
# cmd.txt, while the actual topic folders live one level up (the
# project root). So we search starting from the parent directory of
# this script, not from "." (which would only be "generate" itself).
#
# Override by exporting SEARCH_DIR before running the script, e.g.:
#   SEARCH_DIR=/path/to/project ./final_auto.sh
# ------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SEARCH_DIR="${SEARCH_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

SPAN_STYLE="background:#ffffff22; color:#fff; border:1px solid #ffffff55; padding:4px 10px; border-radius:999px; font-weight:bold; display:inline-block; margin-top:10px; line-height:1.6;"

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

write_page() {
    local outfile="$1"
    local generated="$2"

    {
cat <<'HEAD'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Knowledge Terminal</title>

<style>

:root{
--accent:#5EFFF7;
--bg:#050505;
}

*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:Consolas, monospace;
}

body{
background:var(--bg);
overflow:hidden;
height:100vh;
color:white;
}

/* Animated Grid */

.grid{
position:fixed;
inset:0;

background:
linear-gradient(rgba(94,255,247,.05) 1px, transparent 1px),
linear-gradient(90deg, rgba(94,255,247,.05) 1px, transparent 1px);

background-size:40px 40px;

animation:gridmove 20s linear infinite;
}

@keyframes gridmove{
from{transform:translateY(0);}
to{transform:translateY(40px);}
}

/* Network Canvas */

#network{
position:fixed;
inset:0;
z-index:0;
opacity:.6;
}

/* Center Box */

.container{
position:fixed;
inset:0;

display:flex;
justify-content:center;
align-items:center;

padding:30px;
z-index:10;
}

.textbox{

width:min(900px,90vw);
max-height:80vh;

overflow:auto;

padding:40px;

background:rgba(255,255,255,.05);

backdrop-filter:blur(18px);
-webkit-backdrop-filter:blur(18px);

border:1px solid rgba(94,255,247,.25);

box-shadow:
0 0 25px rgba(94,255,247,.15);

border-radius:18px;
}

.textbox h1{
color:var(--accent);
margin-bottom:20px;
}

.textbox p{
line-height:1.8;
font-size:16px;
color:#e9ffff;
}

.textbox a{
color:#FA3B34;
}

.textbox a:visited{
color:#FA3B34;
}

.textbox a:hover{
color:#FA3B34;
}

</style>
</head>
<body>

<canvas id="network"></canvas>

<div class="grid"></div>

<div class="container">

<div class="textbox">

HEAD

printf '%s' "$generated"

cat <<'TAIL'

</div>

<script>

const canvas=document.getElementById("network");
const ctx=canvas.getContext("2d");

function resize(){
canvas.width=window.innerWidth;
canvas.height=window.innerHeight;
}

resize();
window.addEventListener("resize",resize);

const nodes=[];

for(let i=0;i<70;i++){

nodes.push({
x:Math.random()*canvas.width,
y:Math.random()*canvas.height,
vx:(Math.random()-.5)*0.4,
vy:(Math.random()-.5)*0.4
});

}

function animate(){

ctx.clearRect(
0,
0,
canvas.width,
canvas.height
);

for(let a of nodes){

a.x+=a.vx;
a.y+=a.vy;

if(a.x<0||a.x>canvas.width) a.vx*=-1;
if(a.y<0||a.y>canvas.height) a.vy*=-1;

ctx.fillStyle="#5EFFF7";

ctx.fillRect(
a.x,
a.y,
2,
2
);

for(let b of nodes){

let dx=a.x-b.x;
let dy=a.y-b.y;

let dist=Math.sqrt(
dx*dx+dy*dy
);

if(dist<150){

ctx.strokeStyle=
"rgba(94,255,247,.08)";

ctx.beginPath();

ctx.moveTo(a.x,a.y);
ctx.lineTo(b.x,b.y);

ctx.stroke();

}

}

}

requestAnimationFrame(animate);

}

animate();

</script>

<script>
const SCRAMBLE_CHARS = "#█░▓▒/\\<>01";

function scrambleElement(el) {
    const original = el.textContent;
    let progress = 0;

    const duration = 1200; // 1.2 seconds
    const frameRate = 30;
    const totalFrames = duration / frameRate;

    const timer = setInterval(() => {

        progress++;

        const revealCount =
            Math.floor((progress / totalFrames) * original.length);

        let output = "";

        for (let i = 0; i < original.length; i++) {

            if (
                original[i] === " " ||
                original[i] === "\n"
            ) {
                output += original[i];
                continue;
            }

            if (i < revealCount) {
                output += original[i];
            } else {
                output += SCRAMBLE_CHARS[
                    Math.floor(
                        Math.random() * SCRAMBLE_CHARS.length
                    )
                ];
            }
        }

        el.textContent = output;

        if (progress >= totalFrames) {
            clearInterval(timer);
            el.textContent = original;
        }

    }, frameRate);
}

window.addEventListener("load", () => {
    document
        .querySelectorAll(".scramble")
        .forEach(scrambleElement);
});
</script>


</body>
</html>
TAIL

    } > "$outfile"
}

process_block() {
    local foldername="$1" outname="$2" heading="$3"
    shift 3
    local body=("$@")

    if [[ -z "$foldername" || -z "$outname" || -z "$heading" ]]; then
        echo "Skipping incomplete block (missing #folder, \$name, or *heading)." >&2
        return
    fi

    # ---- build the page content ----
    local generated=""
    generated+="<h1 class=\"scramble\">${heading}</h1>"$'\n'
    generated+="<br>"$'\n'"<br>"$'\n'

    local line
    for line in "${body[@]}"; do
        case "$line" in
            "-"*)
                local cmd="${line#-}"
                cmd="$(trim "$cmd")"
                generated+="<span style=\"${SPAN_STYLE}\">${cmd}</span>"$'\n'
                generated+="<br>"$'\n'"<br>"$'\n'
                ;;
            "["*)
                local h4text="${line#[}"
                h4text="${h4text%]}"
                h4text="$(trim "$h4text")"
                generated+="<h4 class=\"scramble\">${h4text}</h4>"$'\n'
                generated+="<br>"$'\n'"<br>"$'\n'
                ;;
            "@"*)
                # @path/to/img.png            -> alt text defaults to filename
                # @path/to/img.png|Alt text    -> custom alt text
                local imgraw="${line#@}"
                local imgsrc="${imgraw%%|*}"
                local imgalt="${imgraw#*|}"
                imgsrc="$(trim "$imgsrc")"
                if [[ "$imgalt" == "$imgraw" ]]; then
                    imgalt="$(basename "$imgsrc")"
                else
                    imgalt="$(trim "$imgalt")"
                fi
                generated+="<img src=\"${imgsrc}\" alt=\"${imgalt}\" width=\"300\">"$'\n'
                generated+="<br>"$'\n'"<br>"$'\n'
                ;;
            "%"*)
                # %path/to/file.py            -> link text defaults to "Download <filename>"
                # %path/to/file.py|Label text -> custom link text
                local fileraw="${line#%}"
                local filehref="${fileraw%%|*}"
                local filelabel="${fileraw#*|}"
                filehref="$(trim "$filehref")"
                if [[ "$filelabel" == "$fileraw" ]]; then
                    filelabel="Download $(basename "$filehref")"
                else
                    filelabel="$(trim "$filelabel")"
                fi
                generated+="<a href=\"${filehref}\" download>${filelabel}</a>"$'\n'
                generated+="<br>"$'\n'"<br>"$'\n'
                ;;
            "+"*)
                # +https://example.com                -> link text defaults to "Visit Website"
                # +https://example.com|Custom label   -> custom link text
                local urlraw="${line#+}"
                local urlhref="${urlraw%%|*}"
                local urllabel="${urlraw#*|}"
                urlhref="$(trim "$urlhref")"
                if [[ "$urllabel" == "$urlraw" ]]; then
                    urllabel="Visit Website"
                else
                    urllabel="$(trim "$urllabel")"
                fi
                generated+="<a href=\"${urlhref}\" target=\"_blank\">${urllabel}</a>"$'\n'
                generated+="<br>"$'\n'"<br>"$'\n'
                ;;
            *)
                generated+="<pre>${line}</pre>"$'\n'
                generated+="<br>"$'\n'
                ;;
        esac
    done

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
    write_page "$outfile" "$generated"
    echo "Saved: $outfile"

    # ---- insert the sidebar button into <foldername>.html ----
    local link_path="${foldername}/${outname}.html"
    mapfile -t matches < <(find "$SEARCH_DIR" -type f -iname "${foldername}.html" 2>/dev/null)

    local target
    if [ "${#matches[@]}" -eq 0 ]; then
        echo "No file named '${foldername}.html' found. Skipping button for '${outname}'." >&2
        return
    elif [ "${#matches[@]}" -eq 1 ]; then
        target="${matches[0]}"
    else
        echo "Multiple matches found for '${foldername}.html':"
        select choice in "${matches[@]}"; do
            [ -n "$choice" ] && { target="$choice"; break; }
        done
    fi

    if ! grep -qE '<div class="(kv-)?menu">' "$target"; then
        echo "Warning: could not find menu div in $target. Skipping button for '${outname}'." >&2
        return
    fi

    local button_block
    button_block=$(cat <<EOF
   <button onclick="window.location.href='${link_path}'">
   ${heading}
   </button>
EOF
)

    local tmpfile
    tmpfile=$(mktemp)

    awk -v block="$button_block" '
        { print }
        /<div class="(kv-)?menu">/ && !done {
            print block
            done = 1
        }
    ' "$target" > "$tmpfile"

    cat "$tmpfile" > "$target"
    rm -f "$tmpfile"

    echo "Button added to $target -> $link_path"
    echo "---"
}

# ==============================================================
# Main: split cmd.txt into blocks separated by blank lines
# ==============================================================

folder=""
outname=""
heading=""
body=()
page_count=0

flush_block() {
    if [[ -n "$folder" || -n "$outname" || -n "$heading" || ${#body[@]} -gt 0 ]]; then
        page_count=$((page_count + 1))
        process_block "$folder" "$outname" "$heading" "${body[@]}"
    fi
    folder=""; outname=""; heading=""; body=()
}

while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="$(trim "$line")"

    # A divider line (e.g. "========================================")
    # marks the end of the current block/topic.
    if [[ "$trimmed" =~ ^=+$ ]]; then
        flush_block
        continue
    fi

    # Blank lines are just spacing inside a block now (dividers are
    # what separate blocks), so ignore them instead of flushing.
    if [[ -z "$trimmed" ]]; then
        continue
    fi

    case "$line" in
        "#"*)
            # Only treat as the folder marker if we haven't seen one
            # yet for this block. A later "#..." line inside the body
            # (e.g. a "# comment" used as a sub-heading) is kept as
            # plain text instead of being mistaken for a new block.
            if [[ -z "$folder" ]]; then
                folder="$(trim "${line#\#}")"
            else
                body+=("$line")
            fi
            ;;
        "\$"*)
            if [[ -z "$outname" ]]; then
                outname="$(trim "${line#\$}")"
            else
                body+=("$line")
            fi
            ;;
        "*"*)
            if [[ -z "$heading" ]]; then
                heading="$(trim "${line#\*}")"
            else
                body+=("$line")
            fi
            ;;
        *) body+=("$line") ;;
    esac
done < "$INPUT"

# flush the last block (file may not end with a blank line)
flush_block

echo "Finished. Processed ${page_count} page block(s) from $INPUT."
