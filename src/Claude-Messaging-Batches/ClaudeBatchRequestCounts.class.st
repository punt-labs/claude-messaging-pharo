"
Per-status tally inside `ClaudeBatch >> requestCounts`. Counts how many requests in the batch are in each lifecycle state. All five fields default to 0; meaningful values arrive when the batch reaches `processingStatus = 'ended'`.

### Accessors

- `processing` — Integer; still being processed
- `succeeded` — Integer; produced a `ClaudeBatchSucceededResult` in the JSONL stream
- `errored` — Integer; produced a `ClaudeBatchErroredResult`
- `canceled` — Integer; produced a `ClaudeBatchCanceledResult`
- `expired` — Integer; produced a `ClaudeBatchExpiredResult`
- `total` — sum of all five; equals the total number of requests submitted

### Example

```
(ClaudeBatchRequestCounts new succeeded: 5; errored: 2; yourself) total
>>> 7
```

```
| counts |
counts := ClaudeBatchRequestCounts fromJson: (Dictionary newFromPairs: {
    'processing'. 0. 'succeeded'. 10. 'errored'. 0. 'canceled'. 0. 'expired'. 0 }).
counts succeeded
>>> 10
```

### See also

`ClaudeBatch >> requestCounts` — where this lives. The four `ClaudeBatchResult` outcome subclasses — what each non-zero count maps to in the results stream.
"
Class {
	#name : 'ClaudeBatchRequestCounts',
	#superclass : 'Object',
	#instVars : [
		'processing',
		'succeeded',
		'errored',
		'canceled',
		'expired'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchRequestCounts class >> fromJson: aDictionary [
	^ self new
		processing: (aDictionary at: 'processing' ifAbsent: [ 0 ]);
		succeeded: (aDictionary at: 'succeeded' ifAbsent: [ 0 ]);
		errored: (aDictionary at: 'errored' ifAbsent: [ 0 ]);
		canceled: (aDictionary at: 'canceled' ifAbsent: [ 0 ]);
		expired: (aDictionary at: 'expired' ifAbsent: [ 0 ]);
		yourself
]

{ #category : 'json' }
ClaudeBatchRequestCounts >> asJson [
	^ OrderedDictionary new
		at: 'processing' put: processing;
		at: 'succeeded' put: succeeded;
		at: 'errored' put: errored;
		at: 'canceled' put: canceled;
		at: 'expired' put: expired;
		yourself
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> canceled [ ^ canceled
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> canceled: anInteger [ canceled := anInteger
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> errored [ ^ errored
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> errored: anInteger [ errored := anInteger
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> expired [ ^ expired
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> expired: anInteger [ expired := anInteger
]

{ #category : 'initialization' }
ClaudeBatchRequestCounts >> initialize [
	processing := 0.
	succeeded := 0.
	errored := 0.
	canceled := 0.
	expired := 0
]

{ #category : 'printing' }
ClaudeBatchRequestCounts >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchRequestCounts(processing: ';
		print: processing;
		nextPutAll: ' succeeded: ';
		print: succeeded;
		nextPutAll: ' errored: ';
		print: errored;
		nextPutAll: ' canceled: ';
		print: canceled;
		nextPutAll: ' expired: ';
		print: expired;
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> processing [ ^ processing
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> processing: anInteger [ processing := anInteger
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> succeeded [ ^ succeeded
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> succeeded: anInteger [ succeeded := anInteger
]

{ #category : 'accessing' }
ClaudeBatchRequestCounts >> total [
	"Total of all per-status counts. Equals the total number of requests submitted in the batch."
	^ processing + succeeded + errored + canceled + expired
]
