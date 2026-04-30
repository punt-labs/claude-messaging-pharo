"
Live regression guard for ``ClaudeMessagingRawStreamingExample >> runOn:``. Runs against api.anthropic.com with a real API key; skipped when no key is configured.

### What this test proves

The raw-streaming example class opens a real TLS streaming socket, wraps it with ``ClaudeSSEDecoder``, drains the SSE events into a single ``ClaudeMessage``, and copies the socket's ``requestId`` onto the final message before returning. This test asserts the full contract end-to-end: right return type, stream drained to ``#end_turn``, text actually arrived, and the Anthropic ``req_`` correlation id propagated onto the message (the Bugbot + Copilot convergent finding fixed in PR #117 R3).

Skipped cleanly when ``ClaudeSDKExampleSupport resolveClient`` raises -- no API key configured -- so the fast test suite stays green for contributors without keys. Included in the integration suite when a key is present.

### Sibling live tests

Three live streaming tests share the same API surface but exercise different layers:

- ``ClaudeIntegrationTest >> testRealStreamingEvents`` -- drives ``ClaudeStreamingSocket`` directly; proves the socket + ``ClaudeSSEDecoder`` wire contract. Does NOT go through the example class or through ``ClaudeClient >> streamMessage:do:``.
- ``ClaudeIntegrationTest >> testRealStreamingViaClient`` -- drives ``ClaudeClient >> streamMessage:do:``; proves the high-level client streaming path.
- ``ClaudeRawStreamingIntegrationTest >> testRawStreamingExampleRoundTripsAgainstAnthropic`` -- **this test**; drives ``ClaudeMessagingRawStreamingExample >> runOn:``; proves the example class works end-to-end and propagates ``requestId`` as promised.

Before this test existed (PR #117 merged without live coverage for ``runOn:``), the example class was proven only by code review. This closes that gap.

### Structure

One test method in this class. Deterministic structural check:

```
ClaudeRawStreamingIntegrationTest buildSuite tests size
>>> 1
```

Typical wall-clock for the live run: 3-15 seconds including TLS handshake and ~50-token generation. ``defaultTimeLimit`` is 2 minutes -- generous enough for worst-case network weather, short enough to fail fast when a call hangs.

### See also

``ClaudeMessagingRawStreamingExample`` -- the subject under test. ``ClaudeStreamingSocket`` -- the raw socket class used underneath. ``ClaudeMessage >> requestId`` -- the slot this test asserts propagated correctly.

"
Class {
	#name : 'ClaudeRawStreamingIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeRawStreamingIntegrationTest >> defaultTimeLimit [
    "A live API round-trip can take tens of seconds across regions,
     plus server generation time. 2 minutes is generous enough for
     worst-case network weather but fails fast when the call hangs."
    ^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeRawStreamingIntegrationTest >> testRawStreamingExampleRoundTripsAgainstAnthropic [
    "Exercise ClaudeMessagingRawStreamingExample>>runOn: end-to-end against
     api.anthropic.com. This is the live regression guard for the raw-streaming
     example class: it drives a real TLS socket, drains SSE events, and asserts
     the returned ClaudeMessage is fully populated -- including the requestId
     propagation added in PR #117 R3. Sibling live tests
     ClaudeIntegrationTest>>testRealStreamingEvents and testRealStreamingViaClient
     exercise the socket and ClaudeClient>>streamMessage:do: respectively; this
     test is the one that exercises the example class. Skipped when no API key
     is available."
    | client response |
    client := [ ClaudeSDKExampleSupport resolveClient ]
        on: Error do: [ :e | ^ self skip ].
    response := ClaudeMessagingRawStreamingExample runOn: client.
    self
        assert: (response isKindOf: ClaudeMessage)
        description: 'runOn: must return a ClaudeMessage, not a lower-level value'.
    self
        assert: response stopReason = #end_turn
        description: 'stopReason must be #end_turn -- stream drained to completion, not abandoned mid-flight'.
    self
        assert: response textContent isNotEmpty
        description: 'textContent must be non-empty -- tokens actually arrived through the SSE pipeline'.
    self
        assert: response requestId notNil
        description: 'requestId must propagate from the streaming socket onto the final message (Bugbot + Copilot convergence, PR #117 R3)'.
    self
        assert: (response requestId beginsWith: 'req_')
        description: 'requestId must carry the Anthropic req_ prefix so a support ticket has a usable id'.
    Transcript
        nextPutAll: '<< Raw streaming: requestId=';
        nextPutAll: response requestId;
        nextPutAll: ', text=';
        nextPutAll: response textContent;
        nextPutAll: ', in=';
        nextPutAll: response usage inputTokens printString;
        nextPutAll: ', out=';
        nextPutAll: response usage outputTokens printString;
        cr
]
