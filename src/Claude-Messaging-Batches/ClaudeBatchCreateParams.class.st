"
The body for `POST /v1/messages/batches`. Holds an `OrderedCollection` of `ClaudeBatchRequest` items. Build via `addRequest:` (chainable).

### Use

```
| params msgReq |
msgReq := ClaudeMessageRequest new
    model: 'claude-haiku-4-5';
    maxTokens: 256;
    addUserMessage: 'Hello';
    yourself.
params := ClaudeBatchCreateParams new
    addRequest: (ClaudeBatchRequest customId: 'req-1' params: msgReq);
    addRequest: (ClaudeBatchRequest customId: 'req-2' params: msgReq);
    yourself.
params size
>>> 2
```

### Accessors

- `requests` — OrderedCollection of `ClaudeBatchRequest`; mutable via `addRequest:`
- `addRequest:` — chainable; returns receiver
- `isEmpty` / `size` — convenience predicates

### Validation

`ClaudeClient >> createBatch:` raises `ClaudeInvalidRequestError` if `requests` is empty — caller-side guard against the API rejecting an empty batch with a 400.

### See also

`ClaudeBatchRequest` — each entry. `ClaudeClient >> createBatch:` — the API entry that consumes this.
"
Class {
	#name : 'ClaudeBatchCreateParams',
	#superclass : 'Object',
	#instVars : [
		'requests'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'building' }
ClaudeBatchCreateParams >> addRequest: aClaudeBatchRequest [
	"Append a request to the batch. Returns the receiver so adds can be chained."
	requests add: aClaudeBatchRequest.
	^ self
]

{ #category : 'json' }
ClaudeBatchCreateParams >> asJson [
	"Wire shape: { 'requests': [ {...}, ... ] }. STONJSON serializes Arrays as
	 JSON arrays; an OrderedCollection trips 'wrong object class for JSON mode',
	 so we materialize an Array."
	^ OrderedDictionary new
		at: 'requests' put: ((requests collect: [ :each | each asJson ]) asArray);
		yourself
]

{ #category : 'initialization' }
ClaudeBatchCreateParams >> initialize [
	requests := OrderedCollection new
]

{ #category : 'testing' }
ClaudeBatchCreateParams >> isEmpty [
	^ requests isEmpty
]

{ #category : 'printing' }
ClaudeBatchCreateParams >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchCreateParams(';
		print: requests size;
		nextPutAll: ' requests)'
]

{ #category : 'accessing' }
ClaudeBatchCreateParams >> requests [ ^ requests
]

{ #category : 'accessing' }
ClaudeBatchCreateParams >> size [
	^ requests size
]
