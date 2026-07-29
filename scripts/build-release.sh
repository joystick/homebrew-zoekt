#!/usr/bin/env bash
# Build prebuilt macOS zoekt binaries, optionally codesign + notarize them,
# then publish a GitHub release + (manually) update the formula.
#
# Usage:
#   VER=0.0.$(date +%Y%m%d) ./scripts/build-release.sh
#
# Signing / notarization (optional but recommended for distribution):
#   Requires a paid Apple Developer Program membership with a
#   "Developer ID Application" certificate in your login keychain, plus a
#   stored notarytool credential profile:
#
#     xcrun notarytool store-credentials zoekt-notary \
#       --apple-id you@example.com --team-id ABCDE12345 \
#       --password <app-specific-password>
#
#   Then export before running:
#     export SIGN_ID="Developer ID Application: Your Name (ABCDE12345)"
#     export NOTARY_PROFILE="zoekt-notary"
#
#   If SIGN_ID is unset the script builds unsigned binaries (fine for local use,
#   but other Macs may quarantine them). If SIGN_ID is set but NOTARY_PROFILE is
#   not, binaries are signed but not notarized.
set -euo pipefail

VER="${VER:-0.0.$(date +%Y%m%d)}"
REPO="joystick/zoekt"
SIGN_ID="${SIGN_ID:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"
WORK="$(mktemp -d)"
DIST="$(pwd)/dist"
mkdir -p "$DIST"

# ---- preflight -------------------------------------------------------------
if [[ -n "$SIGN_ID" ]]; then
  if ! security find-identity -v -p codesigning | grep -qF "$SIGN_ID"; then
    echo "!! SIGN_ID '$SIGN_ID' not found in keychain codesigning identities." >&2
    exit 1
  fi
  case "$SIGN_ID" in
    "Developer ID Application"*) : ;;
    *) echo "!! Warning: notarization requires a 'Developer ID Application'" >&2
       echo "!! certificate. '$SIGN_ID' will be rejected by the notary service." >&2 ;;
  esac
else
  echo ">> SIGN_ID unset — producing UNSIGNED binaries."
fi

# ---- build -----------------------------------------------------------------
echo ">> cloning sourcegraph/zoekt"
git clone --depth 1 https://github.com/sourcegraph/zoekt.git "$WORK/src"

for ARCH in amd64 arm64; do
  OUT="$DIST/zoekt-$VER-darwin-$ARCH/bin"
  mkdir -p "$OUT"
  echo ">> building darwin/$ARCH"
  ( cd "$WORK/src" && CGO_ENABLED=0 GOOS=darwin GOARCH="$ARCH" \
      go build -trimpath -ldflags "-s -w" -o "$OUT" ./cmd/... )

  # ---- codesign ----------------------------------------------------------
  if [[ -n "$SIGN_ID" ]]; then
    echo ">> codesigning darwin/$ARCH binaries (hardened runtime)"
    for f in "$OUT"/*; do
      codesign --force --sign "$SIGN_ID" \
        --options runtime --timestamp \
        "$f"
    done
    codesign --verify --strict --verbose=1 "$OUT"/zoekt
  fi

  # ---- notarize ----------------------------------------------------------
  # Bare CLI executables cannot be stapled (stapling only works on .app/.pkg/.dmg),
  # so we submit a zip of the signed binaries. Notarization registers the
  # signatures with Apple; Gatekeeper then validates them via an online check.
  if [[ -n "$SIGN_ID" && -n "$NOTARY_PROFILE" ]]; then
    ZIP="$WORK/zoekt-$VER-darwin-$ARCH-notarize.zip"
    ( cd "$OUT" && /usr/bin/zip -q -r "$ZIP" . )
    echo ">> submitting darwin/$ARCH to notary service (this can take minutes)"
    xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
  fi

  ( cd "$DIST" && tar -czf "zoekt-$VER-darwin-$ARCH.tar.gz" "zoekt-$VER-darwin-$ARCH/bin" )
done

echo ">> checksums"
( cd "$DIST" && shasum -a 256 zoekt-$VER-darwin-*.tar.gz )

echo ">> creating GitHub release v$VER"
gh release create "v$VER" --repo "$REPO" --title "zoekt $VER" \
  --notes "Prebuilt macOS binaries of sourcegraph/zoekt built with $(go version | awk '{print $3}')." \
  "$DIST/zoekt-$VER-darwin-amd64.tar.gz" "$DIST/zoekt-$VER-darwin-arm64.tar.gz"

echo ">> now update Formula/zoekt.rb: version + both sha256 values, then commit & push"
