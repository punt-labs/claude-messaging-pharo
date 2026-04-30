"
The primary batch object returned by createBatch:, getBatch:, and cancelBatch:. Mirrors the Anthropic Messages Batches API resource shape. Carries lifecycle state (processingStatus), tally counts (requestCounts), the URL where JSONL results live once ended (resultsUrl), and lifecycle timestamps.

### When you see it

createBatch: returns one with processingStatus = 'in_progress' and resultsUrl = nil. Poll via getBatch: (or pollBatch:untilEndedEvery:) until isEnded; only then is resultsUrl populated and streamBatchResults:do: succeeds.

### Accessors

- `id` — opaque batch id
- `processingStatus` — one of `'in_progress'`, `'canceling'`, `'ended'`. Predicates: `isInProgress`, `isCanceling`, `isEnded`.
- `requestCounts` — `ClaudeBatchRequestCounts`; per-status tally
- `createdAt` / `expiresAt` — RFC 3339 timestamps; `expiresAt` is always `createdAt + 24h`
- `endedAt` / `cancelInitiatedAt` / `archivedAt` — RFC 3339 or nil; populated as the batch transitions
- `resultsUrl` — URL to the JSONL results file; nil until `isEnded`
- `type` — literal `'message_batch'`

### Example

```
(ClaudeBatch new
    id: 'batch-abc';
    processingStatus: 'in_progress';
    yourself) isInProgress
>>> true
```

```
| batch |
batch := ClaudeBatch fromJson: (Dictionary newFromPairs: {
    'id'. 'batch-abc'.
    'processing_status'. 'ended'.
    'request_counts'. (Dictionary newFromPairs: {
        'processing'. 0. 'succeeded'. 5. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
    'created_at'. '2026-04-23T00:00:00Z'.
    'expires_at'. '2026-04-24T00:00:00Z'.
    'results_url'. 'https://api.anthropic.com/v1/messages/batches/batch-abc/results' }).
batch isEnded
>>> true
```

### See also

`ClaudeBatchPage` — list-call wrapper. `ClaudeBatchRequestCounts` — the tally object inside `requestCounts`. `ClaudeClient >> getBatch:`, `pollBatch:untilEndedEvery:`, `streamBatchResults:do:` — the API entries that consume this.
"
Class {
	#name : 'ClaudeBatch',
	#superclass : 'Object',
	#instVars : [
		'id',
		'processingStatus',
		'requestCounts',
		'createdAt',
		'expiresAt',
		'endedAt',
		'cancelInitiatedAt',
		'archivedAt',
		'resultsUrl',
		'type'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatch class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		processingStatus: (aDictionary at: 'processing_status' ifAbsent: [ nil ]);
		requestCounts: (ClaudeBatchRequestCounts fromJson: (aDictionary at: 'request_counts' ifAbsent: [ Dictionary new ]));
		createdAt: (aDictionary at: 'created_at' ifAbsent: [ nil ]);
		expiresAt: (aDictionary at: 'expires_at' ifAbsent: [ nil ]);
		endedAt: (aDictionary at: 'ended_at' ifAbsent: [ nil ]);
		cancelInitiatedAt: (aDictionary at: 'cancel_initiated_at' ifAbsent: [ nil ]);
		archivedAt: (aDictionary at: 'archived_at' ifAbsent: [ nil ]);
		resultsUrl: (aDictionary at: 'results_url' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'message_batch' ]);
		yourself
]

{ #category : 'json' }
ClaudeBatch class >> jsonKeyMap [
	^ {
		#processingStatus -> 'processing_status'.
		#requestCounts -> 'request_counts'.
		#createdAt -> 'created_at'.
		#expiresAt -> 'expires_at'.
		#endedAt -> 'ended_at'.
		#cancelInitiatedAt -> 'cancel_initiated_at'.
		#archivedAt -> 'archived_at'.
		#resultsUrl -> 'results_url'
	} asDictionary
]

{ #category : 'accessing' }
ClaudeBatch >> archivedAt [ ^ archivedAt
]

{ #category : 'accessing' }
ClaudeBatch >> archivedAt: aString [ archivedAt := aString
]

{ #category : 'json' }
ClaudeBatch >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'id' put: id.
	dict at: 'type' put: type.
	dict at: 'processing_status' put: processingStatus.
	requestCounts ifNotNil: [ dict at: 'request_counts' put: requestCounts asJson ].
	dict at: 'created_at' put: createdAt.
	dict at: 'expires_at' put: expiresAt.
	endedAt ifNotNil: [ dict at: 'ended_at' put: endedAt ].
	cancelInitiatedAt ifNotNil: [ dict at: 'cancel_initiated_at' put: cancelInitiatedAt ].
	archivedAt ifNotNil: [ dict at: 'archived_at' put: archivedAt ].
	resultsUrl ifNotNil: [ dict at: 'results_url' put: resultsUrl ].
	^ dict
]

{ #category : 'accessing' }
ClaudeBatch >> cancelInitiatedAt [ ^ cancelInitiatedAt
]

{ #category : 'accessing' }
ClaudeBatch >> cancelInitiatedAt: aString [ cancelInitiatedAt := aString
]

{ #category : 'accessing' }
ClaudeBatch >> createdAt [ ^ createdAt
]

{ #category : 'accessing' }
ClaudeBatch >> createdAt: aString [ createdAt := aString
]

{ #category : 'accessing' }
ClaudeBatch >> endedAt [ ^ endedAt
]

{ #category : 'accessing' }
ClaudeBatch >> endedAt: aString [ endedAt := aString
]

{ #category : 'accessing' }
ClaudeBatch >> expiresAt [ ^ expiresAt
]

{ #category : 'accessing' }
ClaudeBatch >> expiresAt: aString [ expiresAt := aString
]

{ #category : 'accessing' }
ClaudeBatch >> id [ ^ id
]

{ #category : 'accessing' }
ClaudeBatch >> id: aString [ id := aString
]

{ #category : 'initialization' }
ClaudeBatch >> initialize [
	type := 'message_batch'
]

{ #category : 'testing' }
ClaudeBatch >> isCanceling [ ^ processingStatus = 'canceling'
]

{ #category : 'testing' }
ClaudeBatch >> isEnded [ ^ processingStatus = 'ended'
]

{ #category : 'testing' }
ClaudeBatch >> isInProgress [ ^ processingStatus = 'in_progress'
]

{ #category : 'printing' }
ClaudeBatch >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatch(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPutAll: ' ';
		nextPutAll: (processingStatus ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeBatch >> processingStatus [ ^ processingStatus
]

{ #category : 'accessing' }
ClaudeBatch >> processingStatus: aString [ processingStatus := aString
]

{ #category : 'accessing' }
ClaudeBatch >> requestCounts [ ^ requestCounts
]

{ #category : 'accessing' }
ClaudeBatch >> requestCounts: aClaudeBatchRequestCounts [ requestCounts := aClaudeBatchRequestCounts
]

{ #category : 'accessing' }
ClaudeBatch >> resultsUrl [ ^ resultsUrl
]

{ #category : 'accessing' }
ClaudeBatch >> resultsUrl: aString [ resultsUrl := aString
]

{ #category : 'accessing' }
ClaudeBatch >> type [ ^ type
]

{ #category : 'accessing' }
ClaudeBatch >> type: aString [ type := aString
]
