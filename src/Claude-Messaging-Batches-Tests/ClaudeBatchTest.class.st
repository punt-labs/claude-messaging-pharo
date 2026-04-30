"
Tests for ClaudeBatch JSON parsing, status predicates, and round-trip.

  ClaudeBatchTest buildSuite run
  >>> 6 run, 6 passes

"
Class {
	#name : 'ClaudeBatchTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchTest >> testAsJsonOmitsNilOptionals [
	"Optional datetime fields and resultsUrl are omitted from asJson when nil."
	| batch dict |
	batch := ClaudeBatch new
		id: 'batch-3';
		processingStatus: 'in_progress';
		requestCounts: (ClaudeBatchRequestCounts new processing: 1; yourself);
		createdAt: '2026-04-23T00:00:00Z';
		expiresAt: '2026-04-24T00:00:00Z';
		yourself.
	dict := batch asJson.
	self assert: (dict includesKey: 'id').
	self assert: (dict includesKey: 'processing_status').
	self deny: (dict includesKey: 'ended_at').
	self deny: (dict includesKey: 'results_url').
	self deny: (dict includesKey: 'cancel_initiated_at')
]

{ #category : 'tests' }
ClaudeBatchTest >> testConstruction [
	| batch |
	batch := ClaudeBatch new.
	self assert: batch type equals: 'message_batch'.
	self assert: batch isEnded equals: false.
	self assert: batch isInProgress equals: false.
	self assert: batch isCanceling equals: false
]

{ #category : 'tests' }
ClaudeBatchTest >> testFromJsonFull [
	"Full ended object with all optional fields populated."
	| batch |
	batch := ClaudeBatch fromJson: (Dictionary newFromPairs: {
		'id'. 'batch-2'.
		'processing_status'. 'ended'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 0. 'succeeded'. 8. 'errored'. 1. 'canceled'. 0. 'expired'. 1 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'ended_at'. '2026-04-23T00:05:00Z'.
		'cancel_initiated_at'. '2026-04-23T00:04:00Z'.
		'archived_at'. '2026-04-23T00:06:00Z'.
		'results_url'. 'https://api.anthropic.com/v1/messages/batches/batch-2/results'.
		'type'. 'message_batch' }).
	self assert: batch isEnded.
	self assert: batch endedAt equals: '2026-04-23T00:05:00Z'.
	self assert: batch cancelInitiatedAt equals: '2026-04-23T00:04:00Z'.
	self assert: batch archivedAt equals: '2026-04-23T00:06:00Z'.
	self assert: batch resultsUrl notNil
]

{ #category : 'tests' }
ClaudeBatchTest >> testFromJsonMinimal [
	"Partial in-progress object: optional datetime fields and resultsUrl absent."
	| batch |
	batch := ClaudeBatch fromJson: (Dictionary newFromPairs: {
		'id'. 'batch-1'.
		'processing_status'. 'in_progress'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 5. 'succeeded'. 0. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'type'. 'message_batch' }).
	self assert: batch id equals: 'batch-1'.
	self assert: batch isInProgress.
	self deny: batch isEnded.
	self assert: batch resultsUrl isNil.
	self assert: batch endedAt isNil.
	self assert: batch requestCounts processing equals: 5
]

{ #category : 'tests' }
ClaudeBatchTest >> testJsonKeyMap [
	| map |
	map := ClaudeBatch jsonKeyMap.
	self assert: (map at: #processingStatus) equals: 'processing_status'.
	self assert: (map at: #requestCounts) equals: 'request_counts'.
	self assert: (map at: #createdAt) equals: 'created_at'.
	self assert: (map at: #resultsUrl) equals: 'results_url'
]

{ #category : 'tests' }
ClaudeBatchTest >> testStatusPredicates [
	| inProgress canceling ended |
	inProgress := ClaudeBatch new processingStatus: 'in_progress'; yourself.
	canceling := ClaudeBatch new processingStatus: 'canceling'; yourself.
	ended := ClaudeBatch new processingStatus: 'ended'; yourself.
	self assert: inProgress isInProgress.
	self deny: inProgress isEnded.
	self deny: inProgress isCanceling.
	self assert: canceling isCanceling.
	self deny: canceling isEnded.
	self assert: ended isEnded.
	self deny: ended isInProgress
]
