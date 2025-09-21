#!/usr/bin/env bash
# 1-xor_decoder.sh
# Usage: ./1-xor_decoder.sh "{xor}KzosKw=="
# This script decodes IBM WebSphere XOR-obfuscated strings. Behaviour:
# - Accepts an argument which may include the {xor} prefix
# - Base64-decodes the payload
# - XORs each resulting byte with 0x5f (95 decimal) to recover plaintext
# Example:
# ./1-xor_decoder.sh '{xor}KzosKw==' -> prints: test


set -euo pipefail
if [ "$#" -ne 1 ]; then
echo "Usage: $0 '{xor}Base64Payload'" >&2
exit 1
fi


input="$1"
# remove optional {xor} prefix (works whether prefix present or not)
b64="${input#\{xor\}}"


# ensure base64 is valid and decode + xor using Python for portability
python3 - <<'PY' -- "$b64"
import sys, base64
b64 = sys.argv[1]
try:
data = base64.b64decode(b64)
except Exception:
sys.stderr.write('Invalid base64 payload\n')
sys.exit(2)


# XOR key used by this WebSphere encoding
KEY = 0x5f
out = bytes([c ^ KEY for c in data])
# print without extra newline manipulation (stdout will show plaintext)
sys.stdout.buffer.write(out)
PY
