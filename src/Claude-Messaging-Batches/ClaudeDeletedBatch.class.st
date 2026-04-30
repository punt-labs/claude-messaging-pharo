"
Confirmation record returned by `ClaudeClient >> deleteBatch:`. Carries the `id` of the deleted batch and a literal `type` of `'message_batch_deleted'` so callers can disambiguate from other Batches API response shapes on wire logs.

### When you see it

Only as the return value of `deleteBatch:`. A successful delete returns one of these; a failure (most commonly delete-while-not-ended) raises a `ClaudeApiError` subclass (typically `ClaudeInvalidRequestError`).

### Accessors

- `id` — the batch id that was deleted, echoed back from the request
- `type` — always `'message_batch_deleted'`; the API discriminator

### Example

```
(ClaudeDeletedBatch new id: 'batch-abc'; yourself) type
>>> 'message_batch_deleted'
```

```
(ClaudeDeletedBatch new id: 'batch-abc'; yourself) id
>>> 'batch-abc'
```

### See also

`ClaudeDeletedFile` / `ClaudeDeletedSkill` — same `id` + `type` shape across other Anthropic delete endpoints. `ClaudeClient >> deleteBatch:` — the API entry that returns this.
"
Class {
	#name : 'ClaudeDeletedBatch',
	#superclass : 'Object',
	#instVars : [
		'id',
		'type'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeDeletedBatch class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'message_batch_deleted' ]);
		yourself
]

{ #category : 'json' }
ClaudeDeletedBatch >> asJson [
	^ OrderedDictionary new
		at: 'id' put: id;
		at: 'type' put: type;
		yourself
]

{ #category : 'accessing' }
ClaudeDeletedBatch >> id [ ^ id
]

{ #category : 'accessing' }
ClaudeDeletedBatch >> id: aString [ id := aString
]

{ #category : 'initialization' }
ClaudeDeletedBatch >> initialize [
	type := 'message_batch_deleted'
]

{ #category : 'printing' }
ClaudeDeletedBatch >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeDeletedBatch(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeDeletedBatch >> type [ ^ type
]

{ #category : 'accessing' }
ClaudeDeletedBatch >> type: aString [ type := aString
]
