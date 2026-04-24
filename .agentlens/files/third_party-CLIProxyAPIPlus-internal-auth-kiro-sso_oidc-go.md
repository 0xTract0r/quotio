# third_party/CLIProxyAPIPlus/internal/auth/kiro/sso_oidc.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-auth-kiro/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1603
- **Language:** Go
- **Symbols:** 37
- **Public symbols:** 27

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 51 | struct | SSOOIDCClient | pub | - |
| 57 | fn | NewSSOOIDCClient | pub | `func NewSSOOIDCClient(cfg *config.Config) *SSOO...` |
| 69 | struct | RegisterClientResponse | pub | - |
| 77 | struct | StartDeviceAuthResponse | pub | - |
| 87 | struct | CreateTokenResponse | pub | - |
| 95 | fn | getOIDCEndpoint | (private) | `func getOIDCEndpoint(region string) string {` |
| 103 | fn | promptInput | (private) | `func promptInput(prompt, defaultValue string) s...` |
| 123 | fn | promptSelect | (private) | `func promptSelect(prompt string, options []stri...` |
| 151 | fn | RegisterClientWithRegion | pub | `func (c *SSOOIDCClient) RegisterClientWithRegio...` |
| 197 | fn | StartDeviceAuthorizationWithIDC | pub | `func (c *SSOOIDCClient) StartDeviceAuthorizatio...` |
| 242 | fn | CreateTokenWithRegion | pub | `func (c *SSOOIDCClient) CreateTokenWithRegion(c...` |
| 305 | fn | RefreshTokenWithRegion | pub | `func (c *SSOOIDCClient) RefreshTokenWithRegion(...` |
| 366 | fn | LoginWithIDC | pub | `func (c *SSOOIDCClient) LoginWithIDC(ctx contex...` |
| 488 | struct | IDCLoginOptions | pub | - |
| 497 | fn | LoginWithMethodSelection | pub | `func (c *SSOOIDCClient) LoginWithMethodSelectio...` |
| 563 | fn | LoginWithIDCAndOptions | pub | `func (c *SSOOIDCClient) LoginWithIDCAndOptions(...` |
| 568 | fn | RegisterClient | pub | `func (c *SSOOIDCClient) RegisterClient(ctx cont...` |
| 612 | fn | StartDeviceAuthorization | pub | `func (c *SSOOIDCClient) StartDeviceAuthorizatio...` |
| 655 | fn | CreateToken | pub | `func (c *SSOOIDCClient) CreateToken(ctx context...` |
| 717 | fn | RefreshToken | pub | `func (c *SSOOIDCClient) RefreshToken(ctx contex...` |
| 772 | fn | LoginWithBuilderID | pub | `func (c *SSOOIDCClient) LoginWithBuilderID(ctx ...` |
| 893 | fn | FetchUserEmail | pub | `func (c *SSOOIDCClient) FetchUserEmail(ctx cont...` |
| 905 | fn | tryUserInfoEndpoint | (private) | `func (c *SSOOIDCClient) tryUserInfoEndpoint(ctx...` |
| 955 | fn | FetchProfileArn | pub | `func (c *SSOOIDCClient) FetchProfileArn(ctx con...` |
| 963 | fn | tryListAvailableProfiles | (private) | `func (c *SSOOIDCClient) tryListAvailableProfile...` |
| 1010 | fn | tryListProfilesLegacy | (private) | `func (c *SSOOIDCClient) tryListProfilesLegacy(c...` |
| 1070 | fn | RegisterClientForAuthCode | pub | `func (c *SSOOIDCClient) RegisterClientForAuthCo...` |
| 1115 | fn | RegisterClientForAuthCodeWithIDC | pub | `func (c *SSOOIDCClient) RegisterClientForAuthCo...` |
| 1163 | struct | AuthCodeCallbackResult | pub | - |
| 1170 | fn | startAuthCodeCallbackServer | (private) | `func (c *SSOOIDCClient) startAuthCodeCallbackSe...` |
| 1248 | fn | generatePKCEForAuthCode | (private) | `func generatePKCEForAuthCode() (verifier, chall...` |
| 1260 | fn | generateStateForAuthCode | (private) | `func generateStateForAuthCode() (string, error) {` |
| 1269 | fn | CreateTokenWithAuthCode | pub | `func (c *SSOOIDCClient) CreateTokenWithAuthCode...` |
| 1314 | fn | CreateTokenWithAuthCodeAndRegion | pub | `func (c *SSOOIDCClient) CreateTokenWithAuthCode...` |
| 1363 | fn | LoginWithBuilderIDAuthCode | pub | `func (c *SSOOIDCClient) LoginWithBuilderIDAuthC...` |
| 1482 | fn | LoginWithIDCAuthCode | pub | `func (c *SSOOIDCClient) LoginWithIDCAuthCode(ct...` |
| 1593 | fn | buildAuthorizationURL | (private) | `func buildAuthorizationURL(endpoint, clientID, ...` |

## Public API

### `NewSSOOIDCClient`

