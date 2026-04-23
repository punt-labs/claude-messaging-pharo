"
A redacted_thinking content block from a Claude API response. Appears when the API omits thinking content for safety reasons. Carries opaque data that must be preserved verbatim when round-tripping conversations.

### Examples

```
ClaudeRedactedThinkingBlock new type
>>> 'redacted_thinking'
```

"
Class {
	#name : 'ClaudeRedactedThinkingBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'data'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeRedactedThinkingBlock class >> data: aString [
	^ self new
		data: aString;
		yourself
]

{ #category : 'json' }
ClaudeRedactedThinkingBlock class >> fromJson: aDictionary [
	^ self new
		data: (aDictionary at: 'data' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeRedactedThinkingBlock class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		data: (dict at: #data ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeRedactedThinkingBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'redacted_thinking'.
	data ifNotNil: [ dict at: 'data' put: data ].
	^ dict
]

{ #category : 'accessing' }
ClaudeRedactedThinkingBlock >> data [
	^ data
]

{ #category : 'accessing' }
ClaudeRedactedThinkingBlock >> data: aString [
	data := aString
]

{ #category : 'initialization' }
ClaudeRedactedThinkingBlock >> initialize [
	super initialize.
	type := 'redacted_thinking'
]

{ #category : 'persistence' }
ClaudeRedactedThinkingBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #data put: data ]
]
