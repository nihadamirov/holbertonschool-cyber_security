#!/bin/bash

# Simple Wayback Machine OSINT Script
# Finds Sr. Software Engineer at Microsoft from holbertonschool.com (Feb 2016)

TARGET="holbertonschool.com"
OUTPUT_FILE="3-senior.txt"

echo "=========================================="
echo "Wayback Machine OSINT Solver"
echo "=========================================="
echo "Target: $TARGET (February 2016)"
echo ""

# Step 1: Get snapshot URL
echo "[+] Step 1: Finding February 2016 snapshot..."
echo ""

# Use Wayback Machine API to find snapshots
echo "Querying Wayback Machine API..."
SNAPSHOTS=$(curl -s "http://web.archive.org/cdx/search/cdx?url=${TARGET}&from=20160201&to=20160229&output=json&fl=timestamp" | grep -o '"[0-9]\{14\}"' | tr -d '"' | head -10)

if [ -z "$SNAPSHOTS" ]; then
    echo "No snapshots found in February 2016, trying nearby months..."
    SNAPSHOTS=$(curl -s "http://web.archive.org/cdx/search/cdx?url=${TARGET}&from=20160101&to=20160331&output=json&fl=timestamp" | grep -o '"[0-9]\{14\}"' | tr -d '"' | head -10)
fi

echo "Found snapshots:"
echo "$SNAPSHOTS"
echo ""

# Get the first snapshot
FIRST_SNAPSHOT=$(echo "$SNAPSHOTS" | head -1)

if [ -z "$FIRST_SNAPSHOT" ]; then
    echo "[!] Error: Could not find any snapshots"
    echo ""
    echo "Please visit manually:"
    echo "https://web.archive.org/web/2016*/holbertonschool.com"
    exit 1
fi

WAYBACK_URL="https://web.archive.org/web/${FIRST_SNAPSHOT}/https://www.${TARGET}"

echo "[+] Snapshot URL: $WAYBACK_URL"
echo ""

# Step 2: Download the snapshot
echo "[+] Step 2: Downloading snapshot..."
curl -s "$WAYBACK_URL" > snapshot.html

if [ ! -s snapshot.html ]; then
    echo "[!] Failed to download snapshot"
    echo "Please visit manually: $WAYBACK_URL"
    exit 1
fi

echo "Downloaded $(wc -c < snapshot.html) bytes"
echo ""

# Step 3: Search for the target information
echo "[+] Step 3: Searching for 'Sr. Software Engineer at Microsoft'..."
echo ""

# Search for Microsoft and Sr./Senior Software Engineer
echo "=== Pattern 1: Direct search ==="
grep -i "microsoft" snapshot.html | grep -i "sr\|senior" | grep -i "software" | grep -i "engineer" | head -5
echo ""

echo "=== Pattern 2: Extracting names near Microsoft ==="
# Extract text around Microsoft mentions
grep -i "microsoft" snapshot.html -B 5 -A 5 | grep -oE "[A-Z][a-z]+ [A-Z][a-z]+" | sort -u
echo ""

echo "=== Pattern 3: Looking for team/staff sections ==="
grep -i "team\|staff\|mentor\|advisor" snapshot.html | grep -i "microsoft" -B 3 -A 3 | head -10
echo ""

# Try to extract the name automatically
echo "[+] Step 4: Attempting automatic extraction..."
NAME=$(grep -i "microsoft" snapshot.html | grep -iE "sr\.?\s+software\s+engineer|senior\s+software\s+engineer" | grep -oE "[A-Z][a-z]+ [A-Z][a-z]+" | head -1)

if [ ! -z "$NAME" ]; then
    echo ""
    echo "=========================================="
    echo "FOUND: $NAME"
    echo "=========================================="
    echo ""
    echo "Saving to $OUTPUT_FILE..."
    echo "$NAME" > "$OUTPUT_FILE"
    echo "Done!"
else
    echo ""
    echo "=========================================="
    echo "MANUAL REVIEW NEEDED"
    echo "=========================================="
    echo ""
    echo "Could not automatically extract the name."
    echo ""
    echo "Please:"
    echo "  1. Open the saved file: snapshot.html"
    echo "  2. Or visit: $WAYBACK_URL"
    echo "  3. Search for 'Microsoft' on the page"
    echo "  4. Find the person listed as 'Sr. Software Engineer at Microsoft'"
    echo "  5. Save the name:"
    echo "     echo 'FirstName LastName' > $OUTPUT_FILE"
    echo ""
    echo "Tip: Look in the team/staff/about section of the page"
fi
