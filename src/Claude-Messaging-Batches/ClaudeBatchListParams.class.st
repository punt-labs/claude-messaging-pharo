"
Query parameters for `ClaudeClient >> listBatches:`. Cursor-based pagination same shape as `ClaudeFileListParams` — set `afterId` (or `beforeId`) to a cursor returned by the previous page's `lastId` (or `firstId`), and optionally cap page size with `limit`.

### When you touch it

When the default `listBatches` page (no params) is not what you want. Typical: walking multiple pages (pass the previous `lastId` as `afterId`), paging backward (`beforeId`), or capping page size (`limit`).

```
| client params page |
client := ClaudeClient apiKey: 'sk-ant-...'.
params := ClaudeBatchListParams new
    afterId: 'batch-abc';
    limit: 50;
    yourself.
page := client listBatches: params.
```

### Accessors and defaults

- `afterId` — cursor id; forward pagination. Default nil.
- `beforeId` — cursor id; backward pagination. Default nil.
- `limit` — page size (Integer). Default nil (server default applies; capped at 100). Enforced server-side.

### Example

```
(ClaudeBatchListParams new afterId: 'batch-abc'; limit: 50; yourself) asQueryParams size
>>> 2
```

### See also

`ClaudeBatchPage >> lastId` / `firstId` — where the next cursor comes from. `ClaudeClient >> listBatches:` — the API entry that consumes this.
"
Class {
	#name : 'ClaudeBatchListParams',
	#superclass : 'Object',
	#instVars : [
		'limit',
		'afterId',
		'beforeId'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchListParams class >> jsonKeyMap [
	^ {
		#afterId -> 'after_id'.
		#beforeId -> 'before_id'
	} asDictionary
]

{ #category : 'accessing' }
ClaudeBatchListParams >> afterId [ ^ afterId
]

{ #category : 'accessing' }
ClaudeBatchListParams >> afterId: aString [ afterId := aString
]

{ #category : 'converting' }
ClaudeBatchListParams >> asQueryParams [
	"Build a Dictionary of query parameters for /v1/messages/batches.
	 nil-valued slots are omitted so the URL stays minimal. limit is rendered
	 with printString to keep the encoding consistent with sibling list-params."
	| params |
	params := Dictionary new.
	afterId ifNotNil: [ params at: 'after_id' put: afterId ].
	beforeId ifNotNil: [ params at: 'before_id' put: beforeId ].
	limit ifNotNil: [ params at: 'limit' put: limit printString ].
	^ params
]

{ #category : 'accessing' }
ClaudeBatchListParams >> beforeId [ ^ beforeId
]

{ #category : 'accessing' }
ClaudeBatchListParams >> beforeId: aString [ beforeId := aString
]

{ #category : 'accessing' }
ClaudeBatchListParams >> limit [ ^ limit
]

{ #category : 'accessing' }
ClaudeBatchListParams >> limit: anInteger [ limit := anInteger
]

{ #category : 'printing' }
ClaudeBatchListParams >> printOn: aStream [
	aStream nextPutAll: 'ClaudeBatchListParams('.
	afterId ifNotNil: [ aStream nextPutAll: 'after: '; nextPutAll: afterId; nextPut: $  ].
	beforeId ifNotNil: [ aStream nextPutAll: 'before: '; nextPutAll: beforeId; nextPut: $  ].
	limit ifNotNil: [ aStream nextPutAll: 'limit: '; print: limit ].
	aStream nextPut: $)
]
