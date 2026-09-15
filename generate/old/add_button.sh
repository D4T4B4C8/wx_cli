#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# add_button.sh
# Inserts a new sidebar button into one of your Knowledge Vault
# HTML files, right at the top of the <div class="menu"> block.
# ------------------------------------------------------------

# 1. Ask for the base file name (without .html) and find it
read -rp "Enter file name (without .html), e.g. youtube: " base
base="${base%.html}"   # strip .html if user typed it anyway

echo "Searching for ${base}.html ..."
mapfile -t matches < <(find . -type f -iname "${base}.html" 2>/dev/null)

if [ "${#matches[@]}" -eq 0 ]; then
    echo "No file named '${base}.html' found."
    exit 1
elif [ "${#matches[@]}" -eq 1 ]; then
    target="${matches[0]}"
else
    echo "Multiple matches found:"
    select choice in "${matches[@]}"; do
        if [ -n "$choice" ]; then
            target="$choice"
            break
        fi
    done
fi

echo "Found file: $target"

# 2. Ask for the button heading text
read -rp "Enter button heading (e.g. DOWNLOAD ANY WEBSITE VIDEO): " heading

# 3. Ask for the linked file name (inside the base folder)
read -rp "Enter linked file name (e.g. ytdlp.html): " linked
linked="${linked%.html}.html"   # ensure it ends with .html

link_path="${base}/${linked}"

# Build the button block
button_block=$(cat <<EOF
   <button onclick="window.location.href='${link_path}'">
   ${heading}
   </button>
EOF
)

# 4. Insert the button block right after the line containing <div class="menu">
#    (i.e. at the TOP of the menu, before any existing buttons)

if ! grep -q '<div class="menu">' "$target"; then
    echo "Error: could not find <div class=\"menu\"> in $target"
    exit 1
fi

tmpfile=$(mktemp)

awk -v block="$button_block" '
    { print }
    /<div class="menu">/ && !done {
        print block
        done = 1
    }
' "$target" > "$tmpfile"

cat "$tmpfile" > "$target"
rm -f "$tmpfile"

echo "Done. Inserted button pointing to '${link_path}' into $target"
