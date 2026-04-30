"
The errored outcome variant of `ClaudeBatchResult`. Wraps a `ClaudeBatchErrorPayload` (the inner `error.type` + `error.message`).

### Predicates

- `isErrored` answers `true`; the other three answer `false`.

### Accessors

- `type` — literal `'errored'`
- `error` — `ClaudeBatchErrorPayload`; the inner failure description

### Unknown-type fallback

`ClaudeBatchErroredResult class >> unknown:` builds a synthetic instance for unknown wire `result.type` values — see `ClaudeBatchResult class >> resultFromJson:`. The outcome is still polymorphic.

### Example

```
ClaudeBatchErroredResult new isErrored
>>> true
```

```
(ClaudeBatchErroredResult unknown: 'mystery') error message
>>> 'Unknown batch result type: ''mystery'''
```

### See also

`ClaudeBatchResult` — the wrapper that holds this. `ClaudeBatchErrorPayload` — the inner payload. The other three outcome variants.
"
Class {
	#name : 'ClaudeBatchErroredResult',
	#superclass : 'Object',
	#instVars : [
		'type',
		'error'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchErroredResult class >> fromJson: aDictionary [
	^ self new
		type: 'errored';
		error: (ClaudeBatchErrorPayload fromJson: (aDictionary at: 'error' ifAbsent: [ Dictionary new ]));
		yourself
]

{ #category : 'instance creation' }
ClaudeBatchErroredResult class >> unknown: aTypeString [
	"Build a fallback errored result for an unknown result type tag. Used by
	 ClaudeBatchResult class >> resultFromJson: when the wire type is not one
	 of the four known outcomes. Keeps the call site polymorphic — the unknown
	 result still answers isErrored."
	| payload |
	payload := ClaudeBatchErrorPayload new
		type: 'unknown_result_type';
		message: 'Unknown batch result type: ' , aTypeString printString;
		yourself.
	^ self new
		type: 'errored';
		error: payload;
		yourself
]

{ #category : 'json' }
ClaudeBatchErroredResult >> asJson [
	"Wire shape: { 'type': 'errored', 'error': { <ClaudeBatchErrorPayload> } }.
	 Omits the 'error' key when the slot is nil — matches the ifNotNil:-omit
	 idiom used by ClaudeBatch>>asJson for partial objects."
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'errored'.
	error ifNotNil: [ dict at: 'error' put: error asJson ].
	^ dict
]

{ #category : 'error handling' }
ClaudeBatchErroredResult >> error [
	^ error
]

{ #category : 'error handling' }
ClaudeBatchErroredResult >> error: aClaudeBatchErrorPayload [
	error := aClaudeBatchErrorPayload
]

{ #category : 'initialization' }
ClaudeBatchErroredResult >> initialize [
	type := 'errored'
]

{ #category : 'testing' }
ClaudeBatchErroredResult >> isCanceled [
	^ false
]

{ #category : 'testing' }
ClaudeBatchErroredResult >> isErrored [
	^ true
]

{ #category : 'testing' }
ClaudeBatchErroredResult >> isExpired [
	^ false
]

{ #category : 'testing' }
ClaudeBatchErroredResult >> isSucceeded [
	^ false
]

{ #category : 'printing' }
ClaudeBatchErroredResult >> printOn: aStream [
	aStream nextPutAll: 'ClaudeBatchErroredResult('.
	error ifNotNil: [ aStream nextPutAll: (error message ifNil: [ '' ]) ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
ClaudeBatchErroredResult >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeBatchErroredResult >> type: aString [
	type := aString
]
