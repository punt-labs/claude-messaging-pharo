"
Demonstrate the interleaved-thinking pattern: multi-turn tool-use
where the assistant emits a thinking block in EACH assistant turn, not
only before the final answer.

This is a STRUCTURAL example showing the wire shape of an
interleaved-thinking REQUEST. It is not directly sendable: the
thinking blocks carry placeholder cryptographic signatures
(``sig-turn1-...``, ``sig-turn2-...``) chosen for clarity in the
``>>>`` doctest. Anthropic's servers verify each signature against
the corresponding thinking content; sending a request with
fabricated signatures returns a 400. A real interleaved-thinking
conversation captures genuine signatures from a prior live response
and replays those values verbatim on the next request.

This shape requires the ``interleaved-thinking-2025-05-14`` beta header.
Without the beta the model will only think before the final answer; with
it the model may reason between tool calls. The pattern matters for
tool-use-heavy agents where the choice of the next tool call depends on
analysis of the previous tool result.

The example builds a 5-message conversation:

  1. user      - ""What is the weather in Paris and the time in Tokyo?""
  2. assistant - thinking + tool_use(get_weather, Paris)
  3. user      - tool_result for call 1 (""Sunny, 18 C"")
  4. assistant - thinking + tool_use(get_time, Tokyo)
  5. user      - tool_result for call 2 (""14:00 JST"")

Sending this request asks the model to produce a sixth turn: a thinking
block plus the final synthesized text answer. The two assistant turns
each carry their own thinking block, which is the interleaved shape.

The previous-turn thinking blocks carry server-issued cryptographic
signatures that the SDK preserves verbatim through asJson serialization
(see ClaudeThinkingBlockTest>>testSignatureRoundTrip). Replaying these
turns to the model without the signature would cause the API to reject
the request.

  ClaudeInterleavedThinkingExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeInterleavedThinkingExample buildRequest messages size
  >>> 5

  ClaudeInterleavedThinkingExample buildRequest requestOptions betas first
  >>> 'interleaved-thinking-2025-05-14'

"
Class {
	#name : 'ClaudeInterleavedThinkingExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeInterleavedThinkingExample class >> buildRequest [
	"Build the multi-turn interleaved-thinking request. The conversation
	 records two completed assistant turns each carrying a thinking block
	 and a tool_use block, with tool_result turns between them. Sending
	 this request to a Claude 4 model with the interleaved-thinking beta
	 active asks the model to produce a sixth turn — a thinking block
	 plus the final synthesized text answer.
	
	 The thinking blocks carry server-issued cryptographic signatures
	 (here illustrated with placeholder strings — a real conversation
	 round-trips the values verbatim from prior responses). asJson
	 serialization preserves the signature on each thinking block; see
	 ClaudeThinkingBlockTest>>testSignatureRoundTrip."
	| req turn1 weatherCall turn2 timeCall |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 2048.
	req thinking: (ClaudeThinkingParams enabled: 1024) asDictionary.
	req betas: { ClaudeBetaHeader interleavedThinking }.
	req tools: { self weatherTool. self timeTool }.
	
	"User asks a question that requires two distinct tool calls."
	req addUserMessage: 'What is the weather in Paris and the local time in Tokyo?'.
	
	"First assistant turn: think, then call get_weather. Both blocks
	 belong to the same assistant message — interleaved-thinking only
	 changes the *number* of assistant turns that may carry a thinking
	 block, not their internal ordering."
	weatherCall := ClaudeToolUseBlock
		id: 'toolu_01weather'
		name: 'get_weather'
		input: (Dictionary newFromPairs: { 'city'. 'Paris' }).
	turn1 := ClaudeMessage new
		turn: (ClaudeTurn role: 'assistant' content: {
			ClaudeThinkingBlock new
				thinking: 'The user asks for two facts. Start with weather.';
				signature: 'sig-turn1-replayed-from-prior-response';
				yourself.
			weatherCall });
		yourself.
	req addAssistantResponse: turn1.
	
	"User echoes the tool result back."
	req addToolResult: 'toolu_01weather' content: 'Sunny, 18 C'.
	
	"Second assistant turn: think AGAIN, then call get_time. Two
	 thinking blocks across two assistant turns is the interleaved
	 pattern — without the beta the model would only emit thinking
	 once before the final text answer."
	timeCall := ClaudeToolUseBlock
		id: 'toolu_02time'
		name: 'get_time'
		input: (Dictionary newFromPairs: { 'city'. 'Tokyo' }).
	turn2 := ClaudeMessage new
		turn: (ClaudeTurn role: 'assistant' content: {
			ClaudeThinkingBlock new
				thinking: 'Weather done. Now look up the Tokyo time.';
				signature: 'sig-turn2-replayed-from-prior-response';
				yourself.
			timeCall });
		yourself.
	req addAssistantResponse: turn2.
	
	"User echoes the second tool result."
	req addToolResult: 'toolu_02time' content: '14:00 JST'.
	
	^ req
]

{ #category : 'private' }
ClaudeInterleavedThinkingExample class >> resolveClient [
	"Resolve a ClaudeClient via the shared example-support facade.
	 Used by run."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeInterleavedThinkingExample class >> run [
	"Send the multi-turn interleaved-thinking request and return the
	 response. Requires ANTHROPIC_API_KEY (env or keyring) and the
	 interleaved-thinking-2025-05-14 beta on the calling key.

	 NOTE: this is a STRUCTURAL example. ClaudeInterleavedThinkingExample
	 buildRequest carries placeholder thinking signatures
	 (sig-turn1-..., sig-turn2-...) — Anthropic's servers verify each
	 signature against the corresponding thinking content and will
	 return 400 for fabricated values. Use this method only after
	 substituting genuine signatures captured from a prior live
	 response. The example exists to document the request shape; an
	 end-to-end live invocation requires a real conversation history."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeInterleavedThinkingExample class >> runOn: aClient [
	"Send the multi-turn request via the supplied client. The response
	 carries a third assistant turn — a thinking block plus the final
	 text answer synthesizing the two tool results.

	 NOTE: see #run — buildRequest uses placeholder signatures that
	 will be rejected by Anthropic's signature verification. Replace
	 with genuine signatures from a prior live response before
	 expecting a 200 here."
	^ aClient sendMessage: self buildRequest
]

{ #category : 'tools' }
ClaudeInterleavedThinkingExample class >> timeTool [
	"The second tool — looks up local time by city. Same one-property
	 schema as weatherTool. Used for the Tokyo call in the second
	 assistant turn."
	| schema |
	schema := ClaudeToolInputSchema new.
	schema addProperty: 'city' type: 'string' description: 'City name, e.g. Tokyo'.
	schema required: #('city').
	^ ClaudeTool
		name: 'get_time'
		description: 'Get current local time for a named city.'
		inputSchema: schema
]

{ #category : 'tools' }
ClaudeInterleavedThinkingExample class >> weatherTool [
	"The first tool — looks up weather by city. Schema is a single
	 required string property `city`. The example uses this tool for the
	 Paris call in the first assistant turn."
	| schema |
	schema := ClaudeToolInputSchema new.
	schema addProperty: 'city' type: 'string' description: 'City name, e.g. Paris'.
	schema required: #('city').
	^ ClaudeTool
		name: 'get_weather'
		description: 'Get current weather for a named city.'
		inputSchema: schema
]
