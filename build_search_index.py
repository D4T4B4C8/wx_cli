#!/usr/bin/env python3
"""
build_search_index.py

Regenerates the embedded search index (the `const INDEX = [...]` array)
inside sch.html by scanning every .html page in a folder (and its
subfolders).

HOW IT WORKS
------------
For every *.html file found (except sch.html itself) it extracts:
  - path     -> file path relative to the scanned folder (forward slashes)
  - title    -> text of the first <h1> on the page, or the <title> tag
                if there is no <h1>
  - category -> the name of the immediate subfolder the file lives in,
                or the scanned folder's own name if the file sits at
                the top level (this matches how your existing pages
                are organized, e.g. cli/find.html -> category "cli",
                cli/editors/pluma396.html -> category "editors")
  - text     -> all the visible text on the page (script/style/title
                content stripped out), collapsed to single spaces

It then finds the `const INDEX = [ ... ];` block inside sch.html and
swaps in the freshly-built array, leaving the rest of sch.html
(styling, search logic, etc.) completely untouched.

USAGE
-----
1. Drop this script in the SAME folder as sch.html (the folder that
   contains find.html, editors/, adaptor/, etc. -- e.g. your "cli"
   folder).
2. Whenever you add/edit/remove a tool page, just run:

       python3 build_search_index.py

   That's it -- sch.html's search index is rebuilt in place.

You can also point it at a different folder / file explicitly:

       python3 build_search_index.py /path/to/cli --output /path/to/cli/sch.html

"""

import argparse
import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path


class PageParser(HTMLParser):
    """Pulls h1 text, <title> text, and all visible body text out of one HTML page."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.skip_stack = []          # stack of tags whose text we must ignore
        self.h1_text = []
        self.title_text = []
        self.body_text = []
        self._in_h1 = False
        self._h1_done = False         # only capture the FIRST h1
        self._in_title = False
        self._title_done = False      # only capture the FIRST title

    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag in ("script", "style"):
            self.skip_stack.append(tag)
        elif tag == "h1" and not self._h1_done:
            self._in_h1 = True
        elif tag == "title" and not self._title_done:
            self._in_title = True

    def handle_startendtag(self, tag, attrs):
        # self-closing tags like <br/> carry no text, nothing to do
        pass

    def handle_endtag(self, tag):
        tag = tag.lower()
        if tag in ("script", "style"):
            if self.skip_stack and self.skip_stack[-1] == tag:
                self.skip_stack.pop()
        elif tag == "h1" and self._in_h1:
            self._in_h1 = False
            self._h1_done = True
        elif tag == "title" and self._in_title:
            self._in_title = False
            self._title_done = True

    def handle_data(self, data):
        if self.skip_stack:
            return  # inside <script> or <style>, ignore

        if self._in_title:
            self.title_text.append(data)
            return  # title text is never part of the visible body text

        if self._in_h1:
            self.h1_text.append(data)

        # everything not inside script/style/title counts as visible page text
        self.body_text.append(data)

    def result(self):
        h1 = normalize_ws("".join(self.h1_text))
        title_tag = normalize_ws("".join(self.title_text))
        title = h1 if h1 else title_tag
        text = normalize_ws("".join(self.body_text))
        return title, text


# Decorative/background pages that live alongside your content pages but
# aren't real "tool" pages -- they should never show up as search results.
# Add any other filenames here (case-insensitive, just the filename, not
# the full path) if you create more standalone background/effect pages.
EXCLUDED_FILENAMES = {
    "hyperspeed.html",
    "hyperspeed_standalone.html",
}


def normalize_ws(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def build_entry(html_path: Path, base_dir: Path):
    raw = html_path.read_text(encoding="utf-8", errors="replace")
    parser = PageParser()
    parser.feed(raw)
    title, text = parser.result()

    rel = html_path.relative_to(base_dir)
    rel_parts = rel.parts
    path = "/".join(rel_parts)

    if len(rel_parts) > 1:
        category = rel_parts[0]           # file is inside a subfolder
    else:
        category = base_dir.name          # file sits at the top level

    if not title:
        title = html_path.stem

    return {"path": path, "title": title, "category": category, "text": text}


def collect_entries(base_dir: Path, output_file: Path):
    entries = []
    for html_path in sorted(base_dir.rglob("*.html")):
        if html_path.resolve() == output_file.resolve():
            continue  # never index the search page itself
        if html_path.name.lower() in EXCLUDED_FILENAMES:
            continue  # never index decorative/background pages
        entries.append(build_entry(html_path, base_dir))
    return entries


def inject_index(sch_html_text: str, entries: list) -> str:
    marker = "const INDEX = "
    start = sch_html_text.find(marker)
    if start == -1:
        raise ValueError(
            "Could not find 'const INDEX = [...]' in the target file. "
            "Is this really the sch.html search-index file?"
        )

    array_start = sch_html_text.index("[", start)

    # walk forward tracking bracket depth, respecting quoted strings, to find
    # the matching closing bracket for the INDEX array (handles any [ ] that
    # might appear inside page text/titles).
    depth = 0
    i = array_start
    in_string = False
    string_char = ""
    escaped = False
    n = len(sch_html_text)
    while i < n:
        ch = sch_html_text[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == string_char:
                in_string = False
        else:
            if ch in ("'", '"'):
                in_string = True
                string_char = ch
            elif ch == "[":
                depth += 1
            elif ch == "]":
                depth -= 1
                if depth == 0:
                    array_end = i + 1
                    break
        i += 1
    else:
        raise ValueError("Could not find the end of the INDEX array (unbalanced brackets).")

    new_array = json.dumps(entries, ensure_ascii=False)
    return sch_html_text[:array_start] + new_array + sch_html_text[array_end:]


def main():
    ap = argparse.ArgumentParser(description="Rebuild sch.html's embedded search index.")
    ap.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Folder to scan for .html pages (default: current folder)",
    )
    ap.add_argument(
        "--output",
        default=None,
        help="Path to sch.html to update (default: sch.html inside DIRECTORY)",
    )
    args = ap.parse_args()

    base_dir = Path(args.directory).resolve()
    if not base_dir.is_dir():
        sys.exit(f"Error: '{base_dir}' is not a folder.")

    output_file = Path(args.output).resolve() if args.output else base_dir / "sch.html"
    if not output_file.is_file():
        sys.exit(f"Error: could not find '{output_file}'.")

    entries = collect_entries(base_dir, output_file)

    original = output_file.read_text(encoding="utf-8", errors="replace")
    updated = inject_index(original, entries)
    output_file.write_text(updated, encoding="utf-8")

    print(f"Indexed {len(entries)} page(s) from '{base_dir}'.")
    print(f"Updated '{output_file}'.")


if __name__ == "__main__":
    main()
