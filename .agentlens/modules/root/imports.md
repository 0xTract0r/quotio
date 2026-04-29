# Imports

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Dependency Graph

```mermaid
graph TD
    root[root] --> _[.]
    root[root] --> _[.]
    root[root] --> _[.]
    root[root] --> usage[usage]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> icons[icons]
    root[root] --> assets[assets]
    root[root] --> common[common]
    root[root] --> common[common]
    root[root] --> common[common]
    root[root] --> layout[layout]
    root[root] --> ui[ui]
    root[root] --> ui[ui]
    root[root] --> ui[ui]
    root[root] --> hooks[hooks]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> pages[pages]
    root[root] --> router[router]
    root[root] --> router[router]
    root[root] --> _[@]
    root[root] --> styles[styles]
    root[root] --> utils[utils]
    root[root] --> utils[utils]
    root[root] --> utils[utils]
    root[root] --> utils[utils]
    root[root] --> _eslint[@eslint]
    root[root] --> _playwright[@playwright]
    root[root] --> _vitejs[@vitejs]
    root[root] --> atomic[atomic]
    root[root] --> base64[base64]
    root[root] --> big[big]
    root[root] --> binary[binary]
    root[root] --> brotli[brotli]
    root[root] --> bufio[bufio]
    root[root] --> bun[bun]
    root[root] --> child_process[child_process]
    root[root] --> cliproxy[cliproxy]
    root[root] --> context[context]
    root[root] --> datetime[datetime]
    root[root] --> diff[diff]
    root[root] --> eslint_plugin_react_hooks[eslint-plugin-react-hooks]
    root[root] --> eslint_plugin_react_refresh[eslint-plugin-react-refresh]
    root[root] --> filepath[filepath]
    root[root] --> flag[flag]
    root[root] --> flate[flate]
    root[root] --> fmt[fmt]
    root[root] --> fs[fs]
    root[root] --> fsnotify[fsnotify]
    root[root] --> gjson[gjson]
    root[root] --> globals[globals]
    root[root] --> godotenv[godotenv]
    root[root] --> google[google]
    root[root] --> gzip[gzip]
    root[root] --> helps[helps]
    root[root] --> hex[hex]
    root[root] --> hmac[hmac]
    root[root] --> html[html]
    root[root] --> httptest[httptest]
    root[root] --> json[json]
    root[root] --> math[math]
    root[root] --> misc[misc]
    root[root] --> mitmproxy[mitmproxy]
    root[root] --> net[net]
    root[root] --> oauth2[oauth2]
    root[root] --> path[path]
    root[root] --> pathlib[pathlib]
    root[root] --> pem[pem]
    root[root] --> plumbing[plumbing]
    root[root] --> rand[rand]
    root[root] --> react[react]
    root[root] --> react_dom[react-dom]
    root[root] --> react_i18next[react-i18next]
    root[root] --> react_router_dom[react-router-dom]
    root[root] --> reflect[reflect]
    root[root] --> regexp[regexp]
    root[root] --> rsa[rsa]
    root[root] --> sha256[sha256]
    root[root] --> singleflight[singleflight]
    root[root] --> sjson[sjson]
    root[root] --> sort[sort]
    root[root] --> sql[sql]
    root[root] --> strconv[strconv]
    root[root] --> strings[strings]
    root[root] --> subtle[subtle]
    root[root] --> sync[sync]
    root[root] --> synthesizer[synthesizer]
    root[root] --> syscall[syscall]
    root[root] --> testing[testing]
    root[root] --> textproto[textproto]
    root[root] --> tls[tls]
    root[root] --> tokenizer[tokenizer]
    root[root] --> transport[transport]
    root[root] --> tui[tui]
    root[root] --> typescript_eslint[typescript-eslint]
    root[root] --> url[url]
    root[root] --> uuid[uuid]
    root[root] --> v6[v6]
    root[root] --> v7[v7]
    root[root] --> vite_plugin_singlefile[vite-plugin-singlefile]
    root[root] --> x509[x509]
    root[root] --> yaml_v3[yaml.v3]
    root[root] --> zstd[zstd]
```

## Internal Dependencies

Dependencies within this module:

