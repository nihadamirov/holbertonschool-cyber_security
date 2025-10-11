#!/bin/bash

TARGET="http://web0x04.hbtn"
OUTPUT_FILE="0-flag.txt"

echo "=== Content Discovery Challenge Solver ==="
echo "Target: $TARGET"
echo ""

# Step 1: Check robots.txt
echo "[+] Step 1: Checking robots.txt..."
curl -s "$TARGET/robots.txt" | tee robots_output.txt
echo ""

# Step 2: Check sitemap.xml
echo "[+] Step 2: Checking sitemap.xml..."
curl -s "$TARGET/sitemap.xml" | tee sitemap_output.txt
echo ""

# Extract URLs from sitemap
echo "[+] Extracting URLs from sitemap..."
grep -oP '(?<=<loc>)[^<]+' sitemap_output.txt | tee urls.txt
echo ""

# Step 3: Download and analyze favicon
echo "[+] Step 3: Downloading favicon.ico..."
curl -s "$TARGET/favicon.ico" -o favicon.ico
if [ -f favicon.ico ]; then
    echo "Favicon downloaded successfully"
    echo "MD5 Hash: $(md5sum favicon.ico | awk '{print $1}')"
else
    echo "Failed to download favicon"
fi
echo ""

# Step 4: Visit each URL from sitemap to find the flag
echo "[+] Step 4: Checking each URL for flags..."
while IFS= read -r url; do
    echo "Checking: $url"
    response=$(curl -s "$url")
    
    # Look for common flag patterns
    if echo "$response" | grep -qiE "(flag|FLAG|CTF|hbtn)"; then
        echo "  [!] Potential flag found at: $url"
        echo "$response"
        echo ""
        
        # Extract flag pattern (adjust regex based on expected format)
        flag=$(echo "$response" | grep -oE "flag\{[^}]+\}|FLAG\{[^}]+\}|HBTN\{[^}]+\}" | head -1)
        if [ ! -z "$flag" ]; then
            echo "$flag" > "$OUTPUT_FILE"
            echo "[SUCCESS] Flag saved to $OUTPUT_FILE: $flag"
            exit 0
        fi
    fi
done < urls.txt

# Step 5: Check paths from robots.txt
echo "[+] Step 5: Checking disallowed paths from robots.txt..."
grep "Disallow:" robots_output.txt | awk '{print $2}' | while read -r path; do
    if [ ! -z "$path" ]; then
        url="$TARGET$path"
        echo "Checking: $url"
        response=$(curl -s "$url")
        
        if echo "$response" | grep -qiE "(flag|FLAG|CTF|hbtn)"; then
            echo "  [!] Potential flag found at: $url"
            echo "$response"
            
            flag=$(echo "$response" | grep -oE "flag\{[^}]+\}|FLAG\{[^}]+\}|HBTN\{[^}]+\}" | head -1)
            if [ ! -z "$flag" ]; then
                echo "$flag" > "$OUTPUT_FILE"
                echo "[SUCCESS] Flag saved to $OUTPUT_FILE: $flag"
                exit 0
            fi
        fi
    fi
done

echo ""
echo "[+] Discovery complete. Check the output files for more details."
echo "    - robots_output.txt"
echo "    - sitemap_output.txt"
echo "    - urls.txt"
echo "    - favicon.ico"

