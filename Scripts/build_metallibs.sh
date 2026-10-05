#!/usr/bin/env bash
# Compiles Sources/Aurora/AuroraGlow.metal into the metallibs the package ships. Command-line SwiftPM
# (`swift build`) can't compile Metal, so Aurora carries them prebuilt for every platform it supports.
# Run this after every change to the shader, and commit the output.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=Sources/Aurora/AuroraGlow.metal
OUT=Sources/Aurora/Metallibs
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

build() {  # sdk, library name, deployment target flag
  xcrun -sdk "$1" metal -c "$SRC" "$3" -o "$TMP/$2.air"
  xcrun -sdk "$1" metallib "$TMP/$2.air" -o "$OUT/$2.metallib"
  echo "$OUT/$2.metallib"
}

build macosx AuroraMacOS -mmacosx-version-min=14.0
build iphoneos AuroraiOS -mios-version-min=17.0
build iphonesimulator AuroraiOSSimulator -mios-simulator-version-min=17.0
