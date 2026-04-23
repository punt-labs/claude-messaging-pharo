"
In-process HTTP mock server for testing ClaudeClient without network access. Registers canned JSON responses (respondTo:with:) and SSE responses (respondTo:withSSE:) by path. Records the last request for assertion. Uses ZnServer with a custom delegate. Start with startOn:, stop with stop.
"
Class {
	#name : 'ClaudeMockServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'responses',
		'lastRequest',
		'sseResponses',
		'errorResponses',
		'responseSequences',
		'requestCounts',
		'delayedResponses'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'instance creation' }
ClaudeMockServer class >> startOn: aPort [
	^ self new startOn: aPort
]

{ #category : 'private' }
ClaudeMockServer >> delayedResponseFor: path [
	"If a delayed response is registered for path, sleep for the configured duration and
	 answer the response. Otherwise return nil so the caller can fall through to the
	 other response dispatchers."
	| entry duration response |
	entry := delayedResponses at: path ifAbsent: [ ^ nil ].
	duration := entry at: 1.
	response := entry at: 2.
	(Delay forMilliseconds: duration asMilliSeconds) wait.
	^ response
]

{ #category : 'factory' }
ClaudeMockServer >> errorResponse: statusCode message: errorMessage [
	"Build a ZnResponse for an error with the given status code and message."
	^ self errorResponseFor: { statusCode. errorMessage. '' }
]

{ #category : 'factory' }
ClaudeMockServer >> errorResponse: statusCode message: errorMessage headers: aDictionary [
	"Build a ZnResponse for an error with custom headers."
	| response |
	response := self errorResponse: statusCode message: errorMessage.
	aDictionary keysAndValuesDo: [ :key :value |
		response headers at: key put: value ].
	^ response
]

{ #category : 'private' }
ClaudeMockServer >> errorResponseFor: anArray [
	"Build a ZnResponse from an error entry {statusCode. message. requestId}."
	| json response |
	json := STONJSON toString: (Dictionary newFromPairs: {
		'type'. 'error'.
		'error'. (Dictionary newFromPairs: { 'type'. 'api_error'. 'message'. (anArray at: 2) })
	}).
	response := ZnResponse statusCode: (anArray at: 1).
	response entity: (ZnEntity json: json).
	(anArray at: 3) ifNotEmpty: [ :reqId |
		response headers at: 'request-id' put: reqId ].
	^ response
]

{ #category : 'delegate' }
ClaudeMockServer >> handleRequest: aZnRequest [
	"Serve canned responses or 404. Record request for assertions.
	 Validates request bodies against known endpoint schemas.
	 Delayed responses sleep before answering to exercise timeout paths."
	| path validationError response |
	lastRequest := aZnRequest.
	path := aZnRequest uri path.
	requestCounts at: path put: (requestCounts at: path ifAbsent: [ 0 ]) + 1.
	validationError := self validateRequest: aZnRequest forPath: path.
	validationError ifNotNil: [ ^ validationError ].
	response := self delayedResponseFor: path.
	response ifNotNil: [ ^ response ].
	response := self sequenceResponseFor: path.
	response ifNotNil: [ ^ response ].
	response := self staticResponseFor: path.
	response ifNotNil: [ ^ response ].
	^ ZnResponse notFound: aZnRequest uri
]

{ #category : 'initialization' }
ClaudeMockServer >> initialize [
	responses := Dictionary new.
	sseResponses := Dictionary new.
	errorResponses := Dictionary new.
	responseSequences := Dictionary new.
	requestCounts := Dictionary new.
	delayedResponses := Dictionary new
]

{ #category : 'accessing' }
ClaudeMockServer >> lastRequest [
	^ lastRequest
]

{ #category : 'accessing' }
ClaudeMockServer >> lastRequestBody [
	"Return the last request body as a parsed JSON dictionary."
	^ STONJSON fromString: lastRequest entity contents
]

{ #category : 'accessing' }
ClaudeMockServer >> lastRequestHeaders [
	"Return the last request headers."
	^ lastRequest headers
]

{ #category : 'accessing' }
ClaudeMockServer >> lastRequestMethod [
	"Return the last request HTTP method as a string."
	^ lastRequest method
]

{ #category : 'accessing' }
ClaudeMockServer >> lastRequestPath [
	"Return the last request URI path."
	^ lastRequest uri path
]

{ #category : 'accessing' }
ClaudeMockServer >> port [
	"Answer the port the server is listening on."
	^ server port
]

{ #category : 'accessing' }
ClaudeMockServer >> requestCountFor: path [
	"Return the number of requests received for the given path."
	| normalizedPath |
	normalizedPath := (path beginsWith: '/')
		ifTrue: [ path allButFirst ]
		ifFalse: [ path ].
	^ requestCounts at: normalizedPath ifAbsent: [ 0 ]
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: path with: jsonString [
	| normalizedPath |
	normalizedPath := (path beginsWith: '/')
		ifTrue: [ path allButFirst ]
		ifFalse: [ path ].
	responses at: normalizedPath put: jsonString
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: aPath with: jsonString headers: aDictionary [
  "Register a JSON response with custom additional response headers.
   Used by mission yvyt+pch2 to fixture rate-limit + request-id headers
   so ClaudeClient>>sendMessage: can be tested for ResponseMetadata
   wiring without a real Anthropic round-trip."
  | normalizedPath response |
  normalizedPath := (aPath beginsWith: '/')
    ifTrue: [ aPath allButFirst ]
    ifFalse: [ aPath ].
  response := ZnResponse ok: (ZnEntity json: jsonString).
  aDictionary keysAndValuesDo: [ :k :v | response headers at: k put: v ].
  responses removeKey: normalizedPath ifAbsent: [ nil ].
  responseSequences at: normalizedPath put: (OrderedCollection with: response)
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: aPath withDelay: aDuration thenWith: aResponse [
	"Register a delayed static response for aPath. When a request hits aPath, the mock
	 server sleeps for aDuration (a Duration) on its request-handler thread, then answers
	 aResponse. Used to exercise the ClaudeClient timeout path end-to-end -- configure the
	 delay longer than the client's timeout to force a real wall-clock timeout.
	 Because the sleep blocks the ZnServer request handler, only one request at a time
	 should target a delayed path. Fine for timeout tests where the client gives up before
	 a second request is issued."
	| normalizedPath |
	normalizedPath := (aPath beginsWith: '/')
		ifTrue: [ aPath allButFirst ]
		ifFalse: [ aPath ].
	delayedResponses at: normalizedPath put: { aDuration. aResponse }
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: path withError: statusCode message: errorMessage [
	"Register an error response with default request-id."
	self respondTo: path withError: statusCode message: errorMessage requestId: ''
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: path withError: statusCode message: errorMessage requestId: reqId [
	"Register an error response with a specific status code, message, and request-id."
	| normalizedPath |
	normalizedPath := (path beginsWith: '/')
		ifTrue: [ path allButFirst ]
		ifFalse: [ path ].
	errorResponses at: normalizedPath put: {statusCode. errorMessage. reqId}
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: path withSSE: sseBodyString [
	"Register a canned SSE response for a given path."
	| normalizedPath |
	normalizedPath := (path beginsWith: '/')
		ifTrue: [ path allButFirst ]
		ifFalse: [ path ].
	sseResponses at: normalizedPath put: sseBodyString
]

{ #category : 'configuring' }
ClaudeMockServer >> respondTo: path withSequence: anOrderedCollection [
	"Register a sequence of responses for a path. Each element is a ZnResponse.
	 The mock server returns the next response in the sequence for each request."
	| normalizedPath |
	normalizedPath := (path beginsWith: '/')
		ifTrue: [ path allButFirst ]
		ifFalse: [ path ].
	responseSequences at: normalizedPath put: anOrderedCollection asOrderedCollection
]

{ #category : 'accessing' }
ClaudeMockServer >> responses [
	^ responses
]

{ #category : 'private' }
ClaudeMockServer >> sequenceResponseFor: path [
	"Return the next response in a sequence for the given path, or nil if no sequence exists.
	 Signals an error if the sequence is exhausted (too many requests)."
	| sequence count |
	sequence := responseSequences at: path ifAbsent: [ ^ nil ].
	count := requestCounts at: path ifAbsent: [ 1 ].
	count > sequence size ifTrue: [
		Error signal: 'Mock sequence exhausted for ', path ].
	^ sequence at: count
]

{ #category : 'accessing' }
ClaudeMockServer >> sseResponses [
	^ sseResponses
]

{ #category : 'lifecycle' }
ClaudeMockServer >> startOn: aPort [
	server := ZnServer on: aPort.
	server delegate: self.
	server start.
	self waitUntilReady
]

{ #category : 'private' }
ClaudeMockServer >> staticResponseFor: path [
	"Return a static error, SSE, or JSON response for the given path, or nil if none exists."
	| errorEntry sseBody body |
	errorEntry := errorResponses at: path ifAbsent: [ nil ].
	errorEntry ifNotNil: [ ^ self errorResponseFor: errorEntry ].
	sseBody := sseResponses at: path ifAbsent: [ nil ].
	sseBody ifNotNil: [
		^ ZnResponse ok: (ZnEntity
			with: sseBody
			type: (ZnMimeType main: 'text' sub: 'event-stream')) ].
	body := responses at: path ifAbsent: [ nil ].
	body ifNotNil: [ ^ ZnResponse ok: (ZnEntity json: body) ].
	^ nil
]

{ #category : 'lifecycle' }
ClaudeMockServer >> stop [
	server ifNotNil: [ server stop ]
]

{ #category : 'factory' }
ClaudeMockServer >> successResponse: jsonString [
	"Build a successful ZnResponse with JSON body."
	^ ZnResponse ok: (ZnEntity json: jsonString)
]

{ #category : 'validation' }
ClaudeMockServer >> validateCountTokensBody: json [
	"Validate request body for the count_tokens endpoint.
	 Rejects max_tokens; requires model and messages."
	(json includesKey: 'max_tokens') ifTrue: [
		^ self errorResponse: 400 message: 'max_tokens is not allowed for count_tokens' ].
	(json includesKey: 'model') ifFalse: [
		^ self errorResponse: 400 message: 'model is required' ].
	(json includesKey: 'messages') ifFalse: [
		^ self errorResponse: 400 message: 'messages is required' ].
	^ nil
]

{ #category : 'validation' }
ClaudeMockServer >> validateMessagesBody: json [
	"Validate request body for the messages endpoint.
	 Requires model, max_tokens, and messages."
	(json includesKey: 'model') ifFalse: [
		^ self errorResponse: 400 message: 'model is required' ].
	(json includesKey: 'max_tokens') ifFalse: [
		^ self errorResponse: 400 message: 'max_tokens is required' ].
	(json includesKey: 'messages') ifFalse: [
		^ self errorResponse: 400 message: 'messages is required' ].
	^ nil
]

{ #category : 'validation' }
ClaudeMockServer >> validateRequest: aZnRequest forPath: path [
	"Validate request body against known endpoint schemas.
	 Returns a ZnResponse for validation errors, or nil if valid.
	 Multipart uploads (e.g. Files API, Skills API) bypass JSON parsing entirely."
	| json contentType |
	(aZnRequest method = 'POST') ifFalse: [ ^ nil ].
	aZnRequest entity ifNil: [ ^ nil ].
	contentType := aZnRequest entity contentType.
	(contentType notNil and: [ contentType main = 'multipart' ]) ifTrue: [ ^ nil ].
	json := [ STONJSON fromString: aZnRequest entity contents ]
		on: Error do: [ :e | ^ self errorResponse: 400 message: 'Invalid JSON' ].
	(path includesSubstring: 'count_tokens') ifTrue: [
		^ self validateCountTokensBody: json ].
	(path includesSubstring: 'messages') ifTrue: [
		^ self validateMessagesBody: json ].
	^ nil
]

{ #category : 'private' }
ClaudeMockServer >> waitUntilReady [
	"Poll until the server is listening, up to 2 seconds."
	10 timesRepeat: [
		server isRunning ifTrue: [ ^ self ].
		(Delay forMilliseconds: 200) wait ].
	Error signal: 'Mock server failed to start'
]
