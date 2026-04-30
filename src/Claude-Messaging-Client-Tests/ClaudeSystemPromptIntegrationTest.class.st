"
Live end-to-end integration test for the `system:` field on
`ClaudeMessageRequest`. Sends `ClaudeMessagingSystemPromptExample`'s
request against api.anthropic.com, asserts the server-generated
response contains the verbatim marker text required by the system
prompt, and confirms `stopReason = #end_turn` on a clean completion.

This test exists to prove that the `system:` field reaches the model
and the model respects it. Mock tests can prove the JSON serialization
is shaped correctly; only a live round-trip proves the server honours
the constraint end-to-end.

**Marker strategy.** The system prompt requires a verbatim marker
(`MKR-%%%`) rather than a semantic constraint (e.g. 'answer in haiku'
or 'use a formal tone'). Semantic constraints need heuristics to
verify; an exact-substring assertion is cheap, reliable, and
falsifiable. If the server drops the system field or the model
ignores it, the marker is missing and the test fails red.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present the test skips via
`self skip` -- it does not fail on a key-less image. The default suite
(`ClaudeMessagingTestSuite suite`) excludes this class by protocol;
only `integrationSuite` includes it.

**Server-computed assertions.** Each assertion targets a value the
server produces. The client cannot fake these:

- `response textContent isNotEmpty` -- server produced some output
- `response textContent includesSubstring: 'MKR-%%%'` -- server
  respected the system-prompt marker constraint
- `response stopReason = #end_turn` -- server completed generation
  cleanly (compared as a Symbol; `stopReason:` coerces via `asSymbol`)

**No cleanup.** The Messages API creates no server-side resources on
our behalf; the absence of an `ensure:` block is intentional.

  ClaudeSystemPromptIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeSystemPromptIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeSystemPromptIntegrationTest >> defaultTimeLimit [
	"One live round-trip to api.anthropic.com plus generation time. The
	 default 10 s test timeout fires before a healthy round-trip
	 completes. 2 minutes matches other integration tests in this
	 package."
	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeSystemPromptIntegrationTest >> testSystemPromptConstraintsResponseAgainstAnthropic [
	"Drive a live sendMessage: call against api.anthropic.com with a
	 system prompt that requires a verbatim marker string in the response.
	 Assert (a) stopReason = #end_turn, (b) the response has text, and
	 (c) the marker is present -- the marker is the server-observable
	 proof that the system prompt reached the model and was respected.
	 Skips cleanly when no API key is present."
	| client response text |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingSystemPromptExample runOn: client.
	text := response textContent.
	self
		assert: response stopReason = #end_turn
		description: 'server must complete generation cleanly (stopReason = #end_turn)'.
	self
		assert: text isNotEmpty
		description: 'response must carry non-empty text content'.
	self
		assert: (text includesSubstring: 'MKR-%%%')
		description: 'response must contain the MKR-%%% marker required by the system prompt'
]
