#!/usr/bin/env bash
# Build prebuilt macOS zoekt binaries and publish a GitHub release + update the formula.
# Usage: VER=0.0.$(date +%Y%m%d) ./scripts/build-release.sh
set -euo pipefail

VER="${VER:-0.0.$(date +%Y%m%d)}"
REPO="joystick/homebrew-zoekt"
WORK="$(mktemp -d)"
DIST="$(pwd)/dist"
mkdir -p "$DIST"

echo ">> cloning sourcegraph/zoekt"
git clone --depth 1 https://github.com/sourcegraph/zoekt.git "$WORK/src"

for ARCH in amd64 arm64; do
  OUT="$DIST/zoekt-$VER-darwin-$ARCH/bin"
  mkdir -p "$OUT"
  echo ">> building darwin/$ARCH"
  ( cd "$WORK/src" && CGO_ENABLED=0 GOOS=darwin GOARCH="$ARCH" \
      go build -trimpath -ldflags "-s -w" -o "$OUT" ./cmd/... )
  ( cd "$DIST" && tar -czf "zoekt-$VER-darwin-$ARCH.tar.gz" "zoekt-$VER-darwin-$ARCH/bin" )
done

echo ">> checksums"
( cd "$DIST" && shasum -a 256 zoekt-$VER-darwin-*.tar.gz )

echo ">> creating GitHub release v$VER"
gh release create "v$VER" --repo "$REPO" --title "zoekt $VER" \
  --notes "Prebuilt macOS binaries of sourcegraph/zoekt built with $(go version | awk '{print $3}')." \
  "$DIST/zoekt-$VER-darwin-amd64.tar.gz" "$DIST/zoekt-$VER-darwin-arm64.tar.gz"

echo ">> now update Formula/zoekt.rb: version + both sha256 values, then commit & push"
