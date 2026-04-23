"
Tests for ClaudeClient streaming methods (streamMessage:do: and streamRawBody:) using ClaudeMockServer with canned SSE responses. From spec Appendix C.3.4, bead okv.
"
Class {
	#name : 'ClaudeClientStreamingTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'testing' }
ClaudeClientStreamingTest >> newParams [
	"Build minimal ClaudeMessageRequest for testing."
	| params |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	^ params
]

{ #category : 'running' }
ClaudeClientStreamingTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	mockServer respondTo: '/v1/messages' withSSE: self sseResponseBody.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5
]

{ #category : 'fixtures' }
ClaudeClientStreamingTest >> sseErrorResponseBody [
	"Canned SSE response body for an overloaded_error event. The API can
	send an error event at any point during a stream; see bead 8x5."

	^ 'event: error
data: {"type":"error","error":{"type":"overloaded_error","message":"stream overloaded"}}

'
]

{ #category : 'fixtures' }
ClaudeClientStreamingTest >> sseResponseBody [
	"Canned SSE response body for a simple Hello world streaming response."
	^ 'event: message_start
data: {"type":"message_start","message":{"id":"msg_01","type":"message","role":"assistant","content":[],"model":"claude-sonnet-4-5","stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":10,"output_tokens":0}}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" world"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_delta
data: {"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":5}}

event: message_stop
data: {"type":"message_stop"}

'
]

{ #category : 'running' }
ClaudeClientStreamingTest >> tearDown [
	mockServer stop.
	super tearDown
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testBetaHeaderSentToServer [
	| params |
	params := self newParams.
	params betas: #('pdfs-2024-09-25' 'output-128k-2025-02-19').
	client streamMessage: params do: [ :event | ].
	self assert: (mockServer lastRequestHeaders includesKey: 'anthropic-beta').
	self assert: (mockServer lastRequestHeaders at: 'anthropic-beta') equals: 'pdfs-2024-09-25,output-128k-2025-02-19'
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamMessageAccumulatesMessage [
	"After streaming, returned ClaudeMessage has correct text and stop reason."
	| msg |
	msg := client streamMessage: self newParams do: [ :event | ].
	self assert: msg textContent equals: 'Hello world'.
	self assert: msg stopReason equals: #end_turn
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamMessageCallsBlock [
	| events |
	events := OrderedCollection new.
	client streamMessage: self newParams do: [ :event |
		events add: event ].
	self assert: events size >= 7.
	self assert: (events first at: 'event') equals: 'message_start'.
	self assert: (events last at: 'event') equals: 'message_stop'
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamMessageRaisesOnErrorEvent [
	"Integration test for bead 8x5 round 2. An error event arriving
	mid-stream must propagate as the matching ClaudeApiError subclass
	with statusCode populated from the reverse mapping."

	| caught |
	mockServer respondTo: '/v1/messages' withSSE: self sseErrorResponseBody.
	caught := nil.
	[ client streamMessage: self newParams do: [ :event | ] ]
		on: ClaudeApiError
		do: [ :e | caught := e ].
	self assert: caught notNil description: 'expected ClaudeApiError to be raised'.
	self assert: caught class equals: ClaudeOverloadedError.
	self assert: caught statusCode equals: 529.
	self assert: caught message equals: 'stream overloaded'.
	self assert: caught isRetryable
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamMessageSetsStreamTrue [
	"Verify the mock received a request body containing stream: true."
	| body |
	client streamMessage: self newParams do: [ :event | ].
	body := mockServer lastRequestBody.
	self assert: (body at: 'stream') equals: true
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamMessageUsesStreamingTimeout [
	"Streaming methods use streamingTimeout (300s default) not timeout (120s default).
	 Verify the defaults differ and the streaming request completes with custom streamingTimeout."
	| msg |
	client streamingTimeout: 2.
	msg := client streamMessage: self newParams do: [ :event | ].
	self assert: msg textContent equals: 'Hello world'.
	"Confirm defaults encode the design intent"
	self assert: ClaudeClient new streamingTimeout equals: 300.
	self assert: ClaudeClient new timeout equals: 120
]

{ #category : 'tests' }
ClaudeClientStreamingTest >> testStreamRawBody [
	"streamRawBody: returns the raw SSE response body as a String."
	| raw |
	raw := client streamRawBody: self newParams.
	self assert: raw isString.
	self assert: (raw includesSubstring: 'event: message_start').
	self assert: (raw includesSubstring: 'event: message_stop').
	self assert: (raw includesSubstring: 'Hello').
	self assert: (raw includesSubstring: ' world')
]
