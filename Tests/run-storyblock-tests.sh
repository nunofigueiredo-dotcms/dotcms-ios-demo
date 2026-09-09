#!/usr/bin/env bash
# Regression test for the StoryBlock parser against a real dotCMS body.
#
# Guards the bug where Apollo's default `typealias JSON = String` made the blog
# detail screen fail with `couldNotConvert(value: AnyHashable([...]))`, because
# dotCMS returns StoryBlock bodies as an OBJECT, not a string.
#
# Runs without Xcode: swiftc only.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK="$(mktemp -d)"; trap 'rm -rf "${WORK}"' EXIT
cp Sources/Models/StoryBlock.swift "${WORK}/"
cp Tests/blog-body-fixture.json "${WORK}/body_only.json"
cp Tests/StoryBlockTests.swift "${WORK}/main.swift"

( cd "${WORK}" && swiftc -O StoryBlock.swift main.swift -o run && ./run )
