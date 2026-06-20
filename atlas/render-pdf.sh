#!/usr/bin/env bash
# render-pdf.sh — render an Atlas report HTML to a print-perfect PDF via Chrome.
#
# WHY CHROME: the report is a full-bleed dark, page-mapped document. Chrome's
# print engine renders it exactly as designed — 8 clean pages, dark to every
# trim edge, crisp badge dot. Safari's "Save as PDF" imposes its own print
# margins (even with @page margin:0), which mis-paginates the page-sheets
# (blank pages) and leaves white strips. So the *deliverable* PDF is always
# generated here, with Chrome. The HTML still views perfectly in Safari.
#
# Usage:  ./render-pdf.sh <report.html> [output.pdf]
#         (output defaults to the html path with a .pdf extension)
set -euo pipefail

SRC="${1:?usage: render-pdf.sh <report.html> [output.pdf]}"
OUT="${2:-${SRC%.html}.pdf}"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
  CHROME="$(command -v google-chrome 2>/dev/null || command -v chromium 2>/dev/null || true)"
fi
[ -n "$CHROME" ] || { echo "Error: Google Chrome not found. Install Chrome to export the PDF."; exit 1; }
[ -f "$SRC" ] || { echo "Error: report not found: $SRC"; exit 1; }

ABS="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
rm -f "$OUT"
"$CHROME" --headless=new --disable-gpu --no-sandbox --virtual-time-budget=4000 \
  --print-to-pdf="$OUT" --no-pdf-header-footer "file://$ABS" >/dev/null 2>&1 || true

if [ -f "$OUT" ]; then
  pages="$(strings "$OUT" 2>/dev/null | grep -c '/Type /Page$' || echo '?')"
  echo "Wrote $OUT (${pages} pages)"
else
  echo "Error: render failed (Chrome produced no PDF)."; exit 1
fi
