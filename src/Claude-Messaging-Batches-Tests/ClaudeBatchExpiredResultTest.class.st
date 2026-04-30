"
Tests for ClaudeBatchExpiredResult predicate matrix and minimal asJson payload.

  ClaudeBatchExpiredResultTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchExpiredResultTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchExpiredResultTest >> testAsJsonOnlyType [
	| dict |
	dict := ClaudeBatchExpiredResult new asJson.
	self assert: (dict at: 'type') equals: 'expired'.
	self assert: dict size equals: 1
]

{ #category : 'tests' }
ClaudeBatchExpiredResultTest >> testInitializeType [
	self assert: ClaudeBatchExpiredResult new type equals: 'expired'
]

{ #category : 'tests' }
ClaudeBatchExpiredResultTest >> testPredicates [
	| r |
	r := ClaudeBatchExpiredResult new.
	self deny: r isSucceeded.
	self deny: r isErrored.
	self deny: r isCanceled.
	self assert: r isExpired
]
