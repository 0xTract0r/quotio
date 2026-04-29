# third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-sdk-api-handlers-openai/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1402
- **Language:** Go
- **Symbols:** 62
- **Public symbols:** 58

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 26 | struct | websocketCaptureExecutor | (private) | - |
| 31 | struct | websocketCompactionCaptureExecutor | (private) | - |
| 37 | struct | orderedWebsocketSelector | (private) | - |
| 43 | fn | Pick | pub | `func (s *orderedWebsocketSelector) Pick(_ conte...` |
| 67 | struct | websocketAuthCaptureExecutor | (private) | - |
| 72 | fn | Identifier | pub | `func (e *websocketAuthCaptureExecutor) Identifi...` |
| 74 | fn | Execute | pub | `func (e *websocketAuthCaptureExecutor) Execute(...` |
| 78 | fn | ExecuteStream | pub | `func (e *websocketAuthCaptureExecutor) ExecuteS...` |
| 91 | fn | Refresh | pub | `func (e *websocketAuthCaptureExecutor) Refresh(...` |
| 95 | fn | CountTokens | pub | `func (e *websocketAuthCaptureExecutor) CountTok...` |
| 99 | fn | HttpRequest | pub | `func (e *websocketAuthCaptureExecutor) HttpRequ...` |
| 103 | fn | AuthIDs | pub | `func (e *websocketAuthCaptureExecutor) AuthIDs(...` |
| 109 | fn | Identifier | pub | `func (e *websocketCaptureExecutor) Identifier()...` |
| 111 | fn | Execute | pub | `func (e *websocketCaptureExecutor) Execute(cont...` |
| 115 | fn | ExecuteStream | pub | `func (e *websocketCaptureExecutor) ExecuteStrea...` |
| 124 | fn | Refresh | pub | `func (e *websocketCaptureExecutor) Refresh(_ co...` |
| 128 | fn | CountTokens | pub | `func (e *websocketCaptureExecutor) CountTokens(...` |
| 132 | fn | HttpRequest | pub | `func (e *websocketCaptureExecutor) HttpRequest(...` |
| 136 | fn | Identifier | pub | `func (e *websocketCompactionCaptureExecutor) Id...` |
| 138 | fn | Execute | pub | `func (e *websocketCompactionCaptureExecutor) Ex...` |
| 148 | fn | ExecuteStream | pub | `func (e *websocketCompactionCaptureExecutor) Ex...` |
| 170 | fn | Refresh | pub | `func (e *websocketCompactionCaptureExecutor) Re...` |
| 174 | fn | CountTokens | pub | `func (e *websocketCompactionCaptureExecutor) Co...` |
| 178 | fn | HttpRequest | pub | `func (e *websocketCompactionCaptureExecutor) Ht...` |
| 182 | fn | TestNormalizeResponsesWebsocketRequestCreate | pub | `func TestNormalizeResponsesWebsocketRequestCrea...` |
| 203 | fn | TestNormalizeResponsesWebsocketRequestCreateWithHistory | pub | `func TestNormalizeResponsesWebsocketRequestCrea...` |
| 237 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDIncremental | pub | `func TestNormalizeResponsesWebsocketRequestWith...` |
| 273 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDMergedWhenIncrementalDisabled | pub | `func TestNormalizeResponsesWebsocketRequestWith...` |
| 303 | fn | TestNormalizeResponsesWebsocketRequestAppend | pub | `func TestNormalizeResponsesWebsocketRequestAppe...` |
| 331 | fn | TestNormalizeResponsesWebsocketRequestAppendWithoutCreate | pub | `func TestNormalizeResponsesWebsocketRequestAppe...` |
| 343 | fn | TestWebsocketJSONPayloadsFromChunk | pub | `func TestWebsocketJSONPayloadsFromChunk(t *test...` |
| 355 | fn | TestWebsocketJSONPayloadsFromPlainJSONChunk | pub | `func TestWebsocketJSONPayloadsFromPlainJSONChun...` |
| 367 | fn | TestResponseCompletedOutputFromPayload | pub | `func TestResponseCompletedOutputFromPayload(t *...` |
| 380 | fn | TestAppendWebsocketEvent | pub | `func TestAppendWebsocketEvent(t *testing.T) {` |
| 395 | fn | TestAppendWebsocketTimelineEvent | pub | `func TestAppendWebsocketTimelineEvent(t *testin...` |
| 413 | fn | TestSetWebsocketTimelineBody | pub | `func TestSetWebsocketTimelineBody(t *testing.T) {` |
| 437 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedOutput | pub | `func TestRepairResponsesWebsocketToolCallsInser...` |
| 465 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanFunctionCall | pub | `func TestRepairResponsesWebsocketToolCallsDrops...` |
| 481 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCallForOrphanOutput | pub | `func TestRepairResponsesWebsocketToolCallsInser...` |
| 506 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanOutputWhenCallMissing | pub | `func TestRepairResponsesWebsocketToolCallsDrops...` |
| 523 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolOutput | pub | `func TestRepairResponsesWebsocketToolCallsInser...` |
| 551 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolCall | pub | `func TestRepairResponsesWebsocketToolCallsDrops...` |
| 567 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolCallForOrphanOutput | pub | `func TestRepairResponsesWebsocketToolCallsInser...` |
| 592 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolOutputWhenCallMissing | pub | `func TestRepairResponsesWebsocketToolCallsDrops...` |
| 609 | fn | TestRecordResponsesWebsocketToolCallsFromPayloadWithCache | pub | `func TestRecordResponsesWebsocketToolCallsFromP...` |
| 625 | fn | TestRecordResponsesWebsocketCustomToolCallsFromCompletedPayloadWithCache | pub | `func TestRecordResponsesWebsocketCustomToolCall...` |
| 641 | fn | TestRecordResponsesWebsocketCustomToolCallsFromOutputItemDoneWithCache | pub | `func TestRecordResponsesWebsocketCustomToolCall...` |
| 657 | fn | TestForwardResponsesWebsocketPreservesCompletedEvent | pub | `func TestForwardResponsesWebsocketPreservesComp...` |
| 737 | fn | TestForwardResponsesWebsocketLogsAttemptedResponseOnWriteFailure | pub | `func TestForwardResponsesWebsocketLogsAttempted...` |
| 802 | fn | TestResponsesWebsocketTimelineRecordsDisconnectEvent | pub | `func TestResponsesWebsocketTimelineRecordsDisco...` |
| 847 | fn | TestWebsocketUpstreamSupportsIncrementalInputForModel | pub | `func TestWebsocketUpstreamSupportsIncrementalIn...` |
| 870 | fn | TestResponsesWebsocketPrewarmHandledLocallyForSSEUpstream | pub | `func TestResponsesWebsocketPrewarmHandledLocall...` |
| 974 | fn | TestWebsocketClientAddressUsesGinClientIP | pub | `func TestWebsocketClientAddressUsesGinClientIP(...` |
| 993 | fn | TestWebsocketClientAddressReturnsEmptyForNilContext | pub | `func TestWebsocketClientAddressReturnsEmptyForN...` |
| 999 | fn | TestResponsesWebsocketPinsOnlyWebsocketCapableAuth | pub | `func TestResponsesWebsocketPinsOnlyWebsocketCap...` |
| 1069 | fn | TestNormalizeResponsesWebsocketRequestTreatsTranscriptReplacementAsReset | pub | `func TestNormalizeResponsesWebsocketRequestTrea...` |
| 1095 | fn | TestNormalizeResponsesWebsocketRequestDoesNotTreatDeveloperMessageAsReplacement | pub | `func TestNormalizeResponsesWebsocketRequestDoes...` |
| 1121 | fn | TestNormalizeResponsesWebsocketRequestDropsDuplicateFunctionCallsByCallID | pub | `func TestNormalizeResponsesWebsocketRequestDrop...` |
| 1144 | fn | TestNormalizeResponsesWebsocketRequestTreatsCustomToolTranscriptReplacementAsReset | pub | `func TestNormalizeResponsesWebsocketRequestTrea...` |
| 1172 | fn | TestNormalizeResponsesWebsocketRequestDropsDuplicateCustomToolCallsByCallID | pub | `func TestNormalizeResponsesWebsocketRequestDrop...` |
| 1195 | fn | TestResponsesWebsocketCompactionResetsTurnStateOnCustomToolTranscriptReplacement | pub | `func TestResponsesWebsocketCompactionResetsTurn...` |
| 1299 | fn | TestResponsesWebsocketCompactionResetsTurnStateOnTranscriptReplacement | pub | `func TestResponsesWebsocketCompactionResetsTurn...` |

