"
Tests for ClaudeBatchRequestCounts initialization, fromJson, asJson round-trip, and total invariant.

  ClaudeBatchRequestCountsTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchRequestCountsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchRequestCountsTest >> testAsJsonRoundTrip [
	| c restored |
	c := ClaudeBatchRequestCounts fromJson: (Dictionary newFromPairs: {
		'processing'. 0. 'succeeded'. 5. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
	restored := ClaudeBatchRequestCounts fromJson: c asJson.
	self assert: restored succeeded equals: 5.
	self assert: restored total equals: 5
]

{ #category : 'tests' }
ClaudeBatchRequestCountsTest >> testFromJson [
	| c |
	c := ClaudeBatchRequestCounts fromJson: (Dictionary newFromPairs: {
		'processing'. 1. 'succeeded'. 7. 'errored'. 2. 'canceled'. 1. 'expired'. 3 }).
	self assert: c processing equals: 1.
	self assert: c succeeded equals: 7.
	self assert: c errored equals: 2.
	self assert: c canceled equals: 1.
	self assert: c expired equals: 3.
	self assert: c total equals: 14
]

{ #category : 'tests' }
ClaudeBatchRequestCountsTest >> testInitializeAllZero [
	| c |
	c := ClaudeBatchRequestCounts new.
	self assert: c processing equals: 0.
	self assert: c succeeded equals: 0.
	self assert: c errored equals: 0.
	self assert: c canceled equals: 0.
	self assert: c expired equals: 0.
	self assert: c total equals: 0
]
