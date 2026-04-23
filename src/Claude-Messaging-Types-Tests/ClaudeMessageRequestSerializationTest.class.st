"
Tests for ClaudeMessageRequest top-level asJson wire format — basic serialization, nil omission, stream flag, system prompts, service tier.
"
Class {
	#name : 'ClaudeMessageRequestSerializationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testAsJsonIncludesSuffix [
  "End-to-end: set format, verify system in JSON includes suffix."
  | req json suffix |
  req := ClaudeMessageRequest new.
  req model: 'test'.
  req maxTokens: 100.
  req system: 'Be concise'.
  req outputConfig format: ClaudeTextOutputFormat logDefault.
  req addUserMessage: 'Hi'.
  json := req asJson.
  suffix := ClaudeTextOutputFormat logDefault systemPromptSuffix.
  self assert: (json at: 'system') isString.
  self assert: ((json at: 'system') includesSubstring: 'Be concise').
  self assert: ((json at: 'system') includesSubstring: suffix)
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testBasicAsJson [
	| params json msgJson |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	json := params asJson.
	self assert: (json at: 'model') equals: 'claude-sonnet-4-20250514'.
	self assert: (json at: 'max_tokens') equals: 1024.
	self assert: (json at: 'messages') size equals: 1.
	msgJson := (json at: 'messages') first.
	self assert: (msgJson at: 'role') equals: 'user'.
	self assert: (msgJson at: 'content') size equals: 1.
	self assert: ((msgJson at: 'content') first at: 'type') equals: 'text'.
	self assert: ((msgJson at: 'content') first at: 'text') equals: 'Hello'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testBetaHeaderCoexistsWithMcpServers [
	| req json |
	req := ClaudeMessageRequest new.
	req model: 'test'; maxTokens: 100; addUserMessage: 'hi'.
	req betas: #('mcp-client-2025-04-04').
	req mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://x.com' }.
	self assert: req requestOptions betaHeader equals: 'mcp-client-2025-04-04'.
	json := req asJson.
	self assert: (json at: 'mcp_servers') size equals: 1
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithBlockArraySystem [
  "Block-array system + format: appends a ClaudeTextBlock, not a Dictionary."
  | req blocks result suffix |
  blocks := { ClaudeTextBlock text: 'Instructions' }.
  req := ClaudeMessageRequest new.
  req systemBlocks: blocks.
  req outputConfig format: ClaudeTextOutputFormat pharoDefault.
  result := req composedSystem.
  suffix := ClaudeTextOutputFormat pharoDefault systemPromptSuffix.
  self assert: result size equals: 2.
  self assert: (result last isKindOf: ClaudeTextBlock).
  self assert: result last text equals: suffix
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithEmptySuffix [
  "Format with no encoding/markup constraints: returns system unchanged."
  | req fmt |
  fmt := ClaudeTextOutputFormat new encoding: #utf8.
  req := ClaudeMessageRequest new.
  req system: 'You are helpful'.
  req outputConfig format: fmt.
  self assert: req composedSystem equals: 'You are helpful'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithJsonSchemaFormat [
  "JSON schema format has no systemPromptSuffix: returns system unchanged."
  | req |
  req := ClaudeMessageRequest new.
  req system: 'You are helpful'.
  req outputConfig format: (ClaudeJsonSchemaOutputFormat schema: ClaudeToolInputSchema new).
  self assert: req composedSystem equals: 'You are helpful'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithNilSystem [
  "Nil system + format with suffix: composedSystem returns suffix string."
  | req |
  req := ClaudeMessageRequest new.
  req outputConfig format: ClaudeTextOutputFormat logDefault.
  self assert: req composedSystem equals: 'Respond using only ASCII characters (U+0000-U+007F). No accented characters, no emoji, no Unicode. No markup formatting. Plain text only.'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithNoFormat [
  "No output format set: composedSystem returns system unchanged."
  | req |
  req := ClaudeMessageRequest new.
  req system: 'You are helpful'.
  self assert: req composedSystem equals: 'You are helpful'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testComposedSystemWithStringSystem [
  "String system + format with suffix: appends with cr cr separator."
  | req result suffix |
  req := ClaudeMessageRequest new.
  req system: 'You are helpful'.
  req outputConfig format: ClaudeTextOutputFormat pharoDefault.
  result := req composedSystem.
  suffix := ClaudeTextOutputFormat pharoDefault systemPromptSuffix.
  self assert: result equals: ('You are helpful', String cr, String cr, suffix)
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testEmptyGroupAddsNothing [
	| dict |
	dict := OrderedDictionary new.
	ClaudeSamplingParams new addFieldsTo: dict.
	ClaudeToolParams new addFieldsTo: dict.
	ClaudeThinkingParams new addFieldsTo: dict.
	ClaudeRequestOptions new addFieldsTo: dict.
	self assert: dict isEmpty
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testJsonKeyMap [
	| map |
	map := ClaudeMessageRequest jsonKeyMap.
	self assert: (map at: #maxTokens) equals: 'max_tokens'.
	self assert: map size equals: 1
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testMcpServersAppearsInAsJson [
	| req json mcp |
	req := ClaudeMessageRequest new.
	req model: 'test'; maxTokens: 100; addUserMessage: 'hi'.
	req mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://x.com' }.
	json := req asJson.
	mcp := json at: 'mcp_servers'.
	self assert: mcp size equals: 1.
	self assert: (mcp first at: 'name') equals: 'example'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testMcpServersDelegatesToRequestOptions [
	| req servers |
	servers := { ClaudeMCPServerDefinition name: 'example' url: 'https://x.com' }.
	req := ClaudeMessageRequest new.
	req mcpServers: servers.
	self assert: req mcpServers identicalTo: req requestOptions mcpServers.
	self assert: req mcpServers size equals: 1
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testMessagesAreUniformType [
	"All entries in the messages collection are ClaudeMessage objects."
	| params |
	params := ClaudeMessageRequest new.
	params addUserMessage: 'Hello'.
	params addAssistantMessage: 'Hi there'.
	params addToolResult: 'toolu_01ABC' content: '42'.
	params addToolResult: 'toolu_01XYZ' content: 'error' isError: true.
	params addUserContent: { ClaudeTextBlock text: 'Image?'. ClaudeImageBlock base64: 'abc' mediaType: 'image/png' }.
	params addAssistantResponse: (ClaudeMessage new role: #assistant; content: { ClaudeTextBlock text: 'Done' }; yourself).
	self assert: params messages size equals: 6.
	params messages do: [ :msg |
		self assert: (msg isKindOf: ClaudeMessage) description: 'All messages must be ClaudeMessage objects' ]
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testNilOmission [
	| params json |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hi'.
	json := params asJson.
	"Required fields present"
	self assert: (json includesKey: 'model').
	self assert: (json includesKey: 'max_tokens').
	self assert: (json includesKey: 'messages').
	"Optional fields absent when nil"
	self deny: (json includesKey: 'system').
	self deny: (json includesKey: 'tools').
	self deny: (json includesKey: 'tool_choice').
	self deny: (json includesKey: 'thinking').
	self deny: (json includesKey: 'temperature').
	self deny: (json includesKey: 'top_p').
	self deny: (json includesKey: 'top_k').
	self deny: (json includesKey: 'stop_sequences').
	self deny: (json includesKey: 'stream').
	self deny: (json includesKey: 'metadata').
	self deny: (json includesKey: 'cache_control').
	self deny: (json includesKey: 'service_tier')
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testServiceTierSerialization [
	"Test that serviceTier is properly serialized to JSON"
	| request json |
	request := ClaudeMessageRequest new.
	request model: 'claude-3-5-sonnet-20241022'.
	request messages: { ClaudeMessage userMessage: 'Hello' }.
	request serviceTier: 'batch'.
	
	json := request asJson.
	self assert: (json at: 'service_tier') equals: 'batch'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testStreamFlag [
	| params json |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hi'.
	"Default: stream is false, not in JSON"
	json := params asJson.
	self deny: (json includesKey: 'stream').
	"Set to true: appears in JSON"
	params stream: true.
	json := params asJson.
	self assert: (json at: 'stream') equals: true
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testStreamNil [
	| params json |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5'.
	params maxTokens: 1024.
	params stream: nil.
	self assert: params stream equals: false.
	params addUserMessage: 'test'.
	json := params asJson.
	self deny: (json includesKey: 'stream')
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testStringSystemPromptSerialization [
	| req json |
	req := ClaudeMessageRequest new
		model: 'test';
		maxTokens: 100;
		system: 'You are helpful';
		addUserMessage: 'Hi'.
	json := req asJson.
	self assert: (json at: 'system') equals: 'You are helpful'.
	self assert: (json at: 'system') isString
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testStructuredSystemPromptMultipleBlocks [
	| req b1 b2 json sysBlocks |
	b1 := ClaudeTextBlock text: 'System instructions'.
	b1 cacheControl: ClaudeCacheControl ephemeral.
	b2 := ClaudeTextBlock text: 'Additional context'.
	req := ClaudeMessageRequest new
		model: 'test';
		maxTokens: 100;
		addUserMessage: 'Hi'.
	req systemBlocks: { b1. b2 }.
	json := req asJson.
	sysBlocks := json at: 'system'.
	self assert: sysBlocks size equals: 2.
	self assert: (sysBlocks first at: 'text') equals: 'System instructions'.
	self assert: (sysBlocks first includesKey: 'cache_control').
	self assert: (sysBlocks second at: 'text') equals: 'Additional context'.
	self deny: (sysBlocks second includesKey: 'cache_control')
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testStructuredSystemPromptSerialization [
	| req block json sysBlocks |
	block := ClaudeTextBlock text: 'You are helpful'.
	block cacheControl: ClaudeCacheControl ephemeral.
	req := ClaudeMessageRequest new
		model: 'test';
		maxTokens: 100;
		addUserMessage: 'Hi'.
	req systemBlocks: { block }.
	json := req asJson.
	sysBlocks := json at: 'system'.
	self assert: sysBlocks isArray.
	self assert: sysBlocks size equals: 1.
	self assert: (sysBlocks first at: 'type') equals: 'text'.
	self assert: (sysBlocks first at: 'text') equals: 'You are helpful'.
	self assert: ((sysBlocks first at: 'cache_control') at: 'type') equals: 'ephemeral'
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testSystemBlocksConvenienceMethod [
	| req |
	req := ClaudeMessageRequest new.
	req systemBlocks: { ClaudeTextBlock text: 'test' }.
	self assert: req system isArray.
	self assert: req system size equals: 1
]

{ #category : 'tests' }
ClaudeMessageRequestSerializationTest >> testWireFormatWithToolResult [
	"Verify the wire format for tool result messages matches API spec."
	| params json msgs toolMsg |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Use tool'.
	params addToolResult: 'toolu_01ABC' content: '42'.
	json := params asJson.
	msgs := json at: 'messages'.
	self assert: msgs size equals: 2.
	toolMsg := msgs second.
	self assert: (toolMsg at: 'role') equals: 'user'.
	self assert: (toolMsg at: 'content') size equals: 1.
	self assert: ((toolMsg at: 'content') first at: 'type') equals: 'tool_result'.
	self assert: ((toolMsg at: 'content') first at: 'tool_use_id') equals: 'toolu_01ABC'.
	self assert: ((toolMsg at: 'content') first at: 'content') equals: '42'
]
