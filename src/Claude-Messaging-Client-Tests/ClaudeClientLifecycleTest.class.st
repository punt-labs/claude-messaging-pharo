"
Tests for ClaudeClient API methods (sendMessage:, countTokens:, listModels, getModel:) using ClaudeMockServer. Each test starts a mock HTTP server, configures canned responses, exercises the client method, and asserts on the parsed result and captured request. From spec Appendix C.2, bead qn4.
"
Class {
	#name : 'ClaudeClientLifecycleTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeClientLifecycleTest >> messageResponseJson [
	"Canned JSON for a Claude message response."
	^ '{"id": "msg_test123", "type": "message", "role": "assistant", "content": [{"type": "text", "text": "Hello world"}], "model": "claude-sonnet-4-5-20250514", "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 20}}'
]

{ #category : 'fixtures' }
ClaudeClientLifecycleTest >> modelInfoJson [
	"Canned JSON for a single model info response."
	^ '{"id": "claude-sonnet-4-5", "display_name": "Claude 3.5 Sonnet", "max_input_tokens": 200000, "max_tokens": 8192, "type": "model", "created_at": "2025-01-01T00:00:00Z"}'
]

{ #category : 'fixtures' }
ClaudeClientLifecycleTest >> modelsListJson [
	"Canned JSON for a models list response."
	^ '{"data": [{"id": "claude-sonnet-4-5", "display_name": "Claude 3.5 Sonnet", "max_input_tokens": 200000, "max_tokens": 8192, "type": "model", "created_at": "2025-01-01T00:00:00Z"}, {"id": "claude-opus-4-0", "display_name": "Claude 4 Opus", "max_input_tokens": 200000, "max_tokens": 4096, "type": "model", "created_at": "2025-03-01T00:00:00Z"}]}'
]

{ #category : 'testing' }
ClaudeClientLifecycleTest >> newParams [
	"Build minimal ClaudeMessageRequest for testing."
	| params |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	^ params
]

{ #category : 'running' }
ClaudeClientLifecycleTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5.
	client maxRetries: 0
]

{ #category : 'running' }
ClaudeClientLifecycleTest >> tearDown [
	mockServer stop.
	super tearDown
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testCountTokensParsesResponse [
	| result |
	mockServer respondTo: '/v1/messages/count_tokens' with: '{"input_tokens": 42}'.
	result := client countTokens: self newParams.
	self assert: result class equals: ClaudeMessageTokensCount.
	self assert: result inputTokens equals: 42
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testCountTokensPostsToCorrectEndpoint [
	mockServer respondTo: '/v1/messages/count_tokens' with: '{"input_tokens": 1}'.
	client countTokens: self newParams.
	self assert: mockServer lastRequestMethod equals: 'POST'.
	self assert: mockServer lastRequestPath equals: 'v1/messages/count_tokens'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testCountTokensSendsCorrectBody [
	| body |
	mockServer respondTo: '/v1/messages/count_tokens' with: '{"input_tokens": 1}'.
	client countTokens: self newParams.
	body := mockServer lastRequestBody.
	self assert: (body includesKey: 'model').
	self assert: (body includesKey: 'messages').
	self deny: (body includesKey: 'max_tokens')
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testGetModelGetsCorrectEndpoint [
	mockServer respondTo: '/v1/models/claude-sonnet-4-5' with: self modelInfoJson.
	client getModel: 'claude-sonnet-4-5'.
	self assert: mockServer lastRequestMethod equals: 'GET'.
	self assert: mockServer lastRequestPath equals: 'v1/models/claude-sonnet-4-5'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testGetModelParsesResponse [
	| info |
	mockServer respondTo: '/v1/models/claude-sonnet-4-5' with: self modelInfoJson.
	info := client getModel: 'claude-sonnet-4-5'.
	self assert: info class equals: ClaudeModelInfo.
	self assert: info id equals: 'claude-sonnet-4-5'.
	self assert: info displayName equals: 'Claude 3.5 Sonnet'.
	self assert: info maxInputTokens equals: 200000.
	self assert: info maxTokens equals: 8192.
	self assert: info type equals: 'model'.
	self assert: info createdAt equals: '2025-01-01T00:00:00Z'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testGetModelRaisesNotFoundError [
	mockServer respondTo: '/v1/models/bad-model-id' withError: 404 message: 'Model not found'.
	self should: [ client getModel: 'bad-model-id' ]
		raise: ClaudeNotFoundError
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testListModelsParsesResponse [
	| models |
	mockServer respondTo: '/v1/models' with: self modelsListJson.
	models := client listModels.
	self assert: models class equals: OrderedCollection.
	self assert: models size equals: 2.
	self assert: models first class equals: ClaudeModelInfo.
	self assert: models first id equals: 'claude-sonnet-4-5'.
	self assert: models second id equals: 'claude-opus-4-0'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testMessageTokensCountFromJson [
	| result |
	result := ClaudeMessageTokensCount fromJson: (Dictionary newFromPairs: { 'input_tokens'. 99 }).
	self assert: result inputTokens equals: 99.
	self assert: result printString equals: 'ClaudeMessageTokensCount(99)'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testModelInfoFromJson [
	| info |
	info := ClaudeModelInfo fromJson: (STONJSON fromString: self modelInfoJson).
	self assert: info id equals: 'claude-sonnet-4-5'.
	self assert: info displayName equals: 'Claude 3.5 Sonnet'.
	self assert: info maxInputTokens equals: 200000.
	self assert: info maxTokens equals: 8192.
	self assert: info type equals: 'model'.
	self assert: info createdAt equals: '2025-01-01T00:00:00Z'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testModelInfoJsonKeyMap [
	| map |
	map := ClaudeModelInfo jsonKeyMap.
	self assert: (map at: #displayName) equals: 'display_name'.
	self assert: (map at: #maxInputTokens) equals: 'max_input_tokens'.
	self assert: (map at: #maxTokens) equals: 'max_tokens'.
	self assert: (map at: #createdAt) equals: 'created_at'.
	self assert: map size equals: 4
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageErrorHasMessage [
	mockServer respondTo: '/v1/messages' withError: 401 message: 'Your API key is invalid'.
	[ client sendMessage: self newParams ]
		on: ClaudeAuthError
		do: [ :err |
			self assert: err message equals: 'Your API key is invalid'.
			^ self ].
	self fail: 'Expected ClaudeAuthError'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageErrorHasRequestId [
	mockServer respondTo: '/v1/messages' withError: 401 message: 'Invalid API key' requestId: 'req-test-abc123'.
	[ client sendMessage: self newParams ]
		on: ClaudeAuthError
		do: [ :err |
			self assert: err requestId equals: 'req-test-abc123'.
			^ self ].
	self fail: 'Expected ClaudeAuthError'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageParsesResponse [
	| msg |
	mockServer respondTo: '/v1/messages' with: self messageResponseJson.
	msg := client sendMessage: self newParams.
	self assert: msg id equals: 'msg_test123'.
	self assert: msg role equals: #assistant.
	self assert: msg textContent equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessagePostsToCorrectEndpoint [
	mockServer respondTo: '/v1/messages' with: self messageResponseJson.
	client sendMessage: self newParams.
	self assert: mockServer lastRequestMethod equals: 'POST'.
	self assert: mockServer lastRequestPath equals: 'v1/messages'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageRaisesAuthError [
	mockServer respondTo: '/v1/messages' withError: 401 message: 'Invalid API key'.
	self should: [ client sendMessage: self newParams ]
		raise: ClaudeAuthError
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageRaisesNotFoundError [
	mockServer respondTo: '/v1/messages' withError: 404 message: 'Not found'.
	self should: [ client sendMessage: self newParams ]
		raise: ClaudeNotFoundError
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageRaisesRateLimitError [
	mockServer respondTo: '/v1/messages' withError: 429 message: 'Rate limit exceeded'.
	self should: [ client sendMessage: self newParams ]
		raise: ClaudeRateLimitError
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageRaisesServerError [
	mockServer respondTo: '/v1/messages' withError: 500 message: 'Internal server error'.
	self should: [ client sendMessage: self newParams ]
		raise: ClaudeServerError
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageSendsCorrectHeaders [
	| headers |
	mockServer respondTo: '/v1/messages' with: self messageResponseJson.
	client sendMessage: self newParams.
	headers := mockServer lastRequestHeaders.
	self assert: (headers at: 'x-api-key') equals: 'test-key'.
	self assert: (headers at: 'anthropic-version') equals: '2023-06-01'.
	self assert: (headers at: 'Content-Type') equals: 'application/json'
]

{ #category : 'tests' }
ClaudeClientLifecycleTest >> testSendMessageSendsJsonBody [
	| body |
	mockServer respondTo: '/v1/messages' with: self messageResponseJson.
	client sendMessage: self newParams.
	body := mockServer lastRequestBody.
	self assert: (body at: 'model') equals: 'claude-sonnet-4-5-20250514'.
	self assert: (body at: 'max_tokens') equals: 1024.
	self assert: (body at: 'messages') size equals: 1
]
