#!/usr/bin/env bash
# img_to_card.sh
# Pick an image with fzf, base64-encode it, and insert it as a new
# "card" article directly into forensics.html (before </section> of
# the .card-grid container).
#
# Usage:
#   ./img_to_card.sh [html_file] [search_dir] [link] [date] [title]
#
# All args are optional:
#   html_file   - target HTML file to insert the card into (default: forensics.html)
#   search_dir  - directory to search for images with fzf (default: .)
#   link/date/title - card metadata; if omitted, you'll be prompted.
#
# NOTE: The actual base64 + insertion work happens in Python (below),
# not in awk/sed, because large images produce base64 strings that
# blow past the shell's ARG_MAX if passed as a command-line argument
# (this is what caused "Argument list too long" previously). Python
# reads/writes the files directly instead, so there's no such limit.

set -euo pipefail

command -v fzf >/dev/null 2>&1 || { echo "fzf is not installed. Install it first (e.g. brew install fzf / apt install fzf)." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 is required but not found." >&2; exit 1; }

HTML_FILE="${1:-forensics.html}"
SEARCH_DIR="${2:-.}"

if [[ ! -f "$HTML_FILE" ]]; then
    echo "HTML file not found: $HTML_FILE" >&2
    exit 1
fi

# 1. Pick the image with fzf (with a preview if a preview tool is available)
if command -v chafa >/dev/null 2>&1; then
    PREVIEW_CMD="chafa -s 60x30 {}"
elif command -v viu >/dev/null 2>&1; then
    PREVIEW_CMD="viu -w 60 {}"
else
    PREVIEW_CMD="echo {} (install chafa or viu for image preview)"
fi

IMG_PATH=$(find "$SEARCH_DIR" -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null \
    | fzf --prompt="Select image > " --preview="$PREVIEW_CMD" --height=80% --border)

if [[ -z "${IMG_PATH:-}" ]]; then
    echo "No image selected." >&2
    exit 1
fi

# 2. Gather card metadata (from args or prompt)
LINK="${3:-}"
DATE="${4:-}"
TITLE="${5:-}"

[[ -z "$LINK"  ]] && read -rp "Link (e.g. a.html): " LINK
[[ -z "$DATE"  ]] && read -rp "Date (e.g. 02/18/2074): " DATE
[[ -z "$TITLE" ]] && read -rp "Title: " TITLE

# 3. Do the base64 encoding + in-place HTML insertion in Python.
#    Only small strings (paths, link, date, title) are passed as argv;
#    the base64 payload itself is built and written entirely inside
#    the Python process, so ARG_MAX is never a concern.
python3 - "$HTML_FILE" "$IMG_PATH" "$LINK" "$DATE" "$TITLE" <<'PYEOF'
import sys
import base64
import mimetypes
import re

html_file, img_path, link, date, title = sys.argv[1:6]

# Determine MIME type
mime, _ = mimetypes.guess_type(img_path)
if not mime or not mime.startswith("image/"):
    mime = "image/jpeg"

# Base64-encode the image
with open(img_path, "rb") as f:
    b64 = base64.b64encode(f.read()).decode("ascii")

card = f'''    <article class="card" onclick="window.location.href='{link}'" style="cursor:pointer;">
        <div class="card__img" style="background-image:url(data:{mime};base64,{b64})"></div>
        <span class="card__date" data-splitting>{date}</span>
        <h2 class="card__title" data-splitting>{title}</h2>
        <a href="#" class="card__link" data-splitting>Read the article</a>
    </article>
'''

with open(html_file, "r", encoding="utf-8") as f:
    content = f.read()

# Insert the card right before the first </section> that follows
# <section class="card-grid">
pattern = re.compile(r'(<section class="card-grid">)(.*?)(</section>)', re.DOTALL)

def inject(match):
    return match.group(1) + match.group(2) + card + match.group(3)

new_content, n = pattern.subn(inject, content, count=1)

if n == 0:
    print('Could not find <section class="card-grid"> ... </section> in the HTML file.', file=sys.stderr)
    sys.exit(1)

with open(html_file, "w", encoding="utf-8") as f:
    f.write(new_content)

print(f"✅ Card added to {html_file} (image: {img_path})")
PYEOF
