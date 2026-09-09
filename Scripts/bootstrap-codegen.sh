#!/usr/bin/env bash
# Build the Apollo codegen CLI from source and run codegen.
# The CLI binary itself is gitignored; this script reproduces it.
set -euo pipefail
cd "$(dirname "$0")/.."

CLI="Scripts/apollo-ios-cli"
if [[ ! -x "${CLI}" ]]; then
  echo "==> Building apollo-ios-cli (first run only)"
  WORK="$(mktemp -d)"; trap 'rm -rf "${WORK}"' EXIT
  cat > "${WORK}/Package.swift" <<'PKG'
// swift-tools-version:5.9
import PackageDescription
let package = Package(
  name: "codegen", platforms: [.macOS(.v13)],
  dependencies: [.package(url: "https://github.com/apollographql/apollo-ios-codegen.git", from: "1.9.0")],
  targets: [.executableTarget(name: "codegen", dependencies: [])])
PKG
  mkdir -p "${WORK}/Sources/codegen"
  echo 'print("")' > "${WORK}/Sources/codegen/main.swift"
  ( cd "${WORK}" && swift build -c release --product apollo-ios-cli )
  cp "${WORK}"/.build/release/apollo-ios-cli "${CLI}"
fi

echo "==> Generating models from the COMMITTED schema"
"${CLI}" generate --path apollo-codegen-config.json
echo "==> Codegen complete"
