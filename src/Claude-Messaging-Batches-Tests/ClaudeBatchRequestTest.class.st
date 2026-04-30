"
Tests for ClaudeBatchRequest construction, asJson via ClaudeMessageRequest, and round-trip from raw Dictionary.

  ClaudeBatchRequestTest buildSuite run
  >>> 5 run, 5 passes

"
Class {
	#name : 'ClaudeBatchRequestTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchRequestTest >> testAsJsonWithMessageRequest [
	"asJson sends asJson to params when it responds — the production path."
	| req msgReq dict paramsDict |
	msgReq := ClaudeMessageRequest new
		model: 'claude-haiku-4-5';
		maxTokens: 16;
		addUserMessage: 'Hi';
		yourself.
	req := ClaudeBatchRequest customId: 'req-a' params: msgReq.
	dict := req asJson.
	self assert: (dict at: 'custom_id') equals: 'req-a'.
	paramsDict := dict at: 'params'.
	self assert: (paramsDict at: 'model') equals: 'claude-haiku-4-5'.
	self assert: (paramsDict at: 'max_tokens') equals: 16
]

{ #category : 'tests' }
ClaudeBatchRequestTest >> testAsJsonWithRawDictionary [
	"asJson passes through when params is already a raw Dictionary — the
	 round-trip path used by fromJson:."
	| req dict |
	req := ClaudeBatchRequest new
		customId: 'req-b';
		params: (Dictionary newFromPairs: { 'model'. 'claude-haiku-4-5'. 'max_tokens'. 8 });
		yourself.
	dict := req asJson.
	self assert: ((dict at: 'params') at: 'model') equals: 'claude-haiku-4-5'
]

{ #category : 'tests' }
ClaudeBatchRequestTest >> testCustomIdParams [
	| req msgReq |
	msgReq := ClaudeMessageRequest new
		model: 'claude-haiku-4-5';
		maxTokens: 256;
		addUserMessage: 'Hello';
		yourself.
	req := ClaudeBatchRequest customId: 'req-1' params: msgReq.
	self assert: req customId equals: 'req-1'.
	self assert: req params identicalTo: msgReq
]

{ #category : 'tests' }
ClaudeBatchRequestTest >> testFromJson [
	| req |
	req := ClaudeBatchRequest fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-c'.
		'params'. (Dictionary newFromPairs: { 'model'. 'claude-haiku-4-5' }) }).
	self assert: req customId equals: 'req-c'.
	self assert: (req params at: 'model') equals: 'claude-haiku-4-5'
]

{ #category : 'tests' }
ClaudeBatchRequestTest >> testJsonKeyMap [
	self assert: (ClaudeBatchRequest jsonKeyMap at: #customId) equals: 'custom_id'
]
