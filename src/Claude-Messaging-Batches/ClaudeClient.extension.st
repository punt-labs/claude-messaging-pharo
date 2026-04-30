Extension { #name : 'ClaudeClient' }

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> cancelBatch: aBatchId [
	"Cancel an in-progress batch. Returns ClaudeBatch with processingStatus = 'canceling'.
	 Only succeeds while the batch is still in_progress; canceling an ended batch yields
	 a 400 from the server."
	^ self executeWithRetry: [
		| http resp |
		http := self newBatchHttpClient.
		http url: baseUrl, '/v1/messages/batches/', aBatchId, '/cancel'.
		resp := http post; response.
		self checkResponse: resp.
		ClaudeBatch fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> createBatch: aClaudeBatchCreateParams [
	"Submit a new batch. Returns ClaudeBatch. Raises ClaudeInvalidRequestError if
	 requests is empty. The returned batch starts with processingStatus = 'in_progress'
	 and resultsUrl = nil; poll getBatch: until isEnded before requesting results."
	aClaudeBatchCreateParams isEmpty ifTrue: [
		(ClaudeInvalidRequestError new
			statusCode: 400;
			message: 'Cannot create a batch with zero requests';
			yourself) signal ].
	^ self executeWithRetry: [
		| http body resp |
		http := self newBatchHttpClient.
		body := STONJSON toString: aClaudeBatchCreateParams asJson.
		http
			url: baseUrl, '/v1/messages/batches';
			entity: (ZnEntity json: body).
		resp := http post; response.
		self checkResponse: resp.
		ClaudeBatch fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> deleteBatch: aBatchId [
	"Delete a batch. Returns ClaudeDeletedBatch. Only valid once processingStatus = 'ended'
	 — the API returns 400 (ClaudeInvalidRequestError) for in-progress or canceling batches.
	 Cancel first, wait for ended, then delete."
	^ self executeWithRetry: [
		| http resp |
		http := self newBatchHttpClient.
		http url: baseUrl, '/v1/messages/batches/', aBatchId.
		resp := http delete; response.
		self checkResponse: resp.
		ClaudeDeletedBatch fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> getBatch: aBatchId [
	"Fetch a batch by id. Returns ClaudeBatch. Idempotent — safe to call repeatedly
	 for polling until isEnded."
	^ self executeWithRetry: [
		| http resp |
		http := self newBatchHttpClient.
		http url: baseUrl, '/v1/messages/batches/', aBatchId.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeBatch fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> listBatches [
	"List batches with default pagination. Returns ClaudeBatchPage."
	^ self listBatches: nil
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> listBatches: aClaudeBatchListParamsOrNil [
	"List batches with optional pagination params. Returns ClaudeBatchPage. Iterate
	 by feeding page lastId into the next call's afterId until hasMore = false."
	^ self executeWithRetry: [
		| http url resp |
		http := self newBatchHttpClient.
		url := baseUrl, '/v1/messages/batches'.
		aClaudeBatchListParamsOrNil ifNotNil: [ :params |
			url := self appendQueryParams: params asQueryParams toUrl: url ].
		http url: url.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeBatchPage fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> newBatchHttpClient [
	"Create a ZnClient with auth headers and the Message Batches API beta header.
	 Mirrors newFileHttpClient — every /v1/messages/batches endpoint uses this
	 client so the message-batches-2024-09-24 beta header travels on every call
	 without callers having to spell it."
	^ ZnClient new
		headerAt: 'x-api-key' put: apiKey;
		headerAt: 'anthropic-version' put: apiVersion;
		headerAt: 'anthropic-beta' put: ClaudeBetaHeader messageBatches;
		headerAt: 'accept' put: 'application/json';
		timeout: timeout;
		yourself
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> pollBatch: aBatchId untilEndedEvery: aDurationOrSeconds [
	"Poll getBatch: until processingStatus = 'ended'. Returns the final ClaudeBatch.
	 Does not fetch results — callers follow up with streamBatchResults:do:.
	 aDurationOrSeconds may be a Duration or a Number of seconds."
	| delay current |
	delay := aDurationOrSeconds isNumber
		ifTrue: [ Duration seconds: aDurationOrSeconds ]
		ifFalse: [ aDurationOrSeconds ].
	[ current := self getBatch: aBatchId.
	  current isEnded ] whileFalse: [
		(Delay forMilliseconds: delay asMilliSeconds) wait ].
	^ current
]

{ #category : '*Claude-Messaging-Batches' }
ClaudeClient >> streamBatchResults: aBatchId do: aBlock [
	"Fetch and parse the JSONL results for an ended batch. Calls aBlock with each
	 ClaudeBatchResult as it arrives; returns an OrderedCollection of every result.
	 Raises ClaudeBatchNotEndedError if resultsUrl is nil (batch hasn't ended yet —
	 poll getBatch: or use pollBatch:untilEndedEvery: first). Defensive against
	 a 200 with an empty body — yields no entries instead of raising on nil body."
	| batch results |
	batch := self getBatch: aBatchId.
	batch resultsUrl ifNil: [ ClaudeBatchNotEndedError signal ].
	results := OrderedCollection new.
	self executeWithRetry: [
		| http resp body |
		http := self newBatchHttpClient.
		http
			headerAt: 'accept' put: 'application/x-jsonl';
			url: batch resultsUrl.
		resp := http get; response.
		self checkResponse: resp.
		body := (resp contents ifNil: [ '' ]) asString.
		(body lines reject: [ :line | line trimBoth isEmpty ]) do: [ :line |
			| entry |
			entry := ClaudeBatchResult fromJson: (STONJSON fromString: line).
			results add: entry.
			aBlock value: entry ] ].
	^ results
]
