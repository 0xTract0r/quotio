# Quotio/Services/Proxy/ProxyBridge.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1685
- **Language:** Swift
- **Symbols:** 38
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 24 | struct | FallbackContext | (internal) | `struct FallbackContext` |
| 98 | class | ProxyBridge | (internal) | `class ProxyBridge` |
| 108 | fn | local | (internal) | `static func local(port: UInt16) -> Target` |
| 119 | fn | remote | (internal) | `static func remote(baseURL: String, verifySSL: ...` |
| 145 | fn | forwardingPath | (internal) | `func forwardingPath(for path: String) -> String` |
| 224 | method | init | (internal) | `init()` |
| 233 | fn | configure | (internal) | `func configure(listenPort: UInt16, targetPort: ...` |
| 241 | fn | configureRemote | (internal) | `func configureRemote(listenPort: UInt16, remote...` |
| 270 | fn | start | (internal) | `func start()` |
| 316 | fn | stop | (internal) | `func stop()` |
| 328 | fn | handleListenerState | (private) | `private func handleListenerState(_ state: NWLis...` |
| 346 | fn | startSocketRelayFallback | (private) | `private func startSocketRelayFallback(reason: S...` |
| 382 | fn | handleNewConnection | (private) | `private func handleNewConnection(_ connection: ...` |
| 598 | fn | createFallbackContext | (private) | `private func createFallbackContext(body: String...` |
| 1235 | class | SocketHTTPRelayListener | (private) | `class SocketHTTPRelayListener` |
| 1247 | method | init | (internal) | `init(listenHost: String, listenPort: UInt16, ta...` |
| 1258 | fn | start | (internal) | `func start()` |
| 1272 | fn | cancel | (internal) | `func cancel()` |
| 1283 | fn | acceptAvailableConnections | (private) | `private func acceptAvailableConnections()` |
| 1310 | fn | storeActiveConnection | (private) | `private func storeActiveConnection(id: UUID, co...` |
| 1316 | fn | removeActiveConnection | (private) | `private func removeActiveConnection(id: UUID)` |
| 1322 | fn | removeAllActiveConnections | (private) | `private func removeAllActiveConnections() -> [S...` |
| 1330 | fn | makeListenSocket | (private) | `private static func makeListenSocket(host: Stri...` |
| 1374 | fn | configureClientSocket | (private) | `private static func configureClientSocket(_ fd:...` |
| 1385 | class | SocketHTTPRelayConnection | (private) | `class SocketHTTPRelayConnection` |
| 1399 | fn | start | (internal) | `func start()` |
| 1412 | fn | cancel | (internal) | `func cancel()` |
| 1416 | fn | startTargetConnection | (private) | `private func startTargetConnection(requestData:...` |
| 1453 | fn | sendRequest | (private) | `private func sendRequest(_ requestData: Data, t...` |
| 1464 | fn | receiveResponse | (private) | `private func receiveResponse(from connection: N...` |
| 1490 | fn | close | (private) | `private func close()` |
| 1507 | fn | writeErrorResponse | (private) | `private func writeErrorResponse(statusCode: Int...` |
| 1529 | fn | readHTTPRequest | (private) | `private static func readHTTPRequest(from fd: In...` |
| 1558 | fn | requestIsComplete | (private) | `private static func requestIsComplete(_ data: D...` |
| 1580 | fn | rewriteRequest | (private) | `private static func rewriteRequest(_ request: D...` |
| 1626 | fn | normalizeRequestTarget | (private) | `private static func normalizeRequestTarget(_ ta...` |
| 1639 | fn | writeAll | (private) | `private static func writeAll(_ data: Data, to f...` |
| 1664 | fn | makeTLSOptions | (private) | `private static func makeTLSOptions(for target: ...` |

