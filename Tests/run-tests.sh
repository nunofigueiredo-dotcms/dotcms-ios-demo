#!/usr/bin/env bash
# Runs every test. No Xcode required — swiftc only.
#
#   ./Tests/run-tests.sh
set -euo pipefail
cd "$(dirname "$0")/.."

FAILED=0

echo "### StoryBlock parser"
if ./Tests/run-storyblock-tests.sh; then echo "  PASS"; else echo "  FAIL"; FAILED=1; fi

echo
echo "### Nullability degradation"
WORK="$(mktemp -d)"; trap 'rm -rf "${WORK}"' EXIT
cp Sources/Models/Contentlet.swift Sources/Models/StoryBlock.swift "${WORK}/"
cp Tests/NullabilityTests.swift "${WORK}/main.swift"
if ( cd "${WORK}" && swiftc -O Contentlet.swift StoryBlock.swift main.swift -o run && ./run ); then
  echo "  PASS"
else
  echo "  FAIL"; FAILED=1
fi

echo
if [[ ${FAILED} -eq 0 ]]; then echo "All tests passed."; else echo "TESTS FAILED."; exit 1; fi
