#!/usr/bin/env bash
# Download the dotCMS GraphQL schema as SDL.
#   Scripts/download-schema.sh [output-path]
# Defaults to Schema/schema.graphqls
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:-Schema/schema.graphqls}"
CONFIG="${DOTCMS_CONFIG:-Config.plist}"
HOST="${DOTCMS_HOST:-$(/usr/libexec/PlistBuddy -c 'Print :DOTCMS_HOST' "$CONFIG" 2>/dev/null || true)}"

[[ -n "${HOST}" ]] || { echo "error: DOTCMS_HOST not set" >&2; exit 2; }
[[ -n "${DOTCMS_AUTH_TOKEN:-}" ]] || { echo "error: DOTCMS_AUTH_TOKEN not set" >&2; exit 2; }

mkdir -p "$(dirname "${OUT}")"
TMP="$(mktemp)"; trap 'rm -f "${TMP}"' EXIT

curl -sS -X POST "${HOST}/api/v1/graphql" \
  -H "Authorization: Bearer ${DOTCMS_AUTH_TOKEN}" \
  -H 'Content-Type: application/json' \
  --data-binary @Scripts/introspection.json \
  -o "${TMP}"

python3 Scripts/introspection_to_sdl.py "${TMP}" > "${OUT}"
echo "==> wrote ${OUT} ($(wc -l < "${OUT}" | tr -d ' ') lines)"
