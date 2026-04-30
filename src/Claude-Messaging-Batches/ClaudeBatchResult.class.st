"
One entry in the JSONL results stream. Carries the developer-supplied `customId` (so callers can match results back to submitted requests) and a polymorphic `result` (one of the four outcome subclasses).

### Polymorphic dispatch

`fromJson:` reads the inner `result.type` and instantiates the matching outcome via `resultFromJson:`. Predicates `isSucceeded`, `isErrored`, `isCanceled`, `isExpired` delegate to the wrapped result. Callers dispatch without conditionals:

```
| stream |
stream := OrderedCollection new.
client streamBatchResults: 'batch-abc' do: [ :entry |
    entry isSucceeded ifTrue: [ stream add: entry result message ] ].
```

### Unknown result types

If the wire `result.type` does not match one of the four known tags, `resultFromJson:` returns a synthetic `ClaudeBatchErroredResult` with a payload describing the unknown type. The outcome is still polymorphic — callers never see a parse error mid-stream.

### Accessors

- `customId` — String; the id you submitted with the corresponding `ClaudeBatchRequest`
- `result` — one of: `ClaudeBatchSucceededResult`, `ClaudeBatchErroredResult`, `ClaudeBatchCanceledResult`, `ClaudeBatchExpiredResult`

### Example

```
(ClaudeBatchResult new
    customId: 'req-1';
    result: ClaudeBatchCanceledResult new;
    yourself) isCanceled
>>> true
```

### See also

`ClaudeClient >> streamBatchResults:do:` — the API entry that produces these. `ClaudeBatchSucceededResult`, `ClaudeBatchErroredResult`, `ClaudeBatchCanceledResult`, `ClaudeBatchExpiredResult` — the four outcome variants.
"
Class {
	#name : 'ClaudeBatchResult',
	#superclass : 'Object',
	#instVars : [
		'customId',
		'result'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchResult class >> fromJson: aDictionary [
	"Build a ClaudeBatchResult from a single JSONL line dictionary. The wire shape is
	 { 'custom_id': 'req-1', 'result': { 'type': 'succeeded', 'message': {...} } }.
	 Reads the inner result.type and dispatches to the correct outcome class. Unknown
	 types fall back to a synthetic errored result so callers always receive a polymorphic
	 ClaudeBatchResult — never a parse error mid-stream."
	^ self new
		customId: (aDictionary at: 'custom_id' ifAbsent: [ nil ]);
		result: (self resultFromJson: (aDictionary at: 'result' ifAbsent: [ Dictionary new ]));
		yourself
]

{ #category : 'json' }
ClaudeBatchResult class >> resultFromJson: aDict [
	"Dispatch on the result-type tag and instantiate the matching outcome subclass.
	 No conditional chains in the call sites — callers use polymorphism via isSucceeded,
	 isErrored, isCanceled, isExpired."
	| type |
	type := aDict at: 'type' ifAbsent: [ nil ].
	type = 'succeeded' ifTrue: [ ^ ClaudeBatchSucceededResult fromJson: aDict ].
	type = 'errored' ifTrue: [ ^ ClaudeBatchErroredResult fromJson: aDict ].
	type = 'canceled' ifTrue: [ ^ ClaudeBatchCanceledResult fromJson: aDict ].
	type = 'expired' ifTrue: [ ^ ClaudeBatchExpiredResult fromJson: aDict ].
	^ ClaudeBatchErroredResult unknown: (type ifNil: [ 'nil' ])
]

{ #category : 'json' }
ClaudeBatchResult >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'custom_id' put: customId.
	result ifNotNil: [ dict at: 'result' put: result asJson ].
	^ dict
]

{ #category : 'accessing' }
ClaudeBatchResult >> customId [ ^ customId
]

{ #category : 'accessing' }
ClaudeBatchResult >> customId: aString [ customId := aString
]

{ #category : 'testing' }
ClaudeBatchResult >> isCanceled [
	^ result ifNil: [ false ] ifNotNil: [ :r | r isCanceled ]
]

{ #category : 'testing' }
ClaudeBatchResult >> isErrored [
	^ result ifNil: [ false ] ifNotNil: [ :r | r isErrored ]
]

{ #category : 'testing' }
ClaudeBatchResult >> isExpired [
	^ result ifNil: [ false ] ifNotNil: [ :r | r isExpired ]
]

{ #category : 'testing' }
ClaudeBatchResult >> isSucceeded [
	"Delegate to the wrapped result so callers can ask the entry directly."
	^ result ifNil: [ false ] ifNotNil: [ :r | r isSucceeded ]
]

{ #category : 'printing' }
ClaudeBatchResult >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchResult(';
		nextPutAll: (customId ifNil: [ '?' ]);
		nextPutAll: ' ';
		print: result;
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeBatchResult >> result [ ^ result
]

{ #category : 'accessing' }
ClaudeBatchResult >> result: aResult [ result := aResult
]
