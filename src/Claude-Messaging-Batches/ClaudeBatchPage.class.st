"
A paginated list of batches returned by `ClaudeClient >> listBatches` and `listBatches:`. Cursor-ID pagination — same shape as `ClaudeFilePage`.

### Iteration

```
| client params all page |
client := ClaudeClient apiKey: 'sk-ant-...'.
params := ClaudeBatchListParams new limit: 100; yourself.
all := OrderedCollection new.
[ page := client listBatches: params.
  all addAll: page data.
  page hasMore ] whileTrue: [
    params afterId: page lastId ].
```

### Accessors

- `data` — Array of `ClaudeBatch` for this page
- `hasMore` — Boolean; true when another page exists
- `firstId` / `lastId` — cursor IDs of the first and last entries; pass `lastId` back as `afterId` (or `firstId` as `beforeId`) on the next call

### Example

```
ClaudeBatchPage new hasMore
>>> false
```

```
| page |
page := ClaudeBatchPage fromJson: (Dictionary newFromPairs: {
    'data'. #().
    'has_more'. true.
    'first_id'. 'batch-abc'.
    'last_id'. 'batch-xyz' }).
page lastId
>>> 'batch-xyz'
```

### See also

`ClaudeBatchListParams` — the request-side cursor carrier. `ClaudeBatch` — each `data` entry. `ClaudeFilePage` — sibling cursor-ID page in the Files API.
"
Class {
	#name : 'ClaudeBatchPage',
	#superclass : 'Object',
	#instVars : [
		'data',
		'hasMore',
		'firstId',
		'lastId'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchPage class >> fromJson: aDictionary [
	^ self new
		data: ((aDictionary at: 'data' ifAbsent: [ Array new ]) collect: [ :each |
			ClaudeBatch fromJson: each ]);
		hasMore: (aDictionary at: 'has_more' ifAbsent: [ false ]);
		firstId: (aDictionary at: 'first_id' ifAbsent: [ nil ]);
		lastId: (aDictionary at: 'last_id' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeBatchPage class >> jsonKeyMap [
	^ {
		#hasMore -> 'has_more'.
		#firstId -> 'first_id'.
		#lastId -> 'last_id'
	} asDictionary
]

{ #category : 'json' }
ClaudeBatchPage >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'data' put: ((data collect: [ :each | each asJson ]) asArray).
	dict at: 'has_more' put: hasMore.
	firstId ifNotNil: [ dict at: 'first_id' put: firstId ].
	lastId ifNotNil: [ dict at: 'last_id' put: lastId ].
	^ dict
]

{ #category : 'accessing' }
ClaudeBatchPage >> data [ ^ data
]

{ #category : 'accessing' }
ClaudeBatchPage >> data: anArray [ data := anArray
]

{ #category : 'accessing' }
ClaudeBatchPage >> firstId [ ^ firstId
]

{ #category : 'accessing' }
ClaudeBatchPage >> firstId: aString [ firstId := aString
]

{ #category : 'accessing' }
ClaudeBatchPage >> hasMore [ ^ hasMore
]

{ #category : 'accessing' }
ClaudeBatchPage >> hasMore: aBoolean [ hasMore := aBoolean
]

{ #category : 'initialization' }
ClaudeBatchPage >> initialize [
	data := Array new.
	hasMore := false
]

{ #category : 'accessing' }
ClaudeBatchPage >> lastId [ ^ lastId
]

{ #category : 'accessing' }
ClaudeBatchPage >> lastId: aString [ lastId := aString
]

{ #category : 'printing' }
ClaudeBatchPage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchPage(';
		print: data size;
		nextPutAll: ' batches, hasMore: ';
		print: hasMore;
		nextPut: $)
]