```
func NewSSOOIDCClient(cfg *config.Config) *SSOOIDCClient {
```

**Line:** 57 | **Kind:** fn

### `RegisterClientWithRegion`

```
func (c *SSOOIDCClient) RegisterClientWithRegion(ctx context.Context, region string) (*RegisterClientResponse, error) {
```

**Line:** 151 | **Kind:** fn

### `StartDeviceAuthorizationWithIDC`

```
func (c *SSOOIDCClient) StartDeviceAuthorizationWithIDC(ctx context.Context, clientID, clientSecret, startURL, region string) (*StartDeviceAuthResponse, error) {
```

**Line:** 197 | **Kind:** fn

### `CreateTokenWithRegion`

```
func (c *SSOOIDCClient) CreateTokenWithRegion(ctx context.Context, clientID, clientSecret, deviceCode, region string) (*CreateTokenResponse, error) {
```

**Line:** 242 | **Kind:** fn

### `RefreshTokenWithRegion`

```
func (c *SSOOIDCClient) RefreshTokenWithRegion(ctx context.Context, clientID, clientSecret, refreshToken, region, startURL string) (*KiroTokenData, error) {
```

**Line:** 305 | **Kind:** fn

### `LoginWithIDC`

```
func (c *SSOOIDCClient) LoginWithIDC(ctx context.Context, startURL, region string) (*KiroTokenData, error) {
```

**Line:** 366 | **Kind:** fn

### `LoginWithMethodSelection`

```
func (c *SSOOIDCClient) LoginWithMethodSelection(ctx context.Context, opts *IDCLoginOptions) (*KiroTokenData, error) {
```

**Line:** 497 | **Kind:** fn

### `LoginWithIDCAndOptions`

```
func (c *SSOOIDCClient) LoginWithIDCAndOptions(ctx context.Context, startURL, region string) (*KiroTokenData, error) {
```

**Line:** 563 | **Kind:** fn

### `RegisterClient`

```
func (c *SSOOIDCClient) RegisterClient(ctx context.Context) (*RegisterClientResponse, error) {
```

**Line:** 568 | **Kind:** fn

### `StartDeviceAuthorization`

```
func (c *SSOOIDCClient) StartDeviceAuthorization(ctx context.Context, clientID, clientSecret string) (*StartDeviceAuthResponse, error) {
```

**Line:** 612 | **Kind:** fn

### `CreateToken`

```
func (c *SSOOIDCClient) CreateToken(ctx context.Context, clientID, clientSecret, deviceCode string) (*CreateTokenResponse, error) {
```

**Line:** 655 | **Kind:** fn

### `RefreshToken`

```
func (c *SSOOIDCClient) RefreshToken(ctx context.Context, clientID, clientSecret, refreshToken string) (*KiroTokenData, error) {
```

**Line:** 717 | **Kind:** fn

### `LoginWithBuilderID`

```
func (c *SSOOIDCClient) LoginWithBuilderID(ctx context.Context) (*KiroTokenData, error) {
```

**Line:** 772 | **Kind:** fn

### `FetchUserEmail`

```
func (c *SSOOIDCClient) FetchUserEmail(ctx context.Context, accessToken string) string {
```

**Line:** 893 | **Kind:** fn

### `FetchProfileArn`

```
func (c *SSOOIDCClient) FetchProfileArn(ctx context.Context, accessToken, clientID, refreshToken string) string {
```

**Line:** 955 | **Kind:** fn

### `RegisterClientForAuthCode`

```
func (c *SSOOIDCClient) RegisterClientForAuthCode(ctx context.Context, redirectURI string) (*RegisterClientResponse, error) {
```

**Line:** 1070 | **Kind:** fn

### `RegisterClientForAuthCodeWithIDC`

```
func (c *SSOOIDCClient) RegisterClientForAuthCodeWithIDC(ctx context.Context, redirectURI, issuerUrl, region string) (*RegisterClientResponse, error) {
```

**Line:** 1115 | **Kind:** fn

### `CreateTokenWithAuthCode`

```
func (c *SSOOIDCClient) CreateTokenWithAuthCode(ctx context.Context, clientID, clientSecret, code, codeVerifier, redirectURI string) (*CreateTokenResponse, error) {
```

**Line:** 1269 | **Kind:** fn

### `CreateTokenWithAuthCodeAndRegion`

```
func (c *SSOOIDCClient) CreateTokenWithAuthCodeAndRegion(ctx context.Context, clientID, clientSecret, code, codeVerifier, redirectURI, region string) (*CreateTokenResponse, error) {
```

**Line:** 1314 | **Kind:** fn

### `LoginWithBuilderIDAuthCode`

```
func (c *SSOOIDCClient) LoginWithBuilderIDAuthCode(ctx context.Context) (*KiroTokenData, error) {
```

**Line:** 1363 | **Kind:** fn

### `LoginWithIDCAuthCode`

```
func (c *SSOOIDCClient) LoginWithIDCAuthCode(ctx context.Context, startURL, region string) (*KiroTokenData, error) {
```

**Line:** 1482 | **Kind:** fn

