"
Tests for ClaudeBatchErroredResult predicate matrix, ClaudeBatchErrorPayload wrapping, and the unknown: factory.

  ClaudeBatchErroredResultTest buildSuite run
  >>> 4 run, 4 passes

"
Class {
	#name : 'ClaudeBatchErroredResultTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchErroredResultTest >> testAsJsonWhenErrorNilOmitsKey [
	"asJson on a partially-constructed receiver omits the 'error' key
	 instead of raising DNU on nil — matches the ifNotNil:-omit idiom
	 used by ClaudeBatch>>asJson."
	| dict |
	dict := ClaudeBatchErroredResult new asJson.
	self assert: (dict at: 'type') equals: 'errored'.
	self deny: (dict includesKey: 'error').
	self assert: dict size equals: 1
]

{ #category : 'tests' }
ClaudeBatchErroredResultTest >> testFromJsonWrapsErrorPayload [
	| r |
	r := ClaudeBatchErroredResult fromJson: (Dictionary newFromPairs: {
		'type'. 'errored'.
		'error'. (Dictionary newFromPairs: {
			'type'. 'invalid_request_error'. 'message'. 'bad' }) }).
	self assert: (r error isKindOf: ClaudeBatchErrorPayload).
	self assert: r error type equals: 'invalid_request_error'.
	self assert: r error message equals: 'bad'
]

{ #category : 'tests' }
ClaudeBatchErroredResultTest >> testInitializeType [
	self assert: ClaudeBatchErroredResult new type equals: 'errored'
]

{ #category : 'tests' }
ClaudeBatchErroredResultTest >> testPredicates [
	| r |
	r := ClaudeBatchErroredResult new.
	self deny: r isSucceeded.
	self assert: r isErrored.
	self deny: r isCanceled.
	self deny: r isExpired
]

{ #category : 'tests' }
ClaudeBatchErroredResultTest >> testUnknownFactory [
	| r |
	r := ClaudeBatchErroredResult unknown: 'mystery'.
	self assert: r isErrored.
	self assert: r error type equals: 'unknown_result_type'.
	self assert: (r error message includesSubstring: 'mystery')
]
