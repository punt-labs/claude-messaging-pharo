"
Live end-to-end integration test for ``ClaudeJsonSchemaOutputFormat``. Sends ``ClaudeMessagingOutputFormatExample``'s request against api.anthropic.com, parses the response text as JSON, and asserts the server-enforced schema conformance (``name`` is a ``String``, ``age`` is an ``Integer``).

This test exists to prove that the ``output_config.format`` field reaches the model and the server actually constrains the output shape. Mock tests can prove the JSON serialization is correct; only a live round-trip proves the server honours the schema end-to-end — and only a server can produce a schema-conforming object (the client cannot fake that).

**Preconditions.** Requires an Anthropic API key, resolved by ``ClaudeSDKExampleSupport resolveClient`` from either the OS keyring (service ``anthropic-api``, account ``default``) or the ``ANTHROPIC_API_KEY`` environment variable. When no key is present the test skips via ``self skip`` — it does not fail on a key-less image. The default suite (``ClaudeMessagingTestSuite suite``) excludes this class by protocol; only ``integrationSuite`` includes it.

**Server-computed assertions.** Each assertion targets a value the server produces. The client cannot fake these:

- ``response stopReason = #end_turn`` — server completed generation cleanly
- ``response textContent isNotEmpty`` — server produced some output
- parsed JSON ``name`` is a ``String`` — server enforced the schema type
- parsed JSON ``age`` is an ``Integer`` — server enforced the schema type

**No cleanup.** The Messages API creates no server-side resources on our behalf; absence of an ``ensure:`` block is intentional.

  ClaudeOutputFormatIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeOutputFormatIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeOutputFormatIntegrationTest >> defaultTimeLimit [
	"One live round-trip to api.anthropic.com plus generation time. The
	 default 10 s test timeout fires before a healthy round-trip
	 completes. 2 minutes matches other integration tests in this package."
	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeOutputFormatIntegrationTest >> testJsonSchemaOutputFormatProducesConformingJsonAgainstAnthropic [
	"Drive a live sendMessage: call against api.anthropic.com with a
	 ClaudeJsonSchemaOutputFormat that requires a
	 { name: string, age: integer } shape. Parse the response text as
	 JSON and assert server-computed schema conformance:
	  - stopReason = #end_turn (clean completion)
	  - textContent non-empty (something came back)
	  - parsed JSON has name as a String
	  - parsed JSON has age as an Integer
	 Server-side schema enforcement is the point: no client-side
	 validation could prove this because the model could otherwise
	 emit free-form prose.
	 JSON field access uses at:ifAbsent: so a missing key fails the
	 downstream isKindOf: assertion with its description rather than
	 erroring on KeyNotFound.
	 Skips cleanly when no API key is present."
	| client response text parsed name age |
	client := [ ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingOutputFormatExample runOn: client.
	text := response textContent.
	self
		assert: response stopReason = #end_turn
		description: 'server must complete generation cleanly (stopReason = #end_turn)'.
	self
		assert: text isNotEmpty
		description: 'response must carry non-empty text content'.
	parsed := STONJSON fromString: text.
	name := parsed at: 'name' ifAbsent: [ nil ].
	age := parsed at: 'age' ifAbsent: [ nil ].
	self
		assert: (name isKindOf: String)
		description: 'response JSON must have name as a String; got ' , name printString.
	self
		assert: (age isKindOf: Integer)
		description: 'response JSON must have age as an Integer; got ' , age printString
]
