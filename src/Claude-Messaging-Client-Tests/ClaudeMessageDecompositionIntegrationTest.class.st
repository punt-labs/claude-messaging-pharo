"
Live end-to-end integration test for the response-side decomposition objects (``ClaudeRequestContext``, ``ClaudeStopDetails``). Sends a plain message request against api.anthropic.com and asserts that the typed accessors on the returned ``ClaudeMessage`` are populated from the real wire response.

This test exists because the unit tests for ``ClaudeRequestContext`` and ``ClaudeStopDetails`` prove the objects round-trip through ``fromJson:`` — they do NOT prove that a real server response actually lands in those slots. A silent regression in ``ClaudeClient>>sendMessage:`` (e.g. forgetting to call ``msg requestId:`` on the response) would pass unit tests while breaking observability in production. A live test is the only way to prove these fields survive a real round-trip.

**Refusal-path scope.** Refusal triggers are unstable: model updates, policy changes, and prompt-engineering arms races all change which inputs produce a refusal. Asserting ``stopDetails category = #refusal`` would flake within weeks of release. This test asserts the NORMAL end_turn path — which proves the decomposition objects are populated from the wire response. The refusal path remains out of scope.

**Preconditions.** Requires an Anthropic API key, resolved by ``ClaudeSDKExampleSupport resolveClient``. When no key is present both tests skip via ``self skip``. The default suite excludes this class by protocol; only ``integrationSuite`` includes it.

**Server-computed assertions.**

- ``response requestId beginsWith: 'req_'`` — server produced the request id, client copied it from the ``request-id`` response header (read-through accessor delegating to ``responseMetadata requestId``; the request id migrated from ``ClaudeRequestContext`` to ``ClaudeResponseMetadata`` in Phase 2 so it sits next to the rate-limit and retry-after telemetry that arrives on the same response)
- ``response stopDetails stopReason = #end_turn`` — server signalled clean completion
- ``response stopDetails category isNil`` — normal (non-refusal) completion has no refusal category

**No cleanup.** The Messages API creates no server-side resources on our behalf.

  ClaudeMessageDecompositionIntegrationTest buildSuite
  >>> a TestSuite


"
Class {
	#name : 'ClaudeMessageDecompositionIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeMessageDecompositionIntegrationTest >> buildSimpleRequest [
	"Build a plain, inexpensive message request used by both tests in
	 this class. Small maxTokens — this test is about the response-side
	 decomposition objects (stopDetails, requestContext) being populated
	 on the normal end_turn path, not about the content."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 50.
	req addUserMessage: 'What is 2+2? Reply with just the number.'.
	^ req
]

{ #category : 'accessing' }
ClaudeMessageDecompositionIntegrationTest >> defaultTimeLimit [
	"One live round-trip to api.anthropic.com per test plus generation time.
	 2 minutes matches other integration tests in this package."
	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeMessageDecompositionIntegrationTest >> testRequestIdSurvivesRoundTrip [
	"Send a normal message request and assert the response carries a
	 ClaudeResponseMetadata populated from the response request-id
	 header. The request-id migrated from ClaudeRequestContext to
	 ClaudeResponseMetadata in Phase 2 (mission yvyt+pch2) so it could
	 sit next to the rate-limit and retry-after telemetry that arrives
	 on the same response. ClaudeRequestContext now carries only
	 outputFormat; response requestId delegates through responseMetadata.
	 The server returns a request-id of the form 'req_<uuid>' —
	 asserting the prefix proves (a) the client copied the header onto
	 the message and (b) the server uses its documented id shape.
	 Server-computed because the client cannot fabricate a request id.
	 Skips cleanly when no API key is present."
	| client response |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := client sendMessage: self buildSimpleRequest.
	self
		assert: response responseMetadata isNotNil
		description: 'response must have a ClaudeResponseMetadata attached'.
	self
		assert: (response requestId isKindOf: String)
		description: 'response requestId must be a String; got ' , response requestId printString.
	self
		assert: (response requestId beginsWith: 'req_')
		description: 'requestId must begin with req_ (server convention); got ' , response requestId printString
]

{ #category : 'tests-integration' }
ClaudeMessageDecompositionIntegrationTest >> testStopDetailsPopulatedOnNormalEndTurn [
	"Send a normal message request (no refusal trigger) and assert
	 the ClaudeStopDetails object was populated from the response.
	 On the normal end_turn path:
	   - stopDetails stopReason = #end_turn (server signal)
	   - stopDetails category isNil (no refusal category — the
	     category field only populates when stop_details.type is
	     'refusal')
	 Asserting the NORMAL path (not refusal) because refusal triggers
	 are unstable across model/policy changes and an assertion on
	 category = #refusal would flake within weeks of release.
	 Skips cleanly when no API key is present."
	| client response |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := client sendMessage: self buildSimpleRequest.
	self
		assert: response stopDetails isNotNil
		description: 'response must have ClaudeStopDetails attached'.
	self
		assert: response stopDetails stopReason = #end_turn
		description: 'stopDetails stopReason must be #end_turn on normal completion; got ' , response stopDetails stopReason printString.
	self
		assert: response stopDetails category isNil
		description: 'stopDetails category must be nil on a non-refusal response; got ' , response stopDetails category printString
]
