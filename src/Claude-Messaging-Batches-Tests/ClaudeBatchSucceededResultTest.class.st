"
Tests for ClaudeBatchSucceededResult predicate matrix and ClaudeMessage wrapping.

  ClaudeBatchSucceededResultTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchSucceededResultTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchSucceededResultTest >> testFromJsonWrapsMessage [
	| r |
	r := ClaudeBatchSucceededResult fromJson: (Dictionary newFromPairs: {
		'type'. 'succeeded'.
		'message'. (Dictionary newFromPairs: {
			'id'. 'msg_01'. 'type'. 'message'. 'role'. 'assistant'.
			'model'. 'claude-haiku-4-5'.
			'content'. { Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hi' } }.
			'stop_reason'. 'end_turn'.
			'usage'. (Dictionary newFromPairs: { 'input_tokens'. 1. 'output_tokens'. 1 }) }) }).
	self assert: (r message isKindOf: ClaudeMessage).
	self assert: r message id equals: 'msg_01'
]

{ #category : 'tests' }
ClaudeBatchSucceededResultTest >> testInitializeType [
	self assert: ClaudeBatchSucceededResult new type equals: 'succeeded'
]

{ #category : 'tests' }
ClaudeBatchSucceededResultTest >> testPredicates [
	| r |
	r := ClaudeBatchSucceededResult new.
	self assert: r isSucceeded.
	self deny: r isErrored.
	self deny: r isCanceled.
	self deny: r isExpired
]
