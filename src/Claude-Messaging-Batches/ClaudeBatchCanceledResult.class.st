"
The canceled outcome variant of `ClaudeBatchResult`. Terminal state — no payload beyond the `type` discriminator.

### Predicates

- `isCanceled` answers `true`; the other three answer `false`.

### Accessor

- `type` — literal `'canceled'`

### Example

```
ClaudeBatchCanceledResult new isCanceled
>>> true
```

### See also

`ClaudeBatchResult` — the wrapper that holds this. The other three outcome variants.
"
Class {
	#name : 'ClaudeBatchCanceledResult',
	#superclass : 'Object',
	#instVars : [
		'type'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchCanceledResult class >> fromJson: aDictionary [
	^ self new
]

{ #category : 'json' }
ClaudeBatchCanceledResult >> asJson [
	^ OrderedDictionary new
		at: 'type' put: 'canceled';
		yourself
]

{ #category : 'initialization' }
ClaudeBatchCanceledResult >> initialize [
	type := 'canceled'
]

{ #category : 'testing' }
ClaudeBatchCanceledResult >> isCanceled [
	^ true
]

{ #category : 'testing' }
ClaudeBatchCanceledResult >> isErrored [
	^ false
]

{ #category : 'testing' }
ClaudeBatchCanceledResult >> isExpired [
	^ false
]

{ #category : 'testing' }
ClaudeBatchCanceledResult >> isSucceeded [
	^ false
]

{ #category : 'printing' }
ClaudeBatchCanceledResult >> printOn: aStream [
	aStream nextPutAll: 'ClaudeBatchCanceledResult()'
]

{ #category : 'accessing' }
ClaudeBatchCanceledResult >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeBatchCanceledResult >> type: aString [
	type := aString
]
