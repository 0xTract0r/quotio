# Build & Release Scripts

12 bash scripts for building, packaging, notarizing, releasing, and runtime verification.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./scripts/build.sh` | Build release archive |
| `./scripts/package.sh` | Create ZIP + DMG |
| `./scripts/notarize.sh` | Apple notarization |
| `./scripts/release.sh` | Full release pipeline |
| `./scripts/quick-release.sh` | Interactive release helper |
| `./scripts/bump-version.sh` | Version management |
| `./scripts/verify-runtime-isolation.sh` | Launch isolated Debug app and verify log/cpu regression fixes |

## Build Pipeline

```
build.sh → package.sh → notarize.sh → generate-appcast.sh
    ↓          ↓            ↓               ↓
 .xcarchive   ZIP+DMG    Stapled        appcast.xml
```

## Scripts

### build.sh
Creates Xcode archive with ad-hoc signing.
```bash
./scripts/build.sh
# Output: build/Quotio.app, build/Quotio.xcarchive
```

### package.sh
Creates distributable packages.
```bash
./scripts/package.sh
# Output: build/Quotio.zip, build/Quotio.dmg
```
- Uses `ditto` for ZIP (preserves attributes)
- Uses `create-dmg` for DMG with custom layout

### notarize.sh
Submits to Apple for notarization.
```bash
./scripts/notarize.sh
# Requires: APPLE_ID, TEAM_ID, APP_PASSWORD env vars
```
- Graceful skip if credentials missing
- Waits for approval, staples ticket

### release.sh
Full automated release.
```bash
./scripts/release.sh [version]
# Runs: bump → build → package → notarize → appcast
```

### quick-release.sh
Interactive release with prompts.
```bash
./scripts/quick-release.sh
# Prompts for version, confirms each step
```

### bump-version.sh
Updates version in Xcode project.
```bash
./scripts/bump-version.sh 1.2.3
# Updates: MARKETING_VERSION, CURRENT_PROJECT_VERSION
```

### generate-appcast.sh / generate-appcast-ci.sh
Generates Sparkle update manifest.
```bash
./scripts/generate-appcast.sh
# Output: appcast.xml with EdDSA signatures
```
- CI version merges prerelease with stable
- Downloads Sparkle tools if missing

### update-changelog.sh
Moves unreleased entries to versioned section.
```bash
./scripts/update-changelog.sh 1.2.3
```

### verify-runtime-isolation.sh
Starts an isolated Debug Quotio instance under `/tmp`, copies the current production `CLIProxyAPI`
binary into the isolated runtime, enables management log capture, and verifies that:
- `/v0/management/debug` no longer emits recurring `401`
- `/v0/management/logs` no longer self-polls while idle
- idle CPU stays near zero for both Quotio and the isolated core

```bash
./scripts/verify-runtime-isolation.sh
# Output: /tmp/quotio-runtime-verify/summary.txt
```

Common overrides:
```bash
QUOTIO_VERIFY_UI_SMOKE=0 ./scripts/verify-runtime-isolation.sh
QUOTIO_VERIFY_PORT=18127 ./scripts/verify-runtime-isolation.sh
QUOTIO_VERIFY_RUNTIME_DIR=/tmp/quotio-runtime-verify-alt ./scripts/verify-runtime-isolation.sh
```

Notes:
- The script never touches production `18317/28317`; default isolated ports are `18027/28027`
- If Accessibility permission is unavailable, the UI smoke step is skipped automatically and the script falls back to read-only verification
- The isolated runtime directory is kept by default for post-run inspection; set `QUOTIO_VERIFY_KEEP_RUNTIME=0` to auto-clean it

### config.sh
Shared utilities (sourced by other scripts).
- Colorized output functions
- Progress spinners
- Timing utilities
- Error handling

## CI/CD (GitHub Actions)

### release.yml
Triggered by: `v*` tag push or manual dispatch.
```yaml
# Runs on: macOS 15, Xcode 26.1
# Artifacts: DMG, ZIP, appcast.xml → GitHub Releases
```

### changelog-unreleased.yml
Auto-updates CHANGELOG.md from conventional commits on master.

## Environment Variables

| Variable | Required For | Purpose |
|----------|--------------|---------|
| `APPLE_ID` | notarize.sh | Apple Developer email |
| `TEAM_ID` | notarize.sh | Apple Team ID |
| `APP_PASSWORD` | notarize.sh | App-specific password |
| `SPARKLE_KEY` | appcast | EdDSA private key path |
| `QUOTIO_VERIFY_PORT` | verify-runtime-isolation.sh | Isolated client-facing proxy port; internal port is `+10000` |
| `QUOTIO_VERIFY_RUNTIME_DIR` | verify-runtime-isolation.sh | Isolated runtime root under `/tmp` |
| `QUOTIO_VERIFY_WAIT_SECONDS` | verify-runtime-isolation.sh | Idle observation window before collecting log evidence |
| `QUOTIO_VERIFY_UI_SMOKE` | verify-runtime-isolation.sh | Set to `0` to skip the Accessibility-driven Logs screen smoke step |
| `QUOTIO_VERIFY_KEEP_RUNTIME` | verify-runtime-isolation.sh | Set to `0` to remove the isolated runtime directory on exit |

## Conventions

- All scripts use `set -e` (exit on error)
- Source `config.sh` for shared utilities
- Use colored output for visibility
- Measure and report execution time
- Support both local and CI execution
