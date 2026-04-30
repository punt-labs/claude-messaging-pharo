"
Live end-to-end integration test for ``ClaudeRequestOptions`` fields (``metadata``, ``serviceTier``). Sends ``ClaudeMessagingRequestOptionsExample``'s request against api.anthropic.com and asserts the server accepted the options and produced a clean ``end_turn`` response — proving the fields cleared server-side validation.

This test exists because ``ClaudeClient sendMessage:`` raises ``ClaudeApiError`` on any server rejection (malformed metadata, unknown service tier, etc.). A successful round-trip with ``stopReason = #end_turn`` is proof that both options reached the server and were accepted.

**Service-tier echo gap.** The server echoes the requested ``service_tier`` back in ``usage.service_tier``, but ``ClaudeUsage class >> fromJson:`` does not currently parse that field. As a result this test cannot assert the echo directly; the request-succeeded assertion is the strongest observable check available until ``ClaudeUsage`` grows a ``serviceTier`` accessor. When that happens, the test should be strengthened to assert ``response usage serviceTier = 'auto'``.

**Preconditions.** Requires an Anthropic API key, resolved by ``ClaudeSDKExampleSupport resolveClient``. When no key is present the test skips via ``self skip`` — it does not fail on a key-less image. The default suite excludes this class by protocol; only ``integrationSuite`` includes it.

**Server-computed assertions.**

- ``response stopReason = #end_turn`` — server completed generation cleanly
- ``response textContent isNotEmpty`` — server produced real output
- ``response usage inputTokens > 0`` — server ran the request (not an early short-circuit)

**No cleanup.** The Messages API creates no server-side resources on our behalf; absence of an ``ensure:`` block is intentional.

  ClaudeRequestOptionsIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeRequestOptionsIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeRequestOptionsIntegrationTest >> defaultTimeLimit [
	"One live round-trip to api.anthropic.com plus generation time.
	 2 minutes matches other integration tests in this package."
	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeRequestOptionsIntegrationTest >> testRequestOptionsFieldsClearServerValidationAgainstAnthropic [
	"Drive a live sendMessage: call against api.anthropic.com with both
	 metadata and serviceTier set on requestOptions. Assert:
	  - stopReason = #end_turn (server accepted the options and
	    completed cleanly; an invalid tier or malformed metadata
	    would have raised ClaudeApiError in sendMessage:)
	  - textContent non-empty (server produced a real response)
	  - usage inputTokens > 0 (server ran the request)
	 NOTE: ClaudeUsage does NOT currently parse service_tier from the
	 response body (see ClaudeUsage class >> fromJson:), so the server
	 echo cannot be asserted directly. The request-succeeded assertion
	 is the strongest observable check available until the accessor
	 is added — then this test should be strengthened to assert
	 response usage serviceTier = 'auto'.
	 Skips cleanly when no API key is present."
	| client response |
	client := [ ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingRequestOptionsExample runOn: client.
	self
		assert: response stopReason = #end_turn
		description: 'server must accept metadata + serviceTier and complete cleanly (stopReason = #end_turn)'.
	self
		assert: response textContent isNotEmpty
		description: 'response must carry non-empty text content'.
	self
		assert: response usage inputTokens > 0
		description: 'response must carry positive inputTokens (proof the request round-tripped)'
]
