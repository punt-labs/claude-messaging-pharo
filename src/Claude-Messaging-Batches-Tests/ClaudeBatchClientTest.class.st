"
End-to-end tests for the Batches API client extension methods using ClaudeMockServer. Covers createBatch:, getBatch:, listBatches, listBatches:, cancelBatch:, deleteBatch:, streamBatchResults:do:. Pins the message-batches-2024-09-24 beta header on every wire call and the ClaudeBatchNotEndedError guard when streamBatchResults:do: is called before the batch reaches ended. Includes regression tests for the Bugbot MEDIUM finding (no duplication when executeWithRetry: retries the results GET) and the structural property (no callback fires before the entire response is parsed).

  ClaudeBatchClientTest buildSuite run
  >>> 12 run, 12 passes

"
Class {
	#name : 'ClaudeBatchClientTest',
	#superclass : 'TestCase',
	#instVars : [
		'server',
		'client',
		'port'
	],
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'fixtures' }
ClaudeBatchClientTest >> sampleBatchJson [
	"Wire-shape JSON for one batch in in_progress state."
	^ STONJSON toString: (Dictionary newFromPairs: {
		'id'. 'batch-abc'.
		'type'. 'message_batch'.
		'processing_status'. 'in_progress'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 2. 'succeeded'. 0. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z' })
]

{ #category : 'fixtures' }
ClaudeBatchClientTest >> sampleEndedBatchJson [
	^ STONJSON toString: (Dictionary newFromPairs: {
		'id'. 'batch-abc'.
		'type'. 'message_batch'.
		'processing_status'. 'ended'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 0. 'succeeded'. 2. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'ended_at'. '2026-04-23T00:01:00Z'.
		'results_url'. 'http://localhost:' , port printString , '/v1/messages/batches/batch-abc/results' })
]

{ #category : 'running' }
ClaudeBatchClientTest >> setUp [
	"Use OS-assigned port 0 -- ZnServer picks a free port and we read it back
	 via the mock server's port accessor. Avoids hardcoded port ranges, port
	 collisions across parallel test runs, and same-port reuse races. The OS
	 only hands back a port that's actually free at start time."
	server := ClaudeMockServer startOn: 0.
	port := server port.
	client := ClaudeClient apiKey: 'test-key'.
	client baseUrl: 'http://localhost:' , port printString.
	client maxRetries: 0
]

{ #category : 'running' }
ClaudeBatchClientTest >> tearDown [
	"Stop the mock server. The OS-assigned port from setUp is released
	 immediately on stop; no manual delay needed."
	server ifNotNil: [ server stop. server := nil ]
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testCancelBatch [
	| canceling batch |
	canceling := STONJSON toString: (Dictionary newFromPairs: {
		'id'. 'batch-abc'.
		'type'. 'message_batch'.
		'processing_status'. 'canceling'.
		'request_counts'. (Dictionary newFromPairs: {
			'processing'. 1. 'succeeded'. 0. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
		'created_at'. '2026-04-23T00:00:00Z'.
		'expires_at'. '2026-04-24T00:00:00Z'.
		'cancel_initiated_at'. '2026-04-23T00:00:30Z' }).
	server respondTo: 'v1/messages/batches/batch-abc/cancel' with: canceling.
	batch := client cancelBatch: 'batch-abc'.
	self assert: batch isCanceling.
	self assert: batch cancelInitiatedAt notNil.
	self assert: server lastRequestMethod equals: 'POST'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testCreateBatchEmptyRaises [
	"Empty params raise ClaudeInvalidRequestError client-side — never hits the wire."
	| params |
	params := ClaudeBatchCreateParams new.
	self should: [ client createBatch: params ] raise: ClaudeInvalidRequestError
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testCreateBatchSendsBetaHeaderAndBody [
	| msgReq params batch |
	server respondTo: 'v1/messages/batches' with: self sampleBatchJson.
	msgReq := ClaudeMessageRequest new
		model: 'claude-haiku-4-5';
		maxTokens: 16;
		addUserMessage: 'hi';
		yourself.
	params := ClaudeBatchCreateParams new
		addRequest: (ClaudeBatchRequest customId: 'r-1' params: msgReq);
		yourself.
	batch := client createBatch: params.
	self assert: batch id equals: 'batch-abc'.
	self assert: batch isInProgress.
	self assert: (server lastRequestHeaders at: 'anthropic-beta') equals: 'message-batches-2024-09-24'.
	self assert: server lastRequestMethod equals: 'POST'.
	self assert: ((server lastRequestBody at: 'requests') first at: 'custom_id') equals: 'r-1'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testDeleteBatch [
	| body deleted |
	body := STONJSON toString: (Dictionary newFromPairs: {
		'id'. 'batch-abc'. 'type'. 'message_batch_deleted' }).
	server respondTo: 'v1/messages/batches/batch-abc' with: body.
	deleted := client deleteBatch: 'batch-abc'.
	self assert: deleted id equals: 'batch-abc'.
	self assert: deleted type equals: 'message_batch_deleted'.
	self assert: server lastRequestMethod equals: 'DELETE'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testGetBatch [
	| batch |
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleBatchJson.
	batch := client getBatch: 'batch-abc'.
	self assert: batch id equals: 'batch-abc'.
	self assert: batch isInProgress.
	self assert: (server lastRequestHeaders at: 'anthropic-beta') equals: 'message-batches-2024-09-24'.
	self assert: server lastRequestMethod equals: 'GET'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testListBatchesNoParams [
	| body page |
	body := STONJSON toString: (Dictionary newFromPairs: {
		'data'. {  }.
		'has_more'. false }).
	server respondTo: 'v1/messages/batches' with: body.
	page := client listBatches.
	self assert: page data size equals: 0.
	self deny: page hasMore.
	self assert: server lastRequestPath equals: 'v1/messages/batches'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testListBatchesWithParams [
	| body page params query |
	body := STONJSON toString: (Dictionary newFromPairs: {
		'data'. {  }.
		'has_more'. false }).
	server respondTo: 'v1/messages/batches' with: body.
	params := ClaudeBatchListParams new
		afterId: 'batch-abc';
		limit: 25;
		yourself.
	page := client listBatches: params.
	self assert: page data size equals: 0.
	query := server lastRequest uri query.
	self assert: (query at: 'after_id') equals: 'batch-abc'.
	self assert: (query at: 'limit') equals: '25'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testStreamBatchResultsHandlesEmptyStream [
	| jsonl results |
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleEndedBatchJson.
	jsonl := ''.
	server respondTo: 'v1/messages/batches/batch-abc/results' with: jsonl.
	results := client streamBatchResults: 'batch-abc' do: [ :entry | self fail: 'block should not be called' ].
	self assert: results size equals: 0
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testStreamBatchResultsNoCallbackBeforeFullParse [
	"Structural guarantee: aBlock and results accumulation happen ONLY after
	 the entire response body has been parsed successfully. If any line fails
	 to parse, no entries are yielded and no partial collection is returned.
	 This is the property that prevents duplication on executeWithRetry: --
	 partial work from a failed attempt is structurally impossible."
	| jsonl line1 line2 badLine yielded |
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleEndedBatchJson.
	line1 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-1'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	line2 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-2'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	badLine := '{this is not valid json'.
	jsonl := line1 , String lf , line2 , String lf , badLine , String lf.
	server respondTo: 'v1/messages/batches/batch-abc/results' with: jsonl.
	yielded := OrderedCollection new.
	[ client streamBatchResults: 'batch-abc' do: [ :entry | yielded add: entry ] ]
		on: Error do: [ :e | "expected -- bad JSON in last line" ].
	self assert: yielded size equals: 0
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testStreamBatchResultsNoDuplicationOnRetry [
	"Regression for the Bugbot MEDIUM finding: when the results GET retries
	 (e.g., a transient 503), entries from the failed attempt must NOT appear
	 in the returned collection and aBlock must NOT be invoked twice per
	 entry. The fix parses the body fully before yielding to aBlock or
	 accumulating, so a partial parse on a failed attempt is discarded."
	| jsonl line1 line2 line3 successResp errorResp results yielded |
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleEndedBatchJson.
	line1 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-1'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	line2 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-2'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	line3 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-3'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	jsonl := line1 , String lf , line2 , String lf , line3 , String lf.
	errorResp := server errorResponse: 503 message: 'overloaded'.
	successResp := ZnResponse ok: (ZnEntity with: jsonl type: (ZnMimeType main: 'application' sub: 'x-jsonl')).
	server
		respondTo: 'v1/messages/batches/batch-abc/results'
		withSequence: (OrderedCollection with: errorResp with: successResp).
	client maxRetries: 1.
	yielded := OrderedCollection new.
	results := client streamBatchResults: 'batch-abc' do: [ :entry | yielded add: entry ].
	self assert: results size equals: 3.
	self assert: yielded size equals: 3.
	self assert: (results allSatisfy: [ :r | r isCanceled ])
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testStreamBatchResultsParsesJSONL [
	"streamBatchResults:do: GETs the results URL, parses each non-empty line
	 as a ClaudeBatchResult, and yields each entry to the block."
	| jsonl line1 line2 line3 results yielded |
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleEndedBatchJson.
	line1 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-1'.
		'result'. (Dictionary newFromPairs: {
			'type'. 'succeeded'.
			'message'. (Dictionary newFromPairs: {
				'id'. 'msg_01'. 'type'. 'message'. 'role'. 'assistant'.
				'model'. 'claude-haiku-4-5'.
				'content'. { Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'Hi' } }.
				'stop_reason'. 'end_turn'.
				'usage'. (Dictionary newFromPairs: { 'input_tokens'. 1. 'output_tokens'. 1 }) }) }) }).
	line2 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-2'.
		'result'. (Dictionary newFromPairs: { 'type'. 'canceled' }) }).
	line3 := STONJSON toString: (Dictionary newFromPairs: {
		'custom_id'. 'r-3'.
		'result'. (Dictionary newFromPairs: {
			'type'. 'errored'.
			'error'. (Dictionary newFromPairs: { 'type'. 'api_error'. 'message'. 'boom' }) }) }).
	jsonl := line1 , String lf , line2 , String lf , line3 , String lf.
	server respondTo: 'v1/messages/batches/batch-abc/results' with: jsonl.
	yielded := OrderedCollection new.
	results := client streamBatchResults: 'batch-abc' do: [ :entry | yielded add: entry ].
	self assert: results size equals: 3.
	self assert: yielded size equals: 3.
	self assert: results first customId equals: 'r-1'.
	self assert: results first isSucceeded.
	self assert: (results second isCanceled).
	self assert: results third isErrored.
	self assert: results third result error message equals: 'boom'
]

{ #category : 'tests' }
ClaudeBatchClientTest >> testStreamBatchResultsRaisesWhenNotEnded [
	"resultsUrl is nil because the batch is still in_progress — the client raises
	 ClaudeBatchNotEndedError without ever GETting the results URL."
	server respondTo: 'v1/messages/batches/batch-abc' with: self sampleBatchJson.
	self should: [ client streamBatchResults: 'batch-abc' do: [ :entry | ] ]
		raise: ClaudeBatchNotEndedError
]
