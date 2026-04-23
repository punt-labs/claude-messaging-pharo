"
Token usage counts from a Claude API response. Tracks input tokens, output tokens, and prompt cache statistics.

### Examples

```
| usage |
usage := ClaudeUsage new inputTokens: 10; outputTokens: 5; yourself.
(ClaudeUsage fromJson: usage asJson) inputTokens
>>> 10
```

"
Class {
	#name : 'ClaudeUsage',
	#superclass : 'Object',
	#instVars : [
		'inputTokens',
		'outputTokens',
		'cacheCreationInputTokens',
		'cacheReadInputTokens',
		'inferenceGeo',
		'serviceTier'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeUsage class >> fromJson: aDictionary [
  ^ self new
    inputTokens: (aDictionary at: 'input_tokens' ifAbsent: [ nil ]);
    outputTokens: (aDictionary at: 'output_tokens' ifAbsent: [ nil ]);
    cacheCreationInputTokens: (aDictionary at: 'cache_creation_input_tokens' ifAbsent: [ nil ]);
    cacheReadInputTokens: (aDictionary at: 'cache_read_input_tokens' ifAbsent: [ nil ]);
    inferenceGeo: (aDictionary at: 'inference_geo' ifAbsent: [ nil ]);
    serviceTier: (aDictionary at: 'service_tier' ifAbsent: [ nil ]);
    yourself
]

{ #category : 'persistence' }
ClaudeUsage class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    inputTokens: (dict at: #inputTokens ifAbsent: [ nil ]);
    outputTokens: (dict at: #outputTokens ifAbsent: [ nil ]);
    cacheCreationInputTokens: (dict at: #cacheCreationInputTokens ifAbsent: [ nil ]);
    cacheReadInputTokens: (dict at: #cacheReadInputTokens ifAbsent: [ nil ]);
    inferenceGeo: (dict at: #inferenceGeo ifAbsent: [ nil ]);
    serviceTier: (dict at: #serviceTier ifAbsent: [ nil ]);
    yourself
]

{ #category : 'json' }
ClaudeUsage class >> jsonKeyMap [
  ^ {
    #inputTokens -> 'input_tokens'.
    #outputTokens -> 'output_tokens'.
    #cacheCreationInputTokens -> 'cache_creation_input_tokens'.
    #cacheReadInputTokens -> 'cache_read_input_tokens'.
    #inferenceGeo -> 'inference_geo'.
    #serviceTier -> 'service_tier'
  } asDictionary
]

{ #category : 'json' }
ClaudeUsage >> asJson [
  | dict |
  dict := OrderedDictionary new.
  inputTokens ifNotNil: [ dict at: 'input_tokens' put: inputTokens ].
  outputTokens ifNotNil: [ dict at: 'output_tokens' put: outputTokens ].
  cacheCreationInputTokens ifNotNil: [ dict at: 'cache_creation_input_tokens' put: cacheCreationInputTokens ].
  cacheReadInputTokens ifNotNil: [ dict at: 'cache_read_input_tokens' put: cacheReadInputTokens ].
  inferenceGeo ifNotNil: [ dict at: 'inference_geo' put: inferenceGeo ].
  serviceTier ifNotNil: [ dict at: 'service_tier' put: serviceTier ].
  ^ dict
]

{ #category : 'accessing' }
ClaudeUsage >> cacheCreationInputTokens [
	^ cacheCreationInputTokens
]

{ #category : 'accessing' }
ClaudeUsage >> cacheCreationInputTokens: anInteger [
	cacheCreationInputTokens := anInteger
]

{ #category : 'accessing' }
ClaudeUsage >> cacheReadInputTokens [
	^ cacheReadInputTokens
]

{ #category : 'accessing' }
ClaudeUsage >> cacheReadInputTokens: anInteger [
	cacheReadInputTokens := anInteger
]

{ #category : 'accessing' }
ClaudeUsage >> inferenceGeo [
	^ inferenceGeo
]

{ #category : 'accessing' }
ClaudeUsage >> inferenceGeo: aString [
	inferenceGeo := aString
]

{ #category : 'accessing' }
ClaudeUsage >> inputTokens [
	^ inputTokens
]

{ #category : 'accessing' }
ClaudeUsage >> inputTokens: anInteger [
	inputTokens := anInteger
]

{ #category : 'accessing' }
ClaudeUsage >> outputTokens [
	^ outputTokens
]

{ #category : 'accessing' }
ClaudeUsage >> outputTokens: anInteger [
	outputTokens := anInteger
]

{ #category : 'printing' }
ClaudeUsage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeUsage(in: ';
		print: (inputTokens ifNil: [ 0 ]);
		nextPutAll: ' out: ';
		print: (outputTokens ifNil: [ 0 ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeUsage >> serviceTier [
  ^ serviceTier
]

{ #category : 'accessing' }
ClaudeUsage >> serviceTier: aString [
  serviceTier := aString
]

{ #category : 'persistence' }
ClaudeUsage >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    inputTokens ifNotNil: [ map at: #inputTokens put: inputTokens ].
    outputTokens ifNotNil: [ map at: #outputTokens put: outputTokens ].
    cacheCreationInputTokens ifNotNil: [ map at: #cacheCreationInputTokens put: cacheCreationInputTokens ].
    cacheReadInputTokens ifNotNil: [ map at: #cacheReadInputTokens put: cacheReadInputTokens ].
    inferenceGeo ifNotNil: [ map at: #inferenceGeo put: inferenceGeo ].
    serviceTier ifNotNil: [ map at: #serviceTier put: serviceTier ] ]
]
