#!/usr/bin/env bash
# Build, install and launch the app on the simulator with the API token
# supplied from the environment.
#
#   DOTCMS_AUTH_TOKEN=... ./Scripts/run-simulator.sh [device-name]
#
# Use this when Xcode's Run does not have the token in its environment.
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${1:-iPhone 17}"
BUNDLE_ID="com.dotcms.demo.ios"
DD="${DERIVED_DATA:-build/DerivedData}"

if [[ -z "${DOTCMS_AUTH_TOKEN:-}" ]]; then
  echo "error: DOTCMS_AUTH_TOKEN is not set." >&2
  echo "       export DOTCMS_AUTH_TOKEN=... then re-run." >&2
  exit 2
fi

echo "==> Building"
xcodebuild -project DotCMSDemo.xcodeproj -scheme DotCMSDemo \
  -destination "platform=iOS Simulator,name=${DEVICE}" \
  -derivedDataPath "${DD}" build >/dev/null

APP="${DD}/Build/Products/Debug-iphonesimulator/DotCMSDemo.app"

echo "==> Booting ${DEVICE}"
xcrun simctl boot "${DEVICE}" 2>/dev/null || true
xcrun simctl bootstatus "${DEVICE}" -b >/dev/null 2>&1 || true
open -a Simulator

echo "==> Installing"
xcrun simctl install "${DEVICE}" "${APP}"

echo "==> Launching with token from environment"
xcrun simctl terminate "${DEVICE}" "${BUNDLE_ID}" 2>/dev/null || true
SIMCTL_CHILD_DOTCMS_AUTH_TOKEN="${DOTCMS_AUTH_TOKEN}" \
  xcrun simctl launch "${DEVICE}" "${BUNDLE_ID}"

echo "==> Running. The token is now stored in the simulator Keychain,"
echo "    so later launches from Xcode work without the variable."
