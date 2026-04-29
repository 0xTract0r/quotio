# third_party/CLIProxyAPIPlus/internal/api/server.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1179
- **Language:** Go
- **Symbols:** 32
- **Public symbols:** 15

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 45 | const | oauthCallbackSuccessHTML | (private) | - |
| 47 | struct | serverOptionConfig | (private) | - |
| 62 | fn | defaultRequestLoggerFactory | (private) | `func defaultRequestLoggerFactory(cfg *config.Co...` |
| 69 | fn | WithMiddleware | pub | `func WithMiddleware(mw ...gin.HandlerFunc) Serv...` |
| 76 | fn | WithEngineConfigurator | pub | `func WithEngineConfigurator(fn func(*gin.Engine...` |
| 83 | fn | WithRouterConfigurator | pub | `func WithRouterConfigurator(fn func(*gin.Engine...` |
| 90 | fn | WithLocalManagementPassword | pub | `func WithLocalManagementPassword(password strin...` |
| 97 | fn | WithKeepAliveEndpoint | pub | `func WithKeepAliveEndpoint(timeout time.Duratio...` |
| 109 | fn | WithRequestLoggerFactory | pub | `func WithRequestLoggerFactory(factory func(*con...` |
| 116 | fn | WithPostAuthHook | pub | `func WithPostAuthHook(hook auth.PostAuthHook) S...` |
| 124 | struct | Server | pub | - |
| 193 | fn | NewServer | pub | `func NewServer(cfg *config.Config, authManager ...` |
| 327 | fn | setupRoutes | (private) | `func (s *Server) setupRoutes() {` |
| 503 | fn | AttachWebsocketRoute | pub | `func (s *Server) AttachWebsocketRoute(path stri...` |
| 538 | fn | registerManagementRoutes | (private) | `func (s *Server) registerManagementRoutes() {` |
| 731 | fn | managementAvailabilityMiddleware | (private) | `func (s *Server) managementAvailabilityMiddlewa...` |
| 741 | fn | serveManagementControlPanel | (private) | `func (s *Server) serveManagementControlPanel(c ...` |
| 775 | fn | enableKeepAlive | (private) | `func (s *Server) enableKeepAlive(timeout time.D...` |
| 791 | fn | handleKeepAlive | (private) | `func (s *Server) handleKeepAlive(c *gin.Context) {` |
| 813 | fn | signalKeepAlive | (private) | `func (s *Server) signalKeepAlive() {` |
| 823 | fn | watchKeepAlive | (private) | `func (s *Server) watchKeepAlive() {` |
| 857 | fn | unifiedModelsHandler | (private) | `func (s *Server) unifiedModelsHandler(openaiHan...` |
| 877 | fn | Start | pub | `func (s *Server) Start() error {` |
| 912 | fn | Stop | pub | `func (s *Server) Stop(ctx context.Context) error {` |
| 936 | fn | corsMiddleware | (private) | `func corsMiddleware() gin.HandlerFunc {` |
| 951 | fn | applyAccessConfig | (private) | `func (s *Server) applyAccessConfig(oldCfg, newC...` |
| 966 | fn | UpdateClients | pub | `func (s *Server) UpdateClients(cfg *config.Conf...` |
| 1110 | fn | SetWebsocketAuthChangeHandler | pub | `func (s *Server) SetWebsocketAuthChangeHandler(...` |
| 1122 | fn | AuthMiddleware | pub | `func AuthMiddleware(manager *sdkaccess.Manager)...` |
| 1150 | fn | configuredSignatureCacheEnabled | (private) | `func configuredSignatureCacheEnabled(cfg *confi...` |
| 1157 | fn | applySignatureCacheConfig | (private) | `func applySignatureCacheConfig(oldCfg, cfg *con...` |
| 1174 | fn | configuredSignatureBypassStrict | (private) | `func configuredSignatureBypassStrict(cfg *confi...` |

## Public API

### `WithMiddleware`

```
func WithMiddleware(mw ...gin.HandlerFunc) ServerOption {
```

**Line:** 69 | **Kind:** fn

### `WithEngineConfigurator`

```
func WithEngineConfigurator(fn func(*gin.Engine)) ServerOption {
```

**Line:** 76 | **Kind:** fn

### `WithRouterConfigurator`

```
func WithRouterConfigurator(fn func(*gin.Engine, *handlers.BaseAPIHandler, *config.Config)) ServerOption {
```

**Line:** 83 | **Kind:** fn

### `WithLocalManagementPassword`

```
func WithLocalManagementPassword(password string) ServerOption {
```

**Line:** 90 | **Kind:** fn

### `WithKeepAliveEndpoint`

```
func WithKeepAliveEndpoint(timeout time.Duration, onTimeout func()) ServerOption {
```

**Line:** 97 | **Kind:** fn

### `WithRequestLoggerFactory`

```
func WithRequestLoggerFactory(factory func(*config.Config, string) logging.RequestLogger) ServerOption {
```

**Line:** 109 | **Kind:** fn

### `WithPostAuthHook`

```
func WithPostAuthHook(hook auth.PostAuthHook) ServerOption {
```

**Line:** 116 | **Kind:** fn

### `NewServer`

```
func NewServer(cfg *config.Config, authManager *auth.Manager, accessManager *sdkaccess.Manager, configFilePath string, opts ...ServerOption) *Server {
```

**Line:** 193 | **Kind:** fn

### `AttachWebsocketRoute`

```
func (s *Server) AttachWebsocketRoute(path string, handler http.Handler) {
```

**Line:** 503 | **Kind:** fn

### `Start`

```
func (s *Server) Start() error {
```

**Line:** 877 | **Kind:** fn

### `Stop`

```
func (s *Server) Stop(ctx context.Context) error {
```

**Line:** 912 | **Kind:** fn

### `UpdateClients`

```
func (s *Server) UpdateClients(cfg *config.Config) {
```

**Line:** 966 | **Kind:** fn

### `SetWebsocketAuthChangeHandler`

```
func (s *Server) SetWebsocketAuthChangeHandler(fn func(bool, bool)) {
```

**Line:** 1110 | **Kind:** fn

### `AuthMiddleware`

```
func AuthMiddleware(manager *sdkaccess.Manager) gin.HandlerFunc {
```

**Line:** 1122 | **Kind:** fn

