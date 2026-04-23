"
Sampling configuration for the Claude Messages API. Groups temperature, topP, topK, and stopSequences — the parameters that control how the model generates tokens. Extracted from ClaudeMessageParams via Extract Class (Fowler) and Whole Value (Beck).

### Examples

```
ClaudeSamplingParams new temperature: 0.7; temperature
>>> 0.7
```

"
Class {
	#name : 'ClaudeSamplingParams',
	#superclass : 'Object',
	#instVars : [
		'temperature',
		'topP',
		'topK',
		'stopSequences'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeSamplingParams class >> jsonKeyMap [
	^ {
		#topP -> 'top_p'.
		#topK -> 'top_k'.
		#stopSequences -> 'stop_sequences'
	} asDictionary
]

{ #category : 'json' }
ClaudeSamplingParams >> addFieldsTo: dict [
	temperature ifNotNil: [ dict at: 'temperature' put: temperature ].
	topP ifNotNil: [ dict at: 'top_p' put: topP ].
	topK ifNotNil: [ dict at: 'top_k' put: topK ].
	stopSequences ifNotNil: [ dict at: 'stop_sequences' put: stopSequences asArray ]
]

{ #category : 'accessing' }
ClaudeSamplingParams >> stopSequences [
	^ stopSequences
]

{ #category : 'accessing' }
ClaudeSamplingParams >> stopSequences: aCollection [
	stopSequences := aCollection
]

{ #category : 'accessing' }
ClaudeSamplingParams >> temperature [
	^ temperature
]

{ #category : 'accessing' }
ClaudeSamplingParams >> temperature: aFloat [
	temperature := aFloat
]

{ #category : 'accessing' }
ClaudeSamplingParams >> topK [
	^ topK
]

{ #category : 'accessing' }
ClaudeSamplingParams >> topK: anInteger [
	topK := anInteger
]

{ #category : 'accessing' }
ClaudeSamplingParams >> topP [
	^ topP
]

{ #category : 'accessing' }
ClaudeSamplingParams >> topP: aFloat [
	topP := aFloat
]
