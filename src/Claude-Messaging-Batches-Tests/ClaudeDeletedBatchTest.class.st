"
Tests for ClaudeDeletedBatch initialize-time type literal and JSON round-trip.

  ClaudeDeletedBatchTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeDeletedBatchTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeDeletedBatchTest >> testAsJsonRoundTrip [
	| d restored |
	d := ClaudeDeletedBatch new id: 'batch-y'; yourself.
	restored := ClaudeDeletedBatch fromJson: d asJson.
	self assert: restored id equals: 'batch-y'.
	self assert: restored type equals: 'message_batch_deleted'
]

{ #category : 'tests' }
ClaudeDeletedBatchTest >> testFromJson [
	| d |
	d := ClaudeDeletedBatch fromJson: (Dictionary newFromPairs: {
		'id'. 'batch-x'. 'type'. 'message_batch_deleted' }).
	self assert: d id equals: 'batch-x'.
	self assert: d type equals: 'message_batch_deleted'
]

{ #category : 'tests' }
ClaudeDeletedBatchTest >> testInitializeType [
	self assert: ClaudeDeletedBatch new type equals: 'message_batch_deleted'
]
