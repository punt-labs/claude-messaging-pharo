"
The successful outcome variant of `ClaudeBatchResult`. Wraps a `ClaudeMessage` — the same shape `ClaudeClient >> sendMessage:` returns synchronously, so callers can reuse all the existing Messages-API helpers (`textContent`, `toolUseBlocks`, etc.).

### Predicates

- `isSucceeded` answers `true`; the other three (`isErrored`, `isCanceled`, `isExpired`) answer `false`. Polymorphic dispatch — callers avoid type-checking on `type`.

### Accessors

- `type` — literal `'succeeded'`
- `message` — `ClaudeMessage`; the API response for this batch entry

### Example

```
ClaudeBatchSucceededResult new isSucceeded
>>> true
```

```
ClaudeBatchSucceededResult new isErrored
>>> false
```

### See also

`ClaudeBatchResult` — the wrapper that holds this. `ClaudeMessage` — the wrapped response. The other three outcome variants.
"
Class {
	#name : 'ClaudeBatchSucceededResult',
	#superclass : 'Object',
	#instVars : [
		'type',
		'message'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchSucceededResult class >> fromJson: aDictionary [
	^ self new
		type: 'succeeded';
		message: (ClaudeMessage fromJson: (aDictionary at: 'message' ifAbsent: [ Dictionary new ]));
		yourself
]

{ #category : 'json' }
ClaudeBatchSucceededResult >> asJson [
	^ OrderedDictionary new
		at: 'type' put: 'succeeded';
		at: 'message' put: message asJson;
		yourself
]

{ #category : 'initialization' }
ClaudeBatchSucceededResult >> initialize [
	type := 'succeeded'
]

{ #category : 'testing' }
ClaudeBatchSucceededResult >> isCanceled [
	^ false
]

{ #category : 'testing' }
ClaudeBatchSucceededResult >> isErrored [
	^ false
]

{ #category : 'testing' }
ClaudeBatchSucceededResult >> isExpired [
	^ false
]

{ #category : 'testing' }
ClaudeBatchSucceededResult >> isSucceeded [
	^ true
]

{ #category : 'accessing' }
ClaudeBatchSucceededResult >> message [
	^ message
]

{ #category : 'accessing' }
ClaudeBatchSucceededResult >> message: aClaudeMessage [
	message := aClaudeMessage
]

{ #category : 'printing' }
ClaudeBatchSucceededResult >> printOn: aStream [
	aStream nextPutAll: 'ClaudeBatchSucceededResult()'
]

{ #category : 'accessing' }
ClaudeBatchSucceededResult >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeBatchSucceededResult >> type: aString [
	type := aString
]
