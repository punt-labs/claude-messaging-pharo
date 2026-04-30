"
Tests for ClaudeBatchCanceledResult predicate matrix and minimal asJson payload.

  ClaudeBatchCanceledResultTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchCanceledResultTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchCanceledResultTest >> testAsJsonOnlyType [
	| dict |
	dict := ClaudeBatchCanceledResult new asJson.
	self assert: (dict at: 'type') equals: 'canceled'.
	self assert: dict size equals: 1
]

{ #category : 'tests' }
ClaudeBatchCanceledResultTest >> testInitializeType [
	self assert: ClaudeBatchCanceledResult new type equals: 'canceled'
]

{ #category : 'tests' }
ClaudeBatchCanceledResultTest >> testPredicates [
	| r |
	r := ClaudeBatchCanceledResult new.
	self deny: r isSucceeded.
	self deny: r isErrored.
	self assert: r isCanceled.
	self deny: r isExpired
]
