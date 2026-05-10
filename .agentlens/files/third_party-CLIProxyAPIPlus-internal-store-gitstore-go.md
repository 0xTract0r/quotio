# third_party/CLIProxyAPIPlus/internal/store/gitstore.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1009
- **Language:** Go
- **Symbols:** 36
- **Public symbols:** 11

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 25 | const | gcInterval | (private) | - |
| 28 | struct | GitTokenStore | pub | - |
| 41 | struct | resolvedRemoteBranch | (private) | - |
| 49 | fn | NewGitTokenStore | pub | `func NewGitTokenStore(remote, username, passwor...` |
| 59 | fn | SetBaseDir | pub | `func (s *GitTokenStore) SetBaseDir(dir string) {` |
| 85 | fn | AuthDir | pub | `func (s *GitTokenStore) AuthDir() string {` |
| 90 | fn | ConfigPath | pub | `func (s *GitTokenStore) ConfigPath() string {` |
| 100 | fn | EnsureRepository | pub | `func (s *GitTokenStore) EnsureRepository() error {` |
| 258 | fn | Save | pub | `func (s *GitTokenStore) Save(_ context.Context,...` |
| 341 | fn | List | pub | `func (s *GitTokenStore) List(_ context.Context)...` |
| 376 | fn | Delete | pub | `func (s *GitTokenStore) Delete(_ context.Contex...` |
| 410 | fn | PersistAuthFiles | pub | `func (s *GitTokenStore) PersistAuthFiles(_ cont...` |
| 443 | fn | resolveDeletePath | (private) | `func (s *GitTokenStore) resolveDeletePath(id st...` |
| 454 | fn | readAuthFile | (private) | `func (s *GitTokenStore) readAuthFile(path, base...` |
| 495 | fn | idFor | (private) | `func (s *GitTokenStore) idFor(path, baseDir str...` |
| 506 | fn | resolveAuthPath | (private) | `func (s *GitTokenStore) resolveAuthPath(auth *c...` |
| 537 | fn | labelFor | (private) | `func (s *GitTokenStore) labelFor(metadata map[s...` |
| 553 | fn | baseDirSnapshot | (private) | `func (s *GitTokenStore) baseDirSnapshot() string {` |
| 559 | fn | repoDirSnapshot | (private) | `func (s *GitTokenStore) repoDirSnapshot() string {` |
| 565 | fn | gitAuth | (private) | `func (s *GitTokenStore) gitAuth() transport.Aut...` |
| 576 | fn | relativeToRepo | (private) | `func (s *GitTokenStore) relativeToRepo(path str...` |
| 599 | fn | checkoutConfiguredBranch | (private) | `func (s *GitTokenStore) checkoutConfiguredBranc...` |
| 622 | fn | checkoutConfiguredRemoteTrackingBranch | (private) | `func (s *GitTokenStore) checkoutConfiguredRemot...` |
| 653 | fn | syncRemoteReferences | (private) | `func syncRemoteReferences(repo *git.Repository,...` |
| 662 | fn | resolveRemoteDefaultBranch | (private) | `func resolveRemoteDefaultBranch(repo *git.Repos...` |
| 703 | fn | resolveRemoteDefaultBranchFromLocal | (private) | `func resolveRemoteDefaultBranchFromLocal(repo *...` |
| 715 | fn | normalizeRemoteBranchReference | (private) | `func normalizeRemoteBranchReference(name plumbi...` |
| 726 | fn | shouldFallbackToCurrentBranch | (private) | `func shouldFallbackToCurrentBranch(repo *git.Re...` |
| 737 | fn | checkoutRemoteDefaultBranch | (private) | `func checkoutRemoteDefaultBranch(repo *git.Repo...` |
| 785 | fn | commitAndPushLocked | (private) | `func (s *GitTokenStore) commitAndPushLocked(mes...` |
| 869 | fn | rewriteHeadAsSingleCommit | (private) | `func (s *GitTokenStore) rewriteHeadAsSingleComm...` |
| 898 | fn | maybeRunGC | (private) | `func (s *GitTokenStore) maybeRunGC(repo *git.Re...` |
| 916 | fn | PersistConfig | pub | `func (s *GitTokenStore) PersistConfig(_ context...` |
| 939 | fn | ensureEmptyFile | (private) | `func ensureEmptyFile(path string) error {` |
| 949 | fn | jsonEqual | (private) | `func jsonEqual(a, b []byte) bool {` |
| 961 | fn | deepEqualJSON | (private) | `func deepEqualJSON(a, b any) bool {` |

## Public API

### `NewGitTokenStore`

```
func NewGitTokenStore(remote, username, password, branch string) *GitTokenStore {
```

**Line:** 49 | **Kind:** fn

### `SetBaseDir`

```
func (s *GitTokenStore) SetBaseDir(dir string) {
```

**Line:** 59 | **Kind:** fn

### `AuthDir`

```
func (s *GitTokenStore) AuthDir() string {
```

**Line:** 85 | **Kind:** fn

### `ConfigPath`

```
func (s *GitTokenStore) ConfigPath() string {
```

**Line:** 90 | **Kind:** fn

### `EnsureRepository`

```
func (s *GitTokenStore) EnsureRepository() error {
```

**Line:** 100 | **Kind:** fn

### `Save`

```
func (s *GitTokenStore) Save(_ context.Context, auth *cliproxyauth.Auth) (string, error) {
```

**Line:** 258 | **Kind:** fn

### `List`

```
func (s *GitTokenStore) List(_ context.Context) ([]*cliproxyauth.Auth, error) {
```

**Line:** 341 | **Kind:** fn

### `Delete`

```
func (s *GitTokenStore) Delete(_ context.Context, id string) error {
```

**Line:** 376 | **Kind:** fn

### `PersistAuthFiles`

```
func (s *GitTokenStore) PersistAuthFiles(_ context.Context, message string, paths ...string) error {
```

**Line:** 410 | **Kind:** fn

### `PersistConfig`

```
func (s *GitTokenStore) PersistConfig(_ context.Context) error {
```

**Line:** 916 | **Kind:** fn

