# third_party/CLIProxyAPIPlus/internal/api/server.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1123
- **Language:** Go
- **Symbols:** 29
- **Public symbols:** 15

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 44 | const | oauthCallbackSuccessHTML | (private) | - |
| 46 | struct | serverOptionConfig | (private) | - |
| 61 | fn | defaultRequestLoggerFactory | (private) | `func defaultRequestLoggerFactory(cfg *config.Co...` |
| 68 | fn | WithMiddleware | pub | `func WithMiddleware(mw ...gin.HandlerFunc) Serv...` |
| 75 | fn | WithEngineConfigurator | pub | `func WithEngineConfigurator(fn func(*gin.Engine...` |
| 82 | fn | WithRouterConfigurator | pub | `func WithRouterConfigurator(fn func(*gin.Engine...` |
| 89 | fn | WithLocalManagementPassword | pub | `func WithLocalManagementPassword(password strin...` |
| 96 | fn | WithKeepAliveEndpoint | pub | `func WithKeepAliveEndpoint(timeout time.Duratio...` |
| 108 | fn | WithRequestLoggerFactory | pub | `func WithRequestLoggerFactory(factory func(*con...` |
| 115 | fn | WithPostAuthHook | pub | `func WithPostAuthHook(hook auth.PostAuthHook) S...` |
| 123 | struct | Server | pub | - |
| 192 | fn | NewServer | pub | `func NewServer(cfg *config.Config, authManager ...` |
| 325 | fn | setupRoutes | (private) | `func (s *Server) setupRoutes() {` |
| 481 | fn | AttachWebsocketRoute | pub | `func (s *Server) AttachWebsocketRoute(path stri...` |
| 516 | fn | registerManagementRoutes | (private) | `func (s *Server) registerManagementRoutes() {` |
| 707 | fn | managementAvailabilityMiddleware | (private) | `func (s *Server) managementAvailabilityMiddlewa...` |
| 717 | fn | serveManagementControlPanel | (private) | `func (s *Server) serveManagementControlPanel(c ...` |
| 751 | fn | enableKeepAlive | (private) | `func (s *Server) enableKeepAlive(timeout time.D...` |
| 767 | fn | handleKeepAlive | (private) | `func (s *Server) handleKeepAlive(c *gin.Context) {` |
| 789 | fn | signalKeepAlive | (private) | `func (s *Server) signalKeepAlive() {` |
| 799 | fn | watchKeepAlive | (private) | `func (s *Server) watchKeepAlive() {` |
| 833 | fn | unifiedModelsHandler | (private) | `func (s *Server) unifiedModelsHandler(openaiHan...` |
| 853 | fn | Start | pub | `func (s *Server) Start() error {` |
| 888 | fn | Stop | pub | `func (s *Server) Stop(ctx context.Context) error {` |
| 912 | fn | corsMiddleware | (private) | `func corsMiddleware() gin.HandlerFunc {` |
| 927 | fn | applyAccessConfig | (private) | `func (s *Server) applyAccessConfig(oldCfg, newC...` |
| 942 | fn | UpdateClients | pub | `func (s *Server) UpdateClients(cfg *config.Conf...` |
| 1085 | fn | SetWebsocketAuthChangeHandler | pub | `func (s *Server) SetWebsocketAuthChangeHandler(...` |
| 1097 | fn | AuthMiddleware | pub | `func AuthMiddleware(manager *sdkaccess.Manager)...` |

## Public API

### `WithMiddleware`

```
func WithMiddleware(mw ...gin.HandlerFunc) ServerOption {
```

**Line:** 68 | **Kind:** fn

### `WithEngineConfigurator`

```
func WithEngineConfigurator(fn func(*gin.Engine)) ServerOption {
```

**Line:** 75 | **Kind:** fn

### `WithRouterConfigurator`

```
func WithRouterConfigurator(fn func(*gin.Engine, *handlers.BaseAPIHandler, *config.Config)) ServerOption {
```

**Line:** 82 | **Kind:** fn

### `WithLocalManagementPassword`

```
func WithLocalManagementPassword(password string) ServerOption {
```

**Line:** 89 | **Kind:** fn

### `WithKeepAliveEndpoint`

```
func WithKeepAliveEndpoint(timeout time.Duration, onTimeout func()) ServerOption {
```

**Line:** 96 | **Kind:** fn

### `WithRequestLoggerFactory`

```
func WithRequestLoggerFactory(factory func(*config.Config, string) logging.RequestLogger) ServerOption {
```

**Line:** 108 | **Kind:** fn

### `WithPostAuthHook`

```
func WithPostAuthHook(hook auth.PostAuthHook) ServerOption {
```

**Line:** 115 | **Kind:** fn

### `NewServer`

```
func NewServer(cfg *config.Config, authManager *auth.Manager, accessManager *sdkaccess.Manager, configFilePath string, opts ...ServerOption) *Server {
```

**Line:** 192 | **Kind:** fn

### `AttachWebsocketRoute`

```
func (s *Server) AttachWebsocketRoute(path string, handler http.Handler) {
```

**Line:** 481 | **Kind:** fn

### `Start`

```
func (s *Server) Start() error {
```

**Line:** 853 | **Kind:** fn

### `Stop`

```
func (s *Server) Stop(ctx context.Context) error {
```

**Line:** 888 | **Kind:** fn

### `UpdateClients`

```
func (s *Server) UpdateClients(cfg *config.Config) {
```

**Line:** 942 | **Kind:** fn

### `SetWebsocketAuthChangeHandler`

```
func (s *Server) SetWebsocketAuthChangeHandler(fn func(bool, bool)) {
```

**Line:** 1085 | **Kind:** fn

### `AuthMiddleware`

```
func AuthMiddleware(manager *sdkaccess.Manager) gin.HandlerFunc {
```

**Line:** 1097 | **Kind:** fn

