# homebrew-zoekt

[![brew install](https://img.shields.io/badge/brew%20install-zoekt-orange?logo=homebrew&logoColor=white)](https://github.com/joystick/homebrew-zoekt)
[![release](https://img.shields.io/github/v/release/joystick/homebrew-zoekt?label=release)](https://github.com/joystick/homebrew-zoekt/releases/latest)
[![platform](https://img.shields.io/badge/platform-macOS%20(arm64%20%7C%20x86__64)-blue)](https://github.com/joystick/homebrew-zoekt/releases/latest)

Homebrew tap for [zoekt](https://github.com/sourcegraph/zoekt), the fast
trigram-based code search engine (Sourcegraph fork). Ships prebuilt macOS
binaries — no Go toolchain required.

## Install

```sh
brew tap joystick/zoekt
brew install zoekt
```

## What you get

All zoekt command-line tools are installed into your Homebrew `bin`, including:

- `zoekt` — search a compound index
- `zoekt-index`, `zoekt-git-index`, `zoekt-archive-index`, `zoekt-repo-index`
- `zoekt-webserver` — HTTP/JSON search server
- `zoekt-indexserver`, `zoekt-dynamic-indexserver`, `zoekt-sourcegraph-indexserver`
- `zoekt-git-clone`, `zoekt-merge-index`, `zoekt-test`
- `zoekt-mirror-{github,gitlab,gitea,gerrit,bitbucket-server,gitiles}`

## Versioning

Version `0.0.YYYYMMDD` reflects the build date of the upstream
`sourcegraph/zoekt` `main` branch (Sourcegraph does not publish release tags).

## Building the binaries yourself

Run [`scripts/build-release.sh`](scripts/build-release.sh) — it clones upstream,
cross-compiles both darwin architectures, optionally codesigns + notarizes,
packages tarballs, and publishes a GitHub release. Then bump `version` and the
two `sha256` values in `Formula/zoekt.rb` and push.

### Codesigning + notarization (optional)

Requires a paid Apple Developer Program membership with a **Developer ID
Application** certificate (an "Apple Development" cert will be rejected by the
notary service). First store notary credentials once:

```sh
xcrun notarytool store-credentials zoekt-notary \
  --apple-id you@example.com --team-id ABCDE12345 \
  --password <app-specific-password>
```

Then export before building:

```sh
export SIGN_ID="Developer ID Application: Your Name (ABCDE12345)"
export NOTARY_PROFILE="zoekt-notary"
VER=0.0.$(date +%Y%m%d) ./scripts/build-release.sh
```

- `SIGN_ID` unset → unsigned binaries (fine locally; other Macs may quarantine).
- `SIGN_ID` set, `NOTARY_PROFILE` unset → signed but not notarized.
- Both set → signed with hardened runtime + notarized.

Note: bare CLI executables cannot be *stapled* (stapling only applies to
`.app`/`.pkg`/`.dmg`), so the script submits a zip of the signed binaries;
Gatekeeper validates the registered signatures via an online check.
