# Module: third_party/CLIProxyAPIPlus/internal/api/handlers/management

[← Back to INDEX](../../INDEX.md)

**Type:** implicit | **Files:** 31

## Files

| File | Lines | Large |
| ---- | ----- | ----- |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools.go` | 1273 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools_cbor_test.go` | 149 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools_test.go` | 212 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files.go` | 5359 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_account_settings_test.go` | 1420 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_batch_test.go` | 197 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_delete_test.go` | 129 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_download_test.go` | 62 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_download_windows_test.go` | 51 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_gitlab_test.go` | 164 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_patch_fields_test.go` | 164 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_status_test.go` | 118 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_status_history.go` | 303 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_auth_index.go` | 241 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_basic.go` | 368 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_lists.go` | 1514 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_lists_delete_keys_test.go` | 172 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/handler.go` | 343 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/logs.go` | 583 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/model_definitions.go` | 33 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/oauth_callback.go` | 100 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/oauth_management_routes_test.go` | 164 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/oauth_reauth_history.go` | 163 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/oauth_sessions.go` | 367 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/provider_tls_probe.go` | 80 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/provider_tls_probe_test.go` | 157 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/quota.go` | 18 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/test_store_test.go` | 49 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/usage.go` | 171 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/usage_pricing_test.go` | 68 |  |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management/vertex_import.go` | 156 |  |

## Documentation

- [outline.md](outline.md) - Symbol maps for large files
- [imports.md](imports.md) - Dependencies

---

| High 🔴 | Medium 🟡 | Low 🟢 |
| 0 | 0 | 1 |

## 🟢 Low Priority

### `NOTE` (third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools.go:88)

> if you need to override the HTTP Host header, set header["Host"].
