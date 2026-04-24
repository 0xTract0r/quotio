# Module: third_party/CLIProxyAPIPlus/internal/translator/kiro/claude

[← Back to INDEX](../../INDEX.md)

**Type:** implicit | **Files:** 9

## Files

| File | Lines | Large |
| ---- | ----- | ----- |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/init.go` | 20 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude.go` | 21 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_request.go` | 961 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_response.go` | 209 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_stream.go` | 306 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_stream_parser.go` | 350 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_tools.go` | 543 | 📊 |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_websearch.go` | 495 |  |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/truncation_detector.go` | 537 | 📊 |

## Documentation

- [outline.md](outline.md) - Symbol maps for large files
- [imports.md](imports.md) - Dependencies

---

| High 🔴 | Medium 🟡 | Low 🟢 |
| 0 | 0 | 2 |

## 🟢 Low Priority

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_request.go:283)

> Kiro API doesn't actually use max_tokens for thinking budget

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_websearch.go:348)

> We embed search instructions HERE (not in system prompt) because
