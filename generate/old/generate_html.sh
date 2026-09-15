#!/usr/bin/env bash
#
# generate_html.sh
#
# Converts a plain-text "cmd.txt" file into the HTML snippet format
# used in ytdlp.html, then wraps it inside the full ytdlp.html page
# template (grid background, network canvas, glass textbox, scramble
# animation) and saves the result as <output_name>.html.
#
# RULES (unchanged):
#   - Line 1 of the file          -> <h1 class="scramble">...</h1>
#   - A line starting with ">"    -> <span style="...">...</span>   (command badge)
#   - A line starting with "["    -> <h4 class="scramble">...</h4>
#   - Any other non-empty line    -> <p>...</p>
#   - A blank line                -> just <br>
#   - <br> is printed after every processed line
#
# USAGE:
#   ./generate_html.sh cmd.txt
#   -> then it will ask you for an output file name, e.g. "abc"
#      and save the result as abc.html
#
set -euo pipefail

INPUT="${1:-cmd.txt}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file '$INPUT' not found." >&2
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

# The exact inline style used for command badges in ytdlp.html
SPAN_STYLE="background:#ffffff22; color:#fff; border:1px solid #ffffff55; padding:4px 10px; border-radius:999px; font-weight:bold;"

# ------------------------------------------------------------
# Step 1: Generate the inner content (same logic as before),
# captured into a variable instead of printed directly.
# ------------------------------------------------------------

generated=""
first_line=true

while IFS= read -r line || [[ -n "$line" ]]; do

    if $first_line; then
        generated+="<h1 class=\"scramble\">${line}</h1>"$'\n'
        generated+="<br>"$'\n'
        generated+="<br>"$'\n'
        first_line=false
        continue
    fi

    if [[ -z "$line" ]]; then
        generated+="<br>"$'\n'
        generated+="<br>"$'\n'
        continue
    fi

    case "$line" in
        ">"*)
            generated+="<span style=\"${SPAN_STYLE}\">${line}</span>"$'\n'
            generated+="<br>"$'\n'
            generated+="<br>"$'\n'
            ;;
        "["*)
            generated+="<h4 class=\"scramble\">${line}</h4>"$'\n'
            generated+="<br>"$'\n'
            generated+="<br>"$'\n'
            ;;
        *)
            generated+="<p>${line}</p>"$'\n'
            generated+="<br>"$'\n'
            generated+="<br>"$'\n'
            ;;
    esac

done < "$INPUT"

# ------------------------------------------------------------
# Step 2: Ask for the folder name and find it
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
# Step 3: Ask for the output file name
# ------------------------------------------------------------

read -rp "Enter output file name (without .html): " outname
outname="${outname%.html}"
outfile="${targetdir}/${outname}.html"

# ------------------------------------------------------------
# Step 3: Wrap the generated content inside the ytdlp.html template
# ------------------------------------------------------------

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

echo "Done. Saved as $outfile"
