"
One item in a batch submission. Pairs a developer-supplied `customId` with a `ClaudeMessageRequest` that holds the full Messages-API parameters for this entry.

### Use

```
| msgReq batchReq |
msgReq := ClaudeMessageRequest new
    model: 'claude-haiku-4-5';
    maxTokens: 256;
    addUserMessage: 'Hello';
    yourself.
batchReq := ClaudeBatchRequest customId: 'req-1' params: msgReq.
batchReq customId
>>> 'req-1'
```

### Accessors

- `customId` — String; developer-assigned, must be unique within the batch. Echoed back on every `ClaudeBatchResult` so callers can match results to their submitted requests.
- `params` — `ClaudeMessageRequest` (or its raw Dictionary form when round-tripped from JSON); the full message request for this item.

### Round-tripping

`fromJson:` keeps `params` as the raw Dictionary because `ClaudeMessageRequest` is a builder class without a symmetric `fromJson:`. Round-tripping a request the SDK sent is a non-goal; tests that need to assert on submitted params can read the wire dictionary directly.

### See also

`ClaudeBatchCreateParams` — the body that wraps a collection of these. `ClaudeBatchResult` — the response side; carries the same `customId` so the developer can match responses to submitted requests.
"
Class {
	#name : 'ClaudeBatchRequest',
	#superclass : 'Object',
	#instVars : [
		'customId',
		'params'
	],
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'instance creation' }
ClaudeBatchRequest class >> customId: aString params: aClaudeMessageRequest [
	^ self new
		customId: aString;
		params: aClaudeMessageRequest;
		yourself
]

{ #category : 'json' }
ClaudeBatchRequest class >> fromJson: aDictionary [
	"Build a ClaudeBatchRequest from its wire-shape Dictionary. The params field
	 is preserved as the raw Dictionary because ClaudeMessageRequest is a builder
	 class without a symmetric fromJson: — and round-tripping a request we sent
	 is a non-goal of this SDK. Tests that need to assert on submitted params
	 read the wire dictionary directly."
	^ self new
		customId: (aDictionary at: 'custom_id' ifAbsent: [ nil ]);
		params: (aDictionary at: 'params' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeBatchRequest class >> jsonKeyMap [
	^ {
		#customId -> 'custom_id'
	} asDictionary
]

{ #category : 'json' }
ClaudeBatchRequest >> asJson [
	"Wire shape: { 'custom_id': ..., 'params': { <ClaudeMessageRequest wire shape> } }.
	 params can be either a ClaudeMessageRequest (the production path — caller built it
	 in Smalltalk) or a raw Dictionary (the from-JSON round-trip path); send asJson when
	 it responds, otherwise pass through."
	| dict paramsJson |
	dict := OrderedDictionary new.
	dict at: 'custom_id' put: customId.
	params ifNotNil: [
		paramsJson := (params respondsTo: #asJson)
			ifTrue: [ params asJson ]
			ifFalse: [ params ].
		dict at: 'params' put: paramsJson ].
	^ dict
]

{ #category : 'accessing' }
ClaudeBatchRequest >> customId [ ^ customId
]

{ #category : 'accessing' }
ClaudeBatchRequest >> customId: aString [ customId := aString
]

{ #category : 'accessing' }
ClaudeBatchRequest >> params [ ^ params
]

{ #category : 'accessing' }
ClaudeBatchRequest >> params: aClaudeMessageRequest [ params := aClaudeMessageRequest
]

{ #category : 'printing' }
ClaudeBatchRequest >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeBatchRequest(';
		nextPutAll: (customId ifNil: [ '?' ]);
		nextPut: $)
]
