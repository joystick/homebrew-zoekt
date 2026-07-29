# homebrew-zoekt

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

See [`../BUILD.md`](../BUILD.md) for the cross-compile + release steps.
