#!/usr/bin/env bash
# Regression test for the DotCMSAPI.JSON custom scalar.
#
# Guards the SIGABRT (swift_dynamicCastFailure in DataDict.subscript) that hit
# every blog detail load once a value came from Apollo's normalized cache.
# Cause: overriding _asAnyHashable to return the raw value made DataDict store a
# bare Dictionary, which its force cast `_data[key] as! T` could not read back.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK="$(mktemp -d)"; trap 'rm -rf "${WORK}"' EXIT
mkdir -p "${WORK}/Sources"
cp Sources/Generated/Schema/Schema/CustomScalars/JSON.swift "${WORK}/Sources/"
cp Tests/ScalarRoundTripTests.swift "${WORK}/Sources/main.swift"
cp Tests/blog-body-fixture.json "${WORK}/"
cat > "${WORK}/Sources/ns.swift" <<'NS'
import ApolloAPI
enum DotCMSAPI {}
NS
cat > "${WORK}/Package.swift" <<'PKG'
// swift-tools-version:5.9
import PackageDescription
let package = Package(
  name: "scalartest", platforms: [.macOS(.v13)],
  dependencies: [.package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.9.0")],
  targets: [.executableTarget(name: "scalartest",
    dependencies: [.product(name: "ApolloAPI", package: "apollo-ios")], path: "Sources")])
PKG

( cd "${WORK}" && swift run scalartest )
