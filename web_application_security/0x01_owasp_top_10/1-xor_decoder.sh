#!/usr/bin/env bash
# 1-xor_decoder.sh
# Usage: ./1-xor_decoder.sh "{xor}Base64Payload"

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 '{xor}Base64Payload'" >&2
  exit 1
fi

input="$1"
# remove optional {xor} prefix
b64="${input#\{xor\}}"

python3 <<PY
import sys, base64

b64 = sys.argv[1] if len(sys.argv) > 1 else "$b64"

try:
    data = base64.b64decode(b64)
except Exception:
    sys.stderr.write('Invalid base64 payload\n')
    sys.exit(2)

KEY = 0x5f
out = bytes([c ^ KEY for c in data])
sys.stdout.buffer.write(out)
PY "$b64"

