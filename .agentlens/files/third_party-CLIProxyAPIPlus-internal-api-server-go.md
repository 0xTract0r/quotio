# third_party/CLIProxyAPIPlus/internal/api/server.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1191
- **Language:** Go
- **Symbols:** 33
- **Public symbols:** 15

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 46 | const | oauthCallbackSuccessHTML | (private) | - |
| 48 | struct | serverOptionConfig | (private) | - |
| 63 | fn | defaultRequestLoggerFactory | (private) | `func defaultRequestLoggerFactory(cfg *config.Co...` |
| 70 | fn | WithMiddleware | pub | `func WithMiddleware(mw ...gin.HandlerFunc) Serv...` |
| 77 | fn | WithEngineConfigurator | pub | `func WithEngineConfigurator(fn func(*gin.Engine...` |
| 84 | fn | WithRouterConfigurator | pub | `func WithRouterConfigurator(fn func(*gin.Engine...` |
| 91 | fn | WithLocalManagementPassword | pub | `func WithLocalManagementPassword(password strin...` |
| 98 | fn | WithKeepAliveEndpoint | pub | `func WithKeepAliveEndpoint(timeout time.Duratio...` |
| 110 | fn | WithRequestLoggerFactory | pub | `func WithRequestLoggerFactory(factory func(*con...` |
| 117 | fn | WithPostAuthHook | pub | `func WithPostAuthHook(hook auth.PostAuthHook) S...` |
| 125 | struct | Server | pub | - |
| 194 | fn | NewServer | pub | `func NewServer(cfg *config.Config, authManager ...` |
| 327 | fn | buildInfoHeadersMiddleware | (private) | `func buildInfoHeadersMiddleware() gin.HandlerFu...` |
| 338 | fn | setupRoutes | (private) | `func (s *Server) setupRoutes() {` |
| 514 | fn | AttachWebsocketRoute | pub | `func (s *Server) AttachWebsocketRoute(path stri...` |
| 549 | fn | registerManagementRoutes | (private) | `func (s *Server) registerManagementRoutes() {` |
| 743 | fn | managementAvailabilityMiddleware | (private) | `func (s *Server) managementAvailabilityMiddlewa...` |
| 753 | fn | serveManagementControlPanel | (private) | `func (s *Server) serveManagementControlPanel(c ...` |
| 787 | fn | enableKeepAlive | (private) | `func (s *Server) enableKeepAlive(timeout time.D...` |
| 803 | fn | handleKeepAlive | (private) | `func (s *Server) handleKeepAlive(c *gin.Context) {` |
| 825 | fn | signalKeepAlive | (private) | `func (s *Server) signalKeepAlive() {` |
| 835 | fn | watchKeepAlive | (private) | `func (s *Server) watchKeepAlive() {` |
| 869 | fn | unifiedModelsHandler | (private) | `func (s *Server) unifiedModelsHandler(openaiHan...` |
| 889 | fn | Start | pub | `func (s *Server) Start() error {` |
| 924 | fn | Stop | pub | `func (s *Server) Stop(ctx context.Context) error {` |
| 948 | fn | corsMiddleware | (private) | `func corsMiddleware() gin.HandlerFunc {` |
| 963 | fn | applyAccessConfig | (private) | `func (s *Server) applyAccessConfig(oldCfg, newC...` |
| 978 | fn | UpdateClients | pub | `func (s *Server) UpdateClients(cfg *config.Conf...` |
| 1122 | fn | SetWebsocketAuthChangeHandler | pub | `func (s *Server) SetWebsocketAuthChangeHandler(...` |
| 1134 | fn | AuthMiddleware | pub | `func AuthMiddleware(manager *sdkaccess.Manager)...` |
| 1162 | fn | configuredSignatureCacheEnabled | (private) | `func configuredSignatureCacheEnabled(cfg *confi...` |
| 1169 | fn | applySignatureCacheConfig | (private) | `func applySignatureCacheConfig(oldCfg, cfg *con...` |
| 1186 | fn | configuredSignatureBypassStrict | (private) | `func configuredSignatureBypassStrict(cfg *confi...` |

## Public API

### `WithMiddleware`

```
func WithMiddleware(mw ...gin.HandlerFunc) ServerOption {
```

**Line:** 70 | **Kind:** fn

### `WithEngineConfigurator`

```
func WithEngineConfigurator(fn func(*gin.Engine)) ServerOption {
```

**Line:** 77 | **Kind:** fn

### `WithRouterConfigurator`

```
func WithRouterConfigurator(fn func(*gin.Engine, *handlers.BaseAPIHandler, *config.Config)) ServerOption {
```

**Line:** 84 | **Kind:** fn

### `WithLocalManagementPassword`

```
func WithLocalManagementPassword(password string) ServerOption {
```

**Line:** 91 | **Kind:** fn

### `WithKeepAliveEndpoint`

```
func WithKeepAliveEndpoint(timeout time.Duration, onTimeout func()) ServerOption {
```

**Line:** 98 | **Kind:** fn

### `WithRequestLoggerFactory`

```
func WithRequestLoggerFactory(factory func(*config.Config, string) logging.RequestLogger) ServerOption {
```

**Line:** 110 | **Kind:** fn

### `WithPostAuthHook`

```
func WithPostAuthHook(hook auth.PostAuthHook) ServerOption {
```

**Line:** 117 | **Kind:** fn

### `NewServer`

```
func NewServer(cfg *config.Config, authManager *auth.Manager, accessManager *sdkaccess.Manager, configFilePath string, opts ...ServerOption) *Server {
```

**Line:** 194 | **Kind:** fn

### `AttachWebsocketRoute`

```
func (s *Server) AttachWebsocketRoute(path string, handler http.Handler) {
```

**Line:** 514 | **Kind:** fn

### `Start`

```
func (s *Server) Start() error {
```

**Line:** 889 | **Kind:** fn

### `Stop`

```
func (s *Server) Stop(ctx context.Context) error {
```

**Line:** 924 | **Kind:** fn

### `UpdateClients`

```
func (s *Server) UpdateClients(cfg *config.Config) {
```

**Line:** 978 | **Kind:** fn

### `SetWebsocketAuthChangeHandler`

```
func (s *Server) SetWebsocketAuthChangeHandler(fn func(bool, bool)) {
```

**Line:** 1122 | **Kind:** fn

### `AuthMiddleware`

```
func AuthMiddleware(manager *sdkaccess.Manager) gin.HandlerFunc {
```

**Line:** 1134 | **Kind:** fn

