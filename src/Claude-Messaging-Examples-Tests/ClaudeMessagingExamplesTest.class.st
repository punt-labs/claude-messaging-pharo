"
Structural tests for the non-server-tool Messaging SDK example classes (output format, request options, raw streaming, interleaved thinking). Each test verifies request construction without making API calls — the live wire behaviour lives in the corresponding ``*IntegrationTest`` class in ``Claude-Messaging-Client-Tests`` (out of scope for ``make test``), or in the ``integration-`` protocol methods on this class (skipped from the fast suite by the SUnit ``test`` prefix convention).

Separate from ``ClaudeServerToolExamplesTest`` because these examples are not server-tool examples — they demonstrate generic request-shaping features (``output_config.format``, ``request_options``, raw streaming socket usage, interleaved-thinking multi-turn).

  ClaudeMessagingExamplesTest buildSuite tests size
  >>> 4

"
Class {
	#name : 'ClaudeMessagingExamplesTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'integration - skipped from fast suite' }
ClaudeMessagingExamplesTest >> integrationInterleavedThinkingExampleSendsRequest [
	"Manual-invocation placeholder only. The interleaved-thinking example
	 request used by the structural tests contains replay signatures that
	 are documented as placeholders, so sending it directly to the live
	 API is expected to fail server-side signature verification. A real
	 end-to-end integration check must first obtain genuine assistant
	 thinking blocks (and their signatures) from a prior response, then
	 replay those blocks in a follow-up request."
	| client response |
	self skip:
		'ClaudeInterleavedThinkingExample buildRequest uses placeholder thinking signatures. Capture real assistant thinking blocks and signatures from a prior live response before adding an end-to-end integration assertion.'.
	client := ClaudeSDKExampleSupport resolveClient.
	response := ClaudeInterleavedThinkingExample runOn: client.
	self assert: response content notEmpty
]

{ #category : 'tests' }
ClaudeMessagingExamplesTest >> testInterleavedThinkingExampleStructure [
	"Unit-level shape test for ClaudeInterleavedThinkingExample. Verifies
	 the request carries 5 messages (user, assistant, user, assistant,
	 user), the interleaved-thinking beta is wired, both assistant turns
	 carry a thinking block AND a tool_use block, and the wire form
	 preserves the placeholder signatures byte-for-byte."
	| request json msgArr asst1 asst2 |
	request := ClaudeInterleavedThinkingExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46.
	self assert: request maxTokens equals: 2048.
	self assert: request messages size equals: 5.
	self assert: request requestOptions betas first
		equals: ClaudeBetaHeader interleavedThinking.
	self assert: request tools size equals: 2.
	"Both assistant turns carry thinking + tool_use, in that order."
	asst1 := request messages second.
	asst2 := request messages fourth.
	self assert: asst1 turn content first isThinkingBlock.
	self assert: asst1 turn content second isToolUseBlock.
	self assert: asst2 turn content first isThinkingBlock.
	self assert: asst2 turn content second isToolUseBlock.
	"Wire form preserves both signatures byte-for-byte."
	json := request asJson.
	msgArr := json at: 'messages'.
	self assert: (((msgArr second) at: 'content') first at: 'signature')
		equals: 'sig-turn1-replayed-from-prior-response'.
	self assert: (((msgArr fourth) at: 'content') first at: 'signature')
		equals: 'sig-turn2-replayed-from-prior-response'
]

{ #category : 'tests' }
ClaudeMessagingExamplesTest >> testOutputFormatExampleConfiguresFormat [
	"Verify the OutputFormatExample wires a ClaudeJsonSchemaOutputFormat
	 on the request and the schema requires name + age."
	| request format |
	request := ClaudeMessagingOutputFormatExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46.
	format := request outputFormat.
	self assert: (format isKindOf: ClaudeJsonSchemaOutputFormat).
	self assert: (format schema properties includesKey: 'name').
	self assert: (format schema properties includesKey: 'age').
	self assert: (format schema required includes: 'name').
	self assert: (format schema required includes: 'age')
]

{ #category : 'tests' }
ClaudeMessagingExamplesTest >> testRawStreamingExampleBuildsRequest [
	"Verify the RawStreamingExample produces a streaming-enabled
	 request with the canonical sonnet46 model."
	| request |
	request := ClaudeMessagingRawStreamingExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46.
	self assert: request stream.
	self assert: request maxTokens equals: 50.
	self assert: request messages size equals: 1
]

{ #category : 'tests' }
ClaudeMessagingExamplesTest >> testRequestOptionsExampleConfiguresOptions [
	"Verify the RequestOptionsExample sets both metadata and
	 serviceTier on requestOptions."
	| request options |
	request := ClaudeMessagingRequestOptionsExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46.
	options := request requestOptions.
	self assert: options serviceTier equals: 'auto'.
	self assert: (options metadata at: 'user_id') equals: 'sdk-test-user'
]
