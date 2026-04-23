"
Demonstrate JSON-schema-constrained structured output. Builds a request whose ``output_config.format`` is a ``ClaudeJsonSchemaOutputFormat`` describing a ``{ name: string, age: integer }`` schema — the server then constrains the model to emit a JSON object matching that shape rather than free-form prose.

Use this when you need machine-parseable output from the model (downstream code parses the response text as JSON and treats it as structured data). Prefer this over asking the model politely to emit JSON in the user prompt: the server-side constraint is enforced during generation, not validated after the fact. For plain prose responses (chat, explanations, summaries) leave ``outputConfig`` at its default — setting a schema adds latency and constrains creativity.

**What comes back.** The response is a plain ``ClaudeMessage`` whose assistant text block carries the JSON payload as a string — not a structured response object. Callers parse it with ``STONJSON fromString: response textContent`` to get a ``Dictionary`` whose keys and value types match the schema configured via ``ClaudeJsonSchemaOutputFormat``. The schema itself is built with ``ClaudeToolInputSchema`` (same builder used for tool input schemas).

  ClaudeMessagingOutputFormatExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingOutputFormatExample buildRequest maxTokens
  >>> 256

  ClaudeMessagingOutputFormatExample buildRequest outputFormat class
  >>> ClaudeJsonSchemaOutputFormat

  (ClaudeMessagingOutputFormatExample buildRequest outputFormat schema
    properties includesKey: 'age')
  >>> true

  ClaudeMessagingOutputFormatExample buildRequest messages size
  >>> 1

Live end-to-end coverage lives in ``ClaudeOutputFormatIntegrationTest``, which parses the response text as JSON and asserts ``name`` is a ``String`` and ``age`` is an ``Integer`` — server-computed schema conformance.
"
Class {
	#name : 'ClaudeMessagingOutputFormatExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingOutputFormatExample class >> buildRequest [
	"Build a request that constrains the model to emit JSON matching
	 a simple person schema (name: String, age: Integer). Uses
	 ClaudeJsonSchemaOutputFormat to enforce the shape server-side —
	 the integration test parses the response text as JSON and asserts
	 the schema-conforming fields have the right types."
	| req schema |
	schema := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'Person full name';
		addProperty: 'age' type: 'integer' description: 'Person age in years';
		require: 'name';
		require: 'age';
		yourself.
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 256.
	req outputFormat: (ClaudeJsonSchemaOutputFormat schema: schema).
	req addUserMessage: 'Give me a person record for Marie Curie.'.
	^ req
]

{ #category : 'private' }
ClaudeMessagingOutputFormatExample class >> resolveClient [
	"Resolve a live ClaudeClient via shared example support."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingOutputFormatExample class >> run [
	"Send the example request using a resolved client and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingOutputFormatExample class >> runOn: aClient [
	"Send the JSON-schema output-format example request using the
	 given client and return the response. The response textContent
	 parses as JSON matching the schema in buildRequest."
	^ aClient sendMessage: self buildRequest
]
