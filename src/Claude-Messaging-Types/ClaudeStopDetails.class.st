"
Why the model stopped generating. Holds stop_reason and stop_sequence from the API response, plus optional category and explanation from the stop_details refusal sub-object (Go SDK parity). stopReason is stored as a Symbol internally and serialized as a String in JSON.

### Examples

```
ClaudeStopDetails new stopReason: end_turn; stopReason
>>> #end_turn

(ClaudeStopDetails fromJson: (Dictionary newFromPairs: { stop_reason. end_turn. stop_sequence. nil })) stopReason
>>> #end_turn
```

"
Class {
	#name : 'ClaudeStopDetails',
	#superclass : 'Object',
	#instVars : [
		'stopReason',
		'stopSequence',
		'category',
		'explanation'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeStopDetails class >> fromJson: aDictionary [
	"Parse from a flat top-level API response dict."
	| inst details |
	inst := self new.
	inst stopReason: (aDictionary at: 'stop_reason' ifAbsent: [ nil ]).
	inst stopSequence: (aDictionary at: 'stop_sequence' ifAbsent: [ nil ]).
	details := aDictionary at: 'stop_details' ifAbsent: [ nil ].
	details ifNotNil: [
		inst category: (details at: 'category' ifAbsent: [ nil ]).
		inst explanation: (details at: 'explanation' ifAbsent: [ nil ]) ].
	^ inst
]

{ #category : 'persistence' }
ClaudeStopDetails class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		stopReason: (dict at: #stopReason ifAbsent: [ nil ]);
		stopSequence: (dict at: #stopSequence ifAbsent: [ nil ]);
		category: (dict at: #category ifAbsent: [ nil ]);
		explanation: (dict at: #explanation ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeStopDetails class >> jsonKeyMap [
	^ {
		#stopReason -> 'stop_reason'.
		#stopSequence -> 'stop_sequence'
	} asDictionary
]

{ #category : 'json' }
ClaudeStopDetails >> asJson [
	| dict |
	dict := OrderedDictionary new.
	stopReason ifNotNil: [ dict at: 'stop_reason' put: stopReason asString ].
	stopSequence ifNotNil: [ dict at: 'stop_sequence' put: stopSequence ].
	(category notNil or: [ explanation notNil ]) ifTrue: [
		| details |
		details := OrderedDictionary new.
		details at: 'type' put: 'refusal'.
		category ifNotNil: [ details at: 'category' put: category ].
		explanation ifNotNil: [ details at: 'explanation' put: explanation ].
		dict at: 'stop_details' put: details ].
	^ dict
]

{ #category : 'accessing' }
ClaudeStopDetails >> category [
	^ category
]

{ #category : 'accessing' }
ClaudeStopDetails >> category: aString [
	category := aString
]

{ #category : 'accessing' }
ClaudeStopDetails >> explanation [
	^ explanation
]

{ #category : 'accessing' }
ClaudeStopDetails >> explanation: aString [
	explanation := aString
]

{ #category : 'printing' }
ClaudeStopDetails >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeStopDetails(';
		nextPutAll: (stopReason ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'persistence' }
ClaudeStopDetails >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		stopReason ifNotNil: [ map at: #stopReason put: stopReason ].
		stopSequence ifNotNil: [ map at: #stopSequence put: stopSequence ].
		category ifNotNil: [ map at: #category put: category ].
		explanation ifNotNil: [ map at: #explanation put: explanation ] ]
]

{ #category : 'accessing' }
ClaudeStopDetails >> stopReason [
	^ stopReason
]

{ #category : 'accessing' }
ClaudeStopDetails >> stopReason: aStringOrSymbol [
	stopReason := aStringOrSymbol ifNotNil: [ :v | v asSymbol ]
]

{ #category : 'accessing' }
ClaudeStopDetails >> stopSequence [
	^ stopSequence
]

{ #category : 'accessing' }
ClaudeStopDetails >> stopSequence: aString [
	stopSequence := aString
]