## Public API

### `Pick`

```
func (s *orderedWebsocketSelector) Pick(_ context.Context, _ string, _ string, _ coreexecutor.Options, auths []*coreauth.Auth) (*coreauth.Auth, error) {
```

**Line:** 43 | **Kind:** fn

### `Identifier`

```
func (e *websocketAuthCaptureExecutor) Identifier() string { return "test-provider" }
```

**Line:** 72 | **Kind:** fn

### `Execute`

```
func (e *websocketAuthCaptureExecutor) Execute(context.Context, *coreauth.Auth, coreexecutor.Request, coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 74 | **Kind:** fn

### `ExecuteStream`

```
func (e *websocketAuthCaptureExecutor) ExecuteStream(_ context.Context, auth *coreauth.Auth, _ coreexecutor.Request, _ coreexecutor.Options) (*coreexecutor.StreamResult, error) {
```

**Line:** 78 | **Kind:** fn

### `Refresh`

```
func (e *websocketAuthCaptureExecutor) Refresh(_ context.Context, auth *coreauth.Auth) (*coreauth.Auth, error) {
```

**Line:** 91 | **Kind:** fn

### `CountTokens`

```
func (e *websocketAuthCaptureExecutor) CountTokens(context.Context, *coreauth.Auth, coreexecutor.Request, coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 95 | **Kind:** fn

### `HttpRequest`

```
func (e *websocketAuthCaptureExecutor) HttpRequest(context.Context, *coreauth.Auth, *http.Request) (*http.Response, error) {
```

**Line:** 99 | **Kind:** fn

### `AuthIDs`

```
func (e *websocketAuthCaptureExecutor) AuthIDs() []string {
```

**Line:** 103 | **Kind:** fn

### `Identifier`

```
func (e *websocketCaptureExecutor) Identifier() string { return "test-provider" }
```

**Line:** 109 | **Kind:** fn

### `Execute`

```
func (e *websocketCaptureExecutor) Execute(context.Context, *coreauth.Auth, coreexecutor.Request, coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 111 | **Kind:** fn

### `ExecuteStream`

```
func (e *websocketCaptureExecutor) ExecuteStream(_ context.Context, _ *coreauth.Auth, req coreexecutor.Request, _ coreexecutor.Options) (*coreexecutor.StreamResult, error) {
```

**Line:** 115 | **Kind:** fn

### `Refresh`

```
func (e *websocketCaptureExecutor) Refresh(_ context.Context, auth *coreauth.Auth) (*coreauth.Auth, error) {
```

**Line:** 124 | **Kind:** fn

### `CountTokens`

```
func (e *websocketCaptureExecutor) CountTokens(context.Context, *coreauth.Auth, coreexecutor.Request, coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 128 | **Kind:** fn

### `HttpRequest`

```
func (e *websocketCaptureExecutor) HttpRequest(context.Context, *coreauth.Auth, *http.Request) (*http.Response, error) {
```

**Line:** 132 | **Kind:** fn

### `Identifier`

```
func (e *websocketCompactionCaptureExecutor) Identifier() string { return "test-provider" }
```

**Line:** 136 | **Kind:** fn

### `Execute`

```
func (e *websocketCompactionCaptureExecutor) Execute(_ context.Context, _ *coreauth.Auth, req coreexecutor.Request, opts coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 138 | **Kind:** fn

### `ExecuteStream`

```
func (e *websocketCompactionCaptureExecutor) ExecuteStream(_ context.Context, _ *coreauth.Auth, req coreexecutor.Request, _ coreexecutor.Options) (*coreexecutor.StreamResult, error) {
```

**Line:** 148 | **Kind:** fn

### `Refresh`

```
func (e *websocketCompactionCaptureExecutor) Refresh(_ context.Context, auth *coreauth.Auth) (*coreauth.Auth, error) {
```

**Line:** 170 | **Kind:** fn

### `CountTokens`

```
func (e *websocketCompactionCaptureExecutor) CountTokens(context.Context, *coreauth.Auth, coreexecutor.Request, coreexecutor.Options) (coreexecutor.Response, error) {
```

**Line:** 174 | **Kind:** fn

### `HttpRequest`

```
func (e *websocketCompactionCaptureExecutor) HttpRequest(context.Context, *coreauth.Auth, *http.Request) (*http.Response, error) {
```

**Line:** 178 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestCreate`

```
func TestNormalizeResponsesWebsocketRequestCreate(t *testing.T) {
```

**Line:** 182 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestCreateWithHistory`

```
func TestNormalizeResponsesWebsocketRequestCreateWithHistory(t *testing.T) {
```

**Line:** 203 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDIncremental`

```
func TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDIncremental(t *testing.T) {
```

**Line:** 237 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDMergedWhenIncrementalDisabled`

```
func TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDMergedWhenIncrementalDisabled(t *testing.T) {
```

**Line:** 273 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestAppend`

```
func TestNormalizeResponsesWebsocketRequestAppend(t *testing.T) {
```

**Line:** 303 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestAppendWithoutCreate`

```
func TestNormalizeResponsesWebsocketRequestAppendWithoutCreate(t *testing.T) {
```

**Line:** 331 | **Kind:** fn

### `TestWebsocketJSONPayloadsFromChunk`

```
func TestWebsocketJSONPayloadsFromChunk(t *testing.T) {
```

**Line:** 343 | **Kind:** fn

### `TestWebsocketJSONPayloadsFromPlainJSONChunk`

```
func TestWebsocketJSONPayloadsFromPlainJSONChunk(t *testing.T) {
```

**Line:** 355 | **Kind:** fn

### `TestResponseCompletedOutputFromPayload`

```
func TestResponseCompletedOutputFromPayload(t *testing.T) {
```

**Line:** 367 | **Kind:** fn

### `TestAppendWebsocketEvent`

```
func TestAppendWebsocketEvent(t *testing.T) {
```

**Line:** 380 | **Kind:** fn

### `TestAppendWebsocketTimelineEvent`

```
func TestAppendWebsocketTimelineEvent(t *testing.T) {
```

**Line:** 395 | **Kind:** fn

### `TestSetWebsocketTimelineBody`

```
func TestSetWebsocketTimelineBody(t *testing.T) {
```

**Line:** 413 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsInsertsCachedOutput`

```
func TestRepairResponsesWebsocketToolCallsInsertsCachedOutput(t *testing.T) {
```

**Line:** 437 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsDropsOrphanFunctionCall`

```
func TestRepairResponsesWebsocketToolCallsDropsOrphanFunctionCall(t *testing.T) {
```

**Line:** 465 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsInsertsCachedCallForOrphanOutput`

```
func TestRepairResponsesWebsocketToolCallsInsertsCachedCallForOrphanOutput(t *testing.T) {
```

**Line:** 481 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsDropsOrphanOutputWhenCallMissing`

```
func TestRepairResponsesWebsocketToolCallsDropsOrphanOutputWhenCallMissing(t *testing.T) {
```

**Line:** 506 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolOutput`

```
func TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolOutput(t *testing.T) {
```

**Line:** 523 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolCall`

```
func TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolCall(t *testing.T) {
```

**Line:** 551 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolCallForOrphanOutput`

```
func TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolCallForOrphanOutput(t *testing.T) {
```

**Line:** 567 | **Kind:** fn

### `TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolOutputWhenCallMissing`

```
func TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolOutputWhenCallMissing(t *testing.T) {
```

**Line:** 592 | **Kind:** fn

### `TestRecordResponsesWebsocketToolCallsFromPayloadWithCache`

```
func TestRecordResponsesWebsocketToolCallsFromPayloadWithCache(t *testing.T) {
```

**Line:** 609 | **Kind:** fn

### `TestRecordResponsesWebsocketCustomToolCallsFromCompletedPayloadWithCache`

```
func TestRecordResponsesWebsocketCustomToolCallsFromCompletedPayloadWithCache(t *testing.T) {
```

**Line:** 625 | **Kind:** fn

### `TestRecordResponsesWebsocketCustomToolCallsFromOutputItemDoneWithCache`

```
func TestRecordResponsesWebsocketCustomToolCallsFromOutputItemDoneWithCache(t *testing.T) {
```

**Line:** 641 | **Kind:** fn

### `TestForwardResponsesWebsocketPreservesCompletedEvent`

```
func TestForwardResponsesWebsocketPreservesCompletedEvent(t *testing.T) {
```

**Line:** 657 | **Kind:** fn

### `TestForwardResponsesWebsocketLogsAttemptedResponseOnWriteFailure`

```
func TestForwardResponsesWebsocketLogsAttemptedResponseOnWriteFailure(t *testing.T) {
```

**Line:** 737 | **Kind:** fn

### `TestResponsesWebsocketTimelineRecordsDisconnectEvent`

```
func TestResponsesWebsocketTimelineRecordsDisconnectEvent(t *testing.T) {
```

**Line:** 802 | **Kind:** fn

### `TestWebsocketUpstreamSupportsIncrementalInputForModel`

```
func TestWebsocketUpstreamSupportsIncrementalInputForModel(t *testing.T) {
```

**Line:** 847 | **Kind:** fn

### `TestResponsesWebsocketPrewarmHandledLocallyForSSEUpstream`

```
func TestResponsesWebsocketPrewarmHandledLocallyForSSEUpstream(t *testing.T) {
```

**Line:** 870 | **Kind:** fn

### `TestWebsocketClientAddressUsesGinClientIP`

```
func TestWebsocketClientAddressUsesGinClientIP(t *testing.T) {
```

**Line:** 974 | **Kind:** fn

### `TestWebsocketClientAddressReturnsEmptyForNilContext`

```
func TestWebsocketClientAddressReturnsEmptyForNilContext(t *testing.T) {
```

**Line:** 993 | **Kind:** fn

### `TestResponsesWebsocketPinsOnlyWebsocketCapableAuth`

```
func TestResponsesWebsocketPinsOnlyWebsocketCapableAuth(t *testing.T) {
```

**Line:** 999 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestTreatsTranscriptReplacementAsReset`

```
func TestNormalizeResponsesWebsocketRequestTreatsTranscriptReplacementAsReset(t *testing.T) {
```

**Line:** 1069 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestDoesNotTreatDeveloperMessageAsReplacement`

```
func TestNormalizeResponsesWebsocketRequestDoesNotTreatDeveloperMessageAsReplacement(t *testing.T) {
```

**Line:** 1095 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestDropsDuplicateFunctionCallsByCallID`

```
func TestNormalizeResponsesWebsocketRequestDropsDuplicateFunctionCallsByCallID(t *testing.T) {
```

**Line:** 1121 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestTreatsCustomToolTranscriptReplacementAsReset`

```
func TestNormalizeResponsesWebsocketRequestTreatsCustomToolTranscriptReplacementAsReset(t *testing.T) {
```

**Line:** 1144 | **Kind:** fn

### `TestNormalizeResponsesWebsocketRequestDropsDuplicateCustomToolCallsByCallID`

```
func TestNormalizeResponsesWebsocketRequestDropsDuplicateCustomToolCallsByCallID(t *testing.T) {
```

**Line:** 1172 | **Kind:** fn

### `TestResponsesWebsocketCompactionResetsTurnStateOnCustomToolTranscriptReplacement`

```
func TestResponsesWebsocketCompactionResetsTurnStateOnCustomToolTranscriptReplacement(t *testing.T) {
```

**Line:** 1195 | **Kind:** fn

### `TestResponsesWebsocketCompactionResetsTurnStateOnTranscriptReplacement`

```
func TestResponsesWebsocketCompactionResetsTurnStateOnTranscriptReplacement(t *testing.T) {
```

**Line:** 1299 | **Kind:** fn

