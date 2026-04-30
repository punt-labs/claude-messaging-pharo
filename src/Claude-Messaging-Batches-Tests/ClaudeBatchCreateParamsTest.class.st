"
Tests for ClaudeBatchCreateParams chainable addRequest:, isEmpty/size predicates, and asJson wire shape.

  ClaudeBatchCreateParamsTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchCreateParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchCreateParamsTest >> testAddRequestChainable [
	| p msgReq |
	msgReq := ClaudeMessageRequest new
		model: 'claude-haiku-4-5';
		maxTokens: 16;
		addUserMessage: 'hi';
		yourself.
	p := ClaudeBatchCreateParams new
		addRequest: (ClaudeBatchRequest customId: 'r-1' params: msgReq);
		addRequest: (ClaudeBatchRequest customId: 'r-2' params: msgReq);
		yourself.
	self assert: p size equals: 2.
	self deny: p isEmpty
]

{ #category : 'tests' }
ClaudeBatchCreateParamsTest >> testAsJsonShape [
	"Wire shape: { 'requests': [ { 'custom_id': ..., 'params': {...} }, ... ] }."
	| p msgReq json reqs |
	msgReq := ClaudeMessageRequest new
		model: 'claude-haiku-4-5';
		maxTokens: 16;
		addUserMessage: 'hi';
		yourself.
	p := ClaudeBatchCreateParams new
		addRequest: (ClaudeBatchRequest customId: 'r-1' params: msgReq);
		addRequest: (ClaudeBatchRequest customId: 'r-2' params: msgReq);
		yourself.
	json := p asJson.
	self assert: (json includesKey: 'requests').
	reqs := json at: 'requests'.
	self assert: reqs size equals: 2.
	self assert: (reqs first at: 'custom_id') equals: 'r-1'.
	self assert: ((reqs first at: 'params') at: 'model') equals: 'claude-haiku-4-5'
]

{ #category : 'tests' }
ClaudeBatchCreateParamsTest >> testEmpty [
	| p |
	p := ClaudeBatchCreateParams new.
	self assert: p isEmpty.
	self assert: p size equals: 0
]
