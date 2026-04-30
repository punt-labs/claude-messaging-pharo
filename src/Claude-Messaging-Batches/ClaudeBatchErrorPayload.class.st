"
The inner `error` field of a `ClaudeBatchErroredResult`. Mirrors the error shape Anthropic uses elsewhere (`type` + `message` Strings).

### Accessors

- `type` — String; Anthropic error-type tag (e.g. `'invalid_request_error'`, `'api_error'`)
- `message` — String; human-readable description

### Example

```
(ClaudeBatchErrorPayload new type: 'invalid_request_error'; message: 'bad input'; yourself) type
>>> 'invalid_request_error'
```

### See also

`ClaudeBatchErroredResult` — wraps this in the result hierarchy. `ClaudeApiError` — the analogous base class for HTTP errors.
"
Class {
	#name : 'ClaudeBatchErrorPayload',
	#superclass : 'Object',
	#instVars : [
		'type',
		'message'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'json' }
ClaudeBatchErrorPayload class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ nil ]);
		message: (aDictionary at: 'message' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeBatchErrorPayload >> asJson [
	| dict |
	dict := OrderedDictionary new.
	type ifNotNil: [ dict at: 'type' put: type ].
	message ifNotNil: [ dict at: 'message' put: message ].
	^ dict
]

{ #category : 'accessing' }
ClaudeBatchErrorPayload >> message [
	^ message
]

{ #category : 'accessing' }
ClaudeBatchErrorPayload >> message: aString [
	message := aString
]

{ #category : 'printing' }
ClaudeBatchErrorPayload >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchErrorPayload(';
		nextPutAll: (type ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeBatchErrorPayload >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeBatchErrorPayload >> type: aString [
	type := aString
]
