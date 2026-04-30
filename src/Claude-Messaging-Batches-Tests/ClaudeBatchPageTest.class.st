"
Tests for ClaudeBatchPage cursor-ID pagination and JSON round-trip.

  ClaudeBatchPageTest buildSuite run
  >>> 4 run, 4 passes

"
Class {
	#name : 'ClaudeBatchPageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchPageTest >> testAsJsonRoundTrip [
	| page json restored batchJson |
	batchJson := Dictionary newFromPairs: {
		'id'. 'batch-2'.
		'processing_status'. 'ended'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 0. 'succeeded'. 1. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'type'. 'message_batch' }.
	json := Dictionary new.
	json at: 'data' put: { batchJson }.
	json at: 'has_more' put: false.
	page := ClaudeBatchPage fromJson: json.
	restored := page asJson.
	self assert: (restored at: 'data') size equals: 1.
	self assert: ((restored at: 'data') first at: 'id') equals: 'batch-2'.
	self assert: (restored at: 'has_more') equals: false
]

{ #category : 'tests' }
ClaudeBatchPageTest >> testConstruction [
	| page |
	page := ClaudeBatchPage new.
	self assert: page data equals: #().
	self assert: page hasMore equals: false.
	self assert: page firstId isNil.
	self assert: page lastId isNil
]

{ #category : 'tests' }
ClaudeBatchPageTest >> testFromJsonEmptyPage [
	| page |
	page := ClaudeBatchPage fromJson: Dictionary new.
	self assert: page data size equals: 0.
	self assert: page hasMore equals: false
]

{ #category : 'tests' }
ClaudeBatchPageTest >> testFromJsonParsesBatchArray [
	| page batchJson json |
	batchJson := Dictionary newFromPairs: {
		'id'. 'batch-1'.
		'processing_status'. 'in_progress'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 1. 'succeeded'. 0. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'type'. 'message_batch' }.
	json := Dictionary new.
	json at: 'data' put: { batchJson }.
	json at: 'has_more' put: true.
	json at: 'first_id' put: 'batch-1'.
	json at: 'last_id' put: 'batch-1'.
	page := ClaudeBatchPage fromJson: json.
	self assert: page data size equals: 1.
	self assert: (page data first isKindOf: ClaudeBatch).
	self assert: page data first id equals: 'batch-1'.
	self assert: page hasMore equals: true.
	self assert: page firstId equals: 'batch-1'.
	self assert: page lastId equals: 'batch-1'
]
