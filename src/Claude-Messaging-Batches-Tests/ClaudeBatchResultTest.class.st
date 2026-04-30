"
Tests for ClaudeBatchResult fromJson dispatch — succeeded, errored, canceled, expired, and the unknown-type fallback. Pins isSucceeded/isErrored/isCanceled/isExpired delegation through the wrapper.

  ClaudeBatchResultTest buildSuite run
  >>> 6 run, 6 passes

"
Class {
	#name : 'ClaudeBatchResultTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchResultTest >> testFromJsonCanceled [
	| entry |
	entry := ClaudeBatchResult fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-3'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	self assert: entry isCanceled.
	self deny: entry isSucceeded.
	self assert: (entry result isKindOf: ClaudeBatchCanceledResult)
]

{ #category : 'tests' }
ClaudeBatchResultTest >> testFromJsonErrored [
	| entry |
	entry := ClaudeBatchResult fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-2'.
		'result'. (Dictionary newFromPairs: {
			'type'. 'errored'.
			'error'. (Dictionary newFromPairs: {
				'type'. 'invalid_request_error'.
				'message'. 'bad input' }) }) }).
	self assert: entry isErrored.
	self deny: entry isSucceeded.
	self assert: (entry result isKindOf: ClaudeBatchErroredResult).
	self assert: entry result error message equals: 'bad input'
]

{ #category : 'tests' }
ClaudeBatchResultTest >> testFromJsonExpired [
	| entry |
	entry := ClaudeBatchResult fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-4'.
		'result'. (Dictionary newFromPairs: { 'type'. 'expired' }) }).
	self assert: entry isExpired.
	self deny: entry isSucceeded.
	self assert: (entry result isKindOf: ClaudeBatchExpiredResult)
]

{ #category : 'tests' }
ClaudeBatchResultTest >> testFromJsonSucceeded [
	"A succeeded entry wraps a ClaudeMessage."
	| entry msgJson |
	msgJson := Dictionary newFromPairs: {
		'id'. 'msg_01'.
		'type'. 'message'.
		'role'. 'assistant'.
		'model'. 'claude-haiku-4-5'.
		'content'. { Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'Hello!' } }.
		'stop_reason'. 'end_turn'.
		'usage'. (Dictionary newFromPairs: { 'input_tokens'. 5. 'output_tokens'. 3 }) }.
	entry := ClaudeBatchResult fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-1'.
		'result'. (Dictionary newFromPairs: {
			'type'. 'succeeded'.
			'message'. msgJson }) }).
	self assert: entry customId equals: 'req-1'.
	self assert: entry isSucceeded.
	self deny: entry isErrored.
	self assert: (entry result isKindOf: ClaudeBatchSucceededResult).
	self assert: (entry result message isKindOf: ClaudeMessage)
]

{ #category : 'tests' }
ClaudeBatchResultTest >> testFromJsonUnknownTypeFallsBackToErrored [
	"Unknown wire result.type tags become a synthetic errored result so callers
	 always receive a polymorphic outcome instead of a parse error mid-stream."
	| entry |
	entry := ClaudeBatchResult fromJson: (Dictionary newFromPairs: {
		'custom_id'. 'req-5'.
		'result'. (Dictionary newFromPairs: { 'type'. 'mystery' }) }).
	self assert: entry isErrored.
	self assert: entry result error type equals: 'unknown_result_type'.
	self assert: (entry result error message includesSubstring: 'mystery')
]

{ #category : 'tests' }
ClaudeBatchResultTest >> testPredicateDelegationWithNilResult [
	"isSucceeded etc. answer false (not DNU) when result is nil — defensive
	 against partial deserialization."
	| entry |
	entry := ClaudeBatchResult new customId: 'req-x'; yourself.
	self deny: entry isSucceeded.
	self deny: entry isErrored.
	self deny: entry isCanceled.
	self deny: entry isExpired
]
