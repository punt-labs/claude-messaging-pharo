"
Tests for ClaudeBatchListParams asQueryParams variants: empty, limit-only, after+before+limit. Pins jsonKeyMap.

  ClaudeBatchListParamsTest buildSuite run
  >>> 4 run, 4 passes

"
Class {
	#name : 'ClaudeBatchListParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchListParamsTest >> testAfterAndBeforeAndLimit [
	| p qp |
	p := ClaudeBatchListParams new
		afterId: 'batch-a';
		beforeId: 'batch-z';
		limit: 25;
		yourself.
	qp := p asQueryParams.
	self assert: qp size equals: 3.
	self assert: (qp at: 'after_id') equals: 'batch-a'.
	self assert: (qp at: 'before_id') equals: 'batch-z'.
	self assert: (qp at: 'limit') equals: '25'
]

{ #category : 'tests' }
ClaudeBatchListParamsTest >> testEmptyQueryParams [
	self assert: ClaudeBatchListParams new asQueryParams isEmpty
]

{ #category : 'tests' }
ClaudeBatchListParamsTest >> testJsonKeyMap [
	| map |
	map := ClaudeBatchListParams jsonKeyMap.
	self assert: (map at: #afterId) equals: 'after_id'.
	self assert: (map at: #beforeId) equals: 'before_id'
]

{ #category : 'tests' }
ClaudeBatchListParamsTest >> testLimitOnly [
	| p qp |
	p := ClaudeBatchListParams new limit: 50; yourself.
	qp := p asQueryParams.
	self assert: qp size equals: 1.
	self assert: (qp at: 'limit') equals: '50'
]
