#!/usr/bin/env bash
# discovery-flags-2.sh
set -euo pipefail

TARGET="${1:-https://cod.hbtn.io}"
OUTDIR="output_$(date +%s)"
mkdir -p "$OUTDIR"

echo "[*] Target: $TARGET"
echo "[*] Output dir: $OUTDIR"

curl -sL "$TARGET" -o "$OUTDIR/index.html"

# Extract JS files
grep -oP '<script[^>]+src=["'\'']\K[^"'\'' ]+' "$OUTDIR/index.html" | while read -r src; do
  [[ "$src" =~ ^http ]] || src="$TARGET$src"
  echo "[*] Found script: $src"
  fname="$OUTDIR/$(basename "$src")"
  curl -sL "$src" -o "$fname" || echo "[!] Failed: $src"
done

FILES=$(find "$OUTDIR" -type f -name '*.js' -o -name 'index.html')

PATTERNS="ThemeForest|template|BootstrapMade|Start Bootstrap|HTML5 UP|preview|vendor|Designed by|Made by"
> "$OUTDIR/findings.txt"

for f in $FILES; do
  echo "---- $f ----" >> "$OUTDIR/findings.txt"
  grep -iEnC 2 "$PATTERNS" "$f" >> "$OUTDIR/findings.txt" 2>/dev/null || true
  grep -oP 'https?://[^\t\n \"'\''<>]+' "$f" | sort -u >> "$OUTDIR/findings.txt" || true
done

echo "[*] Search complete. Check $OUTDIR/findings.txt"

