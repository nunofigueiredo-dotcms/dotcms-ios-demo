#!/usr/bin/env bash
# Re-download the live dotCMS GraphQL schema and diff it against the committed
# copy. Exits non-zero on ANY difference.
#
# This is the early-warning system for "someone edited a content type and the
# app broke". Run it before a demo, and in CI.
#
# Usage:
#   DOTCMS_AUTH_TOKEN=... ./Scripts/check-schema-drift.sh
set -euo pipefail

cd "$(dirname "$0")/.."

COMMITTED="Schema/schema.graphqls"
CONFIG="${DOTCMS_CONFIG:-Config.plist}"

read_plist() {
  /usr/libexec/PlistBuddy -c "Print :$1" "$CONFIG" 2>/dev/null || true
}

HOST="${DOTCMS_HOST:-$(read_plist DOTCMS_HOST)}"
if [[ -z "${HOST}" ]]; then
  echo "error: DOTCMS_HOST not set and not found in ${CONFIG}" >&2
  exit 2
fi
if [[ -z "${DOTCMS_AUTH_TOKEN:-}" ]]; then
  echo "error: DOTCMS_AUTH_TOKEN not set in the environment." >&2
  echo "       Never hardcode it; export it for this shell only." >&2
  exit 2
fi
if [[ ! -f "${COMMITTED}" ]]; then
  echo "error: ${COMMITTED} not found. Run Scripts/download-schema.sh first." >&2
  exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT
LIVE="${TMP}/live.graphqls"

echo "==> Downloading live schema from ${HOST}"
Scripts/download-schema.sh "${LIVE}"

if diff -u "${COMMITTED}" "${LIVE}" > "${TMP}/drift.diff"; then
  echo "==> OK: live schema matches ${COMMITTED}"
  exit 0
fi

echo ""
echo "!! SCHEMA DRIFT DETECTED"
echo "!! The live instance no longer matches the committed schema."
echo "!! A content type or field has changed. Generated models are stale."
echo ""
cat "${TMP}/drift.diff"
echo ""
echo "To accept these changes:"
echo "  1. Scripts/download-schema.sh ${COMMITTED}"
echo "  2. Re-run Apollo codegen"
echo "  3. Fix any compile errors the new schema surfaces"
echo "  4. Commit the updated schema alongside the code changes"
exit 1
