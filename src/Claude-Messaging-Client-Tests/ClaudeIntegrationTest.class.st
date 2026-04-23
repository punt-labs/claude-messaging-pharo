"
End-to-end integration tests against the real Claude API. Requires an API key in the system keyring. Tests assert prerequisites and fail clearly when missing; they are excluded from make test. Uses claude-3-haiku (cheapest model) with low maxTokens to minimize cost.

  ClaudeIntegrationTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'private' }
ClaudeIntegrationTest >> apiKey [
	^ [ LibC resultOfCommand: 'secret-tool lookup service pharo anthropic api-key' ]
		on: Error do: [ :e | nil ]
]

{ #category : 'private' }
ClaudeIntegrationTest >> modelId [
	"Cheapest available model for integration tests"
	^ 'claude-3-haiku-20240307'
]

{ #category : 'private' }
ClaudeIntegrationTest >> newParams: prompt maxTokens: max [
	| params |
	params := ClaudeMessageRequest new.
	params model: self modelId.
	params maxTokens: max.
	params addUserMessage: prompt.
	^ params
]

{ #category : 'running' }
ClaudeIntegrationTest >> setUp [
	| key |
	super setUp.
	key := self apiKey.
	self assert: key isNotNil description: 'No API key available. Integration tests require a live API key.'.
	key := key trimBoth.
	self assert: key isNotEmpty description: 'API key is empty. Integration tests require a live API key.'.
	client := ClaudeClient apiKey: key.
	Transcript
		nextPutAll: '=== ';
		nextPutAll: self selector;
		nextPutAll: ' ===';
		cr
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testCountTokens [
	| params result |
	params := self newParams: 'Hello' maxTokens: 50.
	Transcript nextPutAll: '>> testCountTokens: counting tokens...'; cr.
	result := client countTokens: params.
	Transcript
		nextPutAll: '<< Token count: ';
		nextPutAll: result inputTokens printString;
		nextPutAll: ' input tokens';
		cr.
	self assert: (result isKindOf: ClaudeMessageTokensCount).
	self assert: result inputTokens > 0
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testErrorInvalidKey [
	| badClient params |
	badClient := ClaudeClient apiKey: 'sk-invalid'.
	params := ClaudeMessageRequest new.
	params model: self modelId.
	params maxTokens: 50.
	params addUserMessage: 'Hello'.
	Transcript nextPutAll: '>> testErrorInvalidKey: expecting 401...'; cr.
	self
		should: [ badClient sendMessage: params ]
		raise: ClaudeAuthError
		withExceptionDo: [ :e |
			Transcript
				nextPutAll: '<< Caught: ';
				nextPutAll: e class name;
				nextPutAll: ' (';
				nextPutAll: e statusCode printString;
				nextPutAll: ')';
				cr.
			self assert: e statusCode equals: 401 ]
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testErrorUnknownModel [
	| params |
	params := ClaudeMessageRequest new.
	params model: 'nonexistent-model-xyz'.
	params maxTokens: 50.
	params addUserMessage: 'Hello'.
	Transcript nextPutAll: '>> testErrorUnknownModel: expecting 404...'; cr.
	self
		should: [ client sendMessage: params ]
		raise: ClaudeNotFoundError
		withExceptionDo: [ :e |
			Transcript
				nextPutAll: '<< Caught: ';
				nextPutAll: e class name;
				nextPutAll: ' (';
				nextPutAll: e statusCode printString;
				nextPutAll: ')';
				cr ]
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testListModels [
	| models |
	Transcript nextPutAll: '>> testListModels: fetching model list...'; cr.
	models := client listModels.
	Transcript
		nextPutAll: '<< Listed: ';
		nextPutAll: models size printString;
		nextPutAll: ' models';
		cr.
	self assert: (models isKindOf: OrderedCollection).
	self deny: models isEmpty.
	self assert: (models allSatisfy: [ :m | m isKindOf: ClaudeModelInfo ]).
	self assert: (models anySatisfy: [ :m | m id includesSubstring: 'claude' ])
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testMultiTurnConversation [
	| params firstResponse secondResponse |
	params := self newParams: 'What is 2+2? Reply with just the number.' maxTokens: 50.
	Transcript nextPutAll: '>> testMultiTurnConversation: sending first turn...'; cr.
	firstResponse := client sendMessage: params.
	Transcript
		nextPutAll: '<< Turn 1: ';
		nextPutAll: firstResponse textContent size printString;
		nextPutAll: ' chars, ';
		nextPutAll: firstResponse usage inputTokens printString;
		nextPutAll: ' in / ';
		nextPutAll: firstResponse usage outputTokens printString;
		nextPutAll: ' out tokens';
		cr.
	params addAssistantResponse: firstResponse.
	params addUserMessage: 'And what is that times 3? Reply with just the number.'.
	Transcript nextPutAll: '>> testMultiTurnConversation: sending second turn...'; cr.
	secondResponse := client sendMessage: params.
	Transcript
		nextPutAll: '<< Turn 2: ';
		nextPutAll: secondResponse textContent size printString;
		nextPutAll: ' chars, ';
		nextPutAll: secondResponse usage inputTokens printString;
		nextPutAll: ' in / ';
		nextPutAll: secondResponse usage outputTokens printString;
		nextPutAll: ' out tokens';
		cr.
	self deny: secondResponse textContent isEmpty
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testRealStreamingClose [
	"Verify socket closes cleanly after streaming completes."
	| sock decoder |
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	sock timeout: 30.
	sock connect.
	sock sendPost: '/v1/messages'
		headers: (OrderedDictionary newFromPairs: {
			'x-api-key'. client apiKey.
			'anthropic-version'. '2023-06-01'.
			'content-type'. 'application/json'.
			'accept'. 'text/event-stream' })
		body: (STONJSON toString: {
			'model' -> 'claude-sonnet-4-6'.
			'max_tokens' -> 20.
			'stream' -> true.
			'messages' -> { { 'role' -> 'user'. 'content' -> 'Hi' } asDictionary }
		} asDictionary).
	sock readStatusLine.
	sock readHeaders.
	decoder := ClaudeSSEDecoder onStream: sock.
	[ decoder hasNext ] whileTrue: [ decoder nextEvent ].
	sock close.
	self deny: sock isConnected
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testRealStreamingConnection [
	"Verify the TLS streaming socket connects, sends a request, and gets status 200."
	| sock statusCode headers decoder |
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	sock timeout: 30.
	sock connect.
	self assert: sock isConnected.
	sock sendPost: '/v1/messages'
		headers: (OrderedDictionary newFromPairs: {
			'x-api-key'. client apiKey.
			'anthropic-version'. '2023-06-01'.
			'content-type'. 'application/json'.
			'accept'. 'text/event-stream' })
		body: (STONJSON toString: {
			'model' -> 'claude-sonnet-4-6'.
			'max_tokens' -> 20.
			'stream' -> true.
			'messages' -> { { 'role' -> 'user'. 'content' -> 'Hi' } asDictionary }
		} asDictionary).
	statusCode := sock readStatusLine.
	headers := sock readHeaders.
	self assert: statusCode equals: 200.
	self assert: ((headers at: 'content-type') beginsWith: 'text/event-stream').
	"Drain the response to allow clean close"
	decoder := ClaudeSSEDecoder onStream: sock.
	[ decoder hasNext ] whileTrue: [ decoder nextEvent ].
	sock close
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testRealStreamingErrorHandling [
	"Verify TLS streaming raises ClaudeApiError for invalid API key. Expect ClaudeAuthError (401) or ClaudeTimeoutError if the network is slow."
	| badClient params |
	badClient := ClaudeClient apiKey: 'sk-invalid'.
	badClient streamingTimeout: 30.
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-6'.
	params maxTokens: 50.
	params addUserMessage: 'Hello'.
	self
		should: [ badClient streamMessage: params do: [ :e | ] ]
		raise: ClaudeApiError
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testRealStreamingEvents [
	"Send a message via real TLS streaming socket, verify SSE events arrive and accumulate correctly."
	| sock decoder message events |
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	sock timeout: 30.
	sock connect.
	sock sendPost: '/v1/messages'
		headers: (OrderedDictionary newFromPairs: {
			'x-api-key'. client apiKey.
			'anthropic-version'. '2023-06-01'.
			'content-type'. 'application/json'.
			'accept'. 'text/event-stream' })
		body: (STONJSON toString: {
			'model' -> 'claude-sonnet-4-6'.
			'max_tokens' -> 50.
			'stream' -> true.
			'messages' -> { { 'role' -> 'user'. 'content' -> 'Say hi in 3 words' } asDictionary }
		} asDictionary).
	sock readStatusLine.
	sock readHeaders.
	decoder := ClaudeSSEDecoder onStream: sock.
	message := ClaudeMessage new.
	events := OrderedCollection new.
	[ decoder hasNext ] whileTrue: [
		| event |
		event := decoder nextEvent.
		events add: (event at: 'event').
		message accumulate: event ].
	sock close.
	self deny: message textContent isEmpty.
	self assert: message stopReason equals: #end_turn.
	self assert: (events includes: 'message_start').
	self assert: (events includes: 'content_block_delta').
	self assert: (events includes: 'message_stop').
	Transcript
		nextPutAll: '<< Real streaming: ';
		nextPutAll: events size printString;
		nextPutAll: ' events, text: ';
		nextPutAll: message textContent;
		cr
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testRealStreamingViaClient [
	"Verify streamMessage:do: uses real TLS streaming for HTTPS base URL."
	| params events message |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-6'.
	params maxTokens: 50.
	params addUserMessage: 'Reply with exactly: streaming works'.
	events := OrderedCollection new.
	message := client streamMessage: params do: [ :event |
		events add: (event at: 'event') ].
	self deny: message textContent isEmpty.
	self assert: message stopReason equals: #end_turn.
	self assert: (events includes: 'message_start').
	self assert: (events includes: 'message_stop').
	Transcript
		nextPutAll: '<< Client streaming: ';
		nextPutAll: events size printString;
		nextPutAll: ' events, text: ';
		nextPutAll: message textContent;
		cr
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testSendMessage [
	| params response |
	params := self newParams: 'Reply with exactly: hello' maxTokens: 50.
	Transcript
		nextPutAll: '>> testSendMessage: sending to ';
		nextPutAll: client baseUrl;
		cr.
	response := client sendMessage: params.
	Transcript
		nextPutAll: '<< Response: ';
		nextPutAll: response textContent size printString;
		nextPutAll: ' chars, ';
		nextPutAll: response usage inputTokens printString;
		nextPutAll: ' in / ';
		nextPutAll: response usage outputTokens printString;
		nextPutAll: ' out tokens';
		cr.
	self assert: (response isKindOf: ClaudeMessage).
	self deny: response textContent isEmpty.
	self assert: response usage inputTokens > 0.
	self assert: response usage outputTokens > 0.
	self assert: response stopReason equals: #end_turn
]

{ #category : 'tests-integration' }
ClaudeIntegrationTest >> testStreamMessage [
	| params events message |
	params := self newParams: 'Reply with exactly: hi' maxTokens: 50.
	Transcript nextPutAll: '>> testStreamMessage: streaming...'; cr.
	events := OrderedCollection new.
	message := client streamMessage: params do: [ :event |
		events add: event.
		Transcript
			nextPutAll: '   event: ';
			nextPutAll: (event at: 'event');
			cr ].
	Transcript
		nextPutAll: '<< Streaming done: ';
		nextPutAll: events size printString;
		nextPutAll: ' events, text: ';
		nextPutAll: message textContent size printString;
		nextPutAll: ' chars';
		cr.
	self assert: events size >= 3.
	self assert: (events anySatisfy: [ :e | (e at: 'event') = 'message_start' ]).
	self assert: (events anySatisfy: [ :e | (e at: 'event') = 'content_block_start' ]).
	self assert: (events anySatisfy: [ :e | (e at: 'event') = 'message_stop' ]).
	self deny: message textContent isEmpty
]
