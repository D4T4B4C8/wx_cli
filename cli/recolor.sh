#!/usr/bin/env bash
#
# recolor.sh
# Asks for a hex color, then updates every *.html file in the current
# directory so that:
#   - --text (titles/headings/logo text) is always forced to white
#   - --accent, --border, --glow (bars/buttons/borders/glow) get the
#     hex color you type in
#
# Usage:
#   ./recolor.sh
#   (then type a hex code like #F54927 or F54927 when prompted)

set -euo pipefail

read -rp "Enter new hex color for bars/buttons/borders (e.g. #F54927): " COLOR

# Add leading # if missing
if [[ "${COLOR:0:1}" != "#" ]]; then
    COLOR="#${COLOR}"
fi

# Validate hex format: #RGB or #RRGGBB
if ! [[ "$COLOR" =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]; then
    echo "Error: '$COLOR' is not a valid hex color (expected format #RRGGBB or #RGB)."
    exit 1
fi

WHITE="#FFFFFF"

echo "Bars/borders/buttons -> $COLOR"
echo "Titles/headings text -> $WHITE"

shopt -s nullglob
FILES=(*.html)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No .html files found in the current directory."
    exit 1
fi

for f in "${FILES[@]}"; do
    # Backup once
    cp "$f" "$f.bak"

    # --text (and --kv-text) is always forced to white (titles/headings/logo
    # inherit this), whether it was a literal hex value or something like
    # var(--accent).
    # --accent / --border (--kv-border) / --glow (--kv-glow) get the
    # user-chosen color (only when they hold a literal hex value; ones set
    # to var(--accent) are left alone since --accent itself already becomes
    # the new color).
    # The optional "kv-" prefix covers files like cli.html / mesg.html that
    # name their variables --kv-border / --kv-text / --kv-glow instead of
    # the plain --border / --text / --glow. Other unrelated variables in the
    # same file (e.g. --text-color, --link-color, --cda-text-color) are left
    # untouched on purpose.
    sed -i -E \
        -e "s/(--(kv-)?text[[:space:]]*:[[:space:]]*)[^;]+;/\1${WHITE};/g" \
        -e "s/(--accent[[:space:]]*:[[:space:]]*)#[A-Fa-f0-9]{3,6}/\1${COLOR}/g" \
        -e "s/(--(kv-)?border[[:space:]]*:[[:space:]]*)#[A-Fa-f0-9]{3,6}/\1${COLOR}/g" \
        -e "s/(--(kv-)?glow[[:space:]]*:[[:space:]]*)#[A-Fa-f0-9]{3,6}/\1${COLOR}/g" \
        "$f"

    echo "Updated: $f (backup saved as $f.bak)"
done

echo "Done."
echo "If anything looks wrong, restore from the .bak files."