- `access`
- `api`
- `auth`
- `browser`
- `buildinfo`
- `bytes`
- `cache`
- `claude`
- `cmd`
- `codex`
- `common`
- `config`
- `credentials`
- `errors`
- `exec`
- `gemini`
- `geminicli`
- `gin`
- `gitlab`
- `handlers`
- `http`
- `interfaces`
- `io`
- `kiro`
- `logging`
- `managementasset`
- `middleware`
- `modules`
- `object`
- `openai`
- `os`
- `proxy`
- `proxyutil`
- `registry`
- `runtime`
- `store`
- `thinking`
- `time`
- `translator`
- `usage`
- `util`
- `vite`
- `websocket`
- `wsrelay`

## External Dependencies

Dependencies from other modules:

- `./App.tsx`
- `./constants`
- `./format`
- `./usage/latency`
- `@/assets/icons/antigravity.svg`
- `@/assets/icons/claude.svg`
- `@/assets/icons/codex.svg`
- `@/assets/icons/gemini.svg`
- `@/assets/icons/iflow.svg`
- `@/assets/icons/kimi-dark.svg`
- `@/assets/icons/kimi-light.svg`
- `@/assets/icons/qwen.svg`
- `@/assets/icons/vertex.svg`
- `@/assets/logoInline`
- `@/components/common/ConfirmationModal`
- `@/components/common/NotificationContainer`
- `@/components/common/PageTransition`
- `@/components/layout/MainLayout`
- `@/components/ui/Button`
- `@/components/ui/LoadingSpinner`
- `@/components/ui/icons`
- `@/hooks/useHeaderRefresh`
- `@/pages/AiProvidersAmpcodeEditPage`
- `@/pages/AiProvidersClaudeEditLayout`
- `@/pages/AiProvidersClaudeEditPage`
- `@/pages/AiProvidersClaudeModelsPage`
- `@/pages/AiProvidersCodexEditPage`
- `@/pages/AiProvidersGeminiEditPage`
- `@/pages/AiProvidersOpenAIEditLayout`
- `@/pages/AiProvidersOpenAIEditPage`
- `@/pages/AiProvidersOpenAIModelsPage`
- `@/pages/AiProvidersPage`
- `@/pages/AiProvidersVertexEditPage`
- `@/pages/AuthFilesOAuthExcludedEditPage`
- `@/pages/AuthFilesOAuthModelAliasEditPage`
- `@/pages/AuthFilesPage`
- `@/pages/ConfigPage`
- `@/pages/DashboardPage`
- `@/pages/LoginPage`
- `@/pages/LogsPage`
- `@/pages/OAuthPage`
- `@/pages/QuotaPage`
- `@/pages/SystemPage`
- `@/pages/UsagePage`
- `@/router/MainRoutes`
- `@/router/ProtectedRoute`
- `@/stores`
- `@/styles/global.scss`
- `@/utils/constants`
- `@/utils/encryption`
- `@/utils/language`
- `@/utils/usage`
- `@eslint/js`
- `@playwright/test`
- `@vitejs/plugin-react`
- `atomic`
- `base64`
- `big`
- `binary`
- `brotli`
- `bufio`
- `bun`
- `child_process`
- `cliproxy`
- `context`
- `datetime`
- `diff`
- `eslint-plugin-react-hooks`
- `eslint-plugin-react-refresh`
- `filepath`
- `flag`
- `flate`
- `fmt`
- `fs`
- `fsnotify`
- `gjson`
- `globals`
- `godotenv`
- `google`
- `gzip`
- `helps`
- `hex`
- `hmac`
- `html`
- `httptest`
- `json`
- `math`
- `misc`
- `mitmproxy`
- `net`
- `oauth2`
- `path`
- `pathlib`
- `pem`
- `plumbing`
- `rand`
- `react`
- `react-dom/client`
- `react-i18next`
- `react-router-dom`
- `reflect`
- `regexp`
- `rsa`
- `sha256`
- `singleflight`
- `sjson`
- `sort`
- `sql`
- `strconv`
- `strings`
- `subtle`
- `sync`
- `synthesizer`
- `syscall`
- `testing`
- `textproto`
- `tls`
- `tokenizer`
- `transport`
- `tui`
- `typescript-eslint`
- `url`
- `uuid`
- `v6`
- `v7`
- `vite-plugin-singlefile`
- `x509`
- `yaml.v3`
- `zstd`

