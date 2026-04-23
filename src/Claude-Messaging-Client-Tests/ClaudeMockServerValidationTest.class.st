"
Tests that validate ClaudeMockServer responses match the Anthropic API format.
"
Class {
	#name : 'ClaudeMockServerValidationTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'private' }
ClaudeMockServerValidationTest >> postTo: path json: aDictionary [
	"POST a JSON body to the mock server and return the response."
	| url |
	url := 'http://localhost:', mockServer port printString, path.
	^ ZnClient new
		url: url;
		entity: (ZnEntity json: (STONJSON toString: aDictionary));
		post;
		response
]

{ #category : 'running' }
ClaudeMockServerValidationTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	mockServer respondTo: '/v1/messages' with: '{"id":"msg_test","type":"message","role":"assistant","content":[{"type":"text","text":"hi"}],"model":"claude-sonnet-4-5-20250514","stop_reason":"end_turn","stop_sequence":null,"usage":{"input_tokens":10,"output_tokens":5,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}'.
	mockServer respondTo: '/v1/messages/count_tokens' with: '{"input_tokens":42}'
]

{ #category : 'running' }
ClaudeMockServerValidationTest >> tearDown [
	mockServer stop.
	super tearDown
]

{ #category : 'tests' }
ClaudeMockServerValidationTest >> testMockAcceptsCountTokensWithoutMaxTokens [
	"count_tokens accepts model + messages without max_tokens."
	| response |
	response := self postTo: '/v1/messages/count_tokens' json: (Dictionary newFromPairs: {
		'model'. 'claude-sonnet-4-5-20250514'.
		'messages'. { Dictionary newFromPairs: { 'role'. 'user'. 'content'. 'Hello' } } }).
	self assert: response code equals: 200
]

{ #category : 'tests' }
ClaudeMockServerValidationTest >> testMockAcceptsValidRequest [
	"A valid messages request with all required fields returns 200."
	| response |
	response := self postTo: '/v1/messages' json: (Dictionary newFromPairs: {
		'model'. 'claude-sonnet-4-5-20250514'.
		'max_tokens'. 1024.
		'messages'. { Dictionary newFromPairs: { 'role'. 'user'. 'content'. 'Hello' } } }).
	self assert: response code equals: 200
]

{ #category : 'tests' }
ClaudeMockServerValidationTest >> testMockRejectsMaxTokensOnCountTokens [
	"The real API rejects max_tokens on the count_tokens endpoint."
	| response |
	response := self postTo: '/v1/messages/count_tokens' json: (Dictionary newFromPairs: {
		'model'. 'claude-sonnet-4-5-20250514'.
		'max_tokens'. 1024.
		'messages'. { Dictionary newFromPairs: { 'role'. 'user'. 'content'. 'Hello' } } }).
	self assert: response code equals: 400
]

{ #category : 'tests' }
ClaudeMockServerValidationTest >> testMockRequiresMessagesOnMessages [
	"The messages endpoint requires a messages array."
	| response |
	response := self postTo: '/v1/messages' json: (Dictionary newFromPairs: {
		'model'. 'claude-sonnet-4-5-20250514'.
		'max_tokens'. 1024 }).
	self assert: response code equals: 400
]

{ #category : 'tests' }
ClaudeMockServerValidationTest >> testMockRequiresModelOnMessages [
	"The messages endpoint requires a model field."
	| response |
	response := self postTo: '/v1/messages' json: (Dictionary newFromPairs: {
		'max_tokens'. 1024.
		'messages'. { Dictionary newFromPairs: { 'role'. 'user'. 'content'. 'Hello' } } }).
	self assert: response code equals: 400
]
