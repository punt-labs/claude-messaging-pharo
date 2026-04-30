"
The expired outcome variant of `ClaudeBatchResult`. Terminal state — the request was still pending when the 24-hour batch lifetime elapsed.

### Predicates

- `isExpired` answers `true`; the other three answer `false`.

### Accessor

- `type` — literal `'expired'`

### Example

```
ClaudeBatchExpiredResult new isExpired
>>> true
```

### See also

`ClaudeBatchResult` — the wrapper that holds this. The other three outcome variants.
"
Class {
	#name : 'ClaudeBatchExpiredResult',
	#superclass : 'Object',
	#instVars : [
		'type'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchExpiredResult class >> fromJson: aDictionary [
	^ self new
]

{ #category : 'json' }
ClaudeBatchExpiredResult >> asJson [
	^ OrderedDictionary new
		at: 'type' put: 'expired';
		yourself
]

{ #category : 'initialization' }
ClaudeBatchExpiredResult >> initialize [
	type := 'expired'
]

{ #category : 'testing' }
ClaudeBatchExpiredResult >> isCanceled [
	^ false
]

{ #category : 'testing' }
ClaudeBatchExpiredResult >> isErrored [
	^ false
]

{ #category : 'testing' }
ClaudeBatchExpiredResult >> isExpired [
	^ true
]

{ #category : 'testing' }
ClaudeBatchExpiredResult >> isSucceeded [
	^ false
]

{ #category : 'printing' }
ClaudeBatchExpiredResult >> printOn: aStream [
	aStream nextPutAll: 'ClaudeBatchExpiredResult()'
]

{ #category : 'accessing' }
ClaudeBatchExpiredResult >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeBatchExpiredResult >> type: aString [
	type := aString
]
