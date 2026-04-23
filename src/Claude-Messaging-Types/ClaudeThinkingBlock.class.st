"
A thinking content block from a Claude API response when extended thinking is enabled. Contains the model chain-of-thought reasoning and a cryptographic signature that must be preserved when round-tripping conversations.

### Examples

```
ClaudeThinkingBlock new type
>>> 'thinking'

ClaudeThinkingBlock new thinking: 'Let me reason...'; thinking
>>> 'Let me reason...'
```

"
Class {
	#name : 'ClaudeThinkingBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'thinking',
		'signature'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeThinkingBlock class >> fromJson: aDictionary [
	^ self new
		thinking: (aDictionary at: 'thinking' ifAbsent: [ nil ]);
		signature: (aDictionary at: 'signature' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeThinkingBlock class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		thinking: (dict at: #thinking ifAbsent: [ nil ]);
		signature: (dict at: #signature ifAbsent: [ nil ]);
		yourself
]

{ #category : 'instance creation' }
ClaudeThinkingBlock class >> thinking: aString signature: sigString [
	^ self new
		thinking: aString;
		signature: sigString;
		yourself
]

{ #category : 'streaming' }
ClaudeThinkingBlock >> applyDelta: aDeltaDict [
	| deltaType |
	deltaType := aDeltaDict at: 'type'.
	deltaType = 'thinking_delta' ifTrue: [
		thinking := (thinking ifNil: [ '' ]) , (aDeltaDict at: 'thinking').
		^ self ].
	deltaType = 'signature_delta' ifTrue: [
		signature := aDeltaDict at: 'signature' ]
]

{ #category : 'json' }
ClaudeThinkingBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'thinking'.
	dict at: 'thinking' put: thinking.
	signature ifNotNil: [ dict at: 'signature' put: signature ].
	^ dict
]

{ #category : 'initialization' }
ClaudeThinkingBlock >> initialize [
	super initialize.
	type := 'thinking'
]

{ #category : 'testing' }
ClaudeThinkingBlock >> isThinkingBlock [
	"Polymorphic predicate. Overrides the base-class default (false).
	 Lets callers filter response content without isKindOf:."

	^ true
]

{ #category : 'accessing' }
ClaudeThinkingBlock >> signature [
	^ signature
]

{ #category : 'accessing' }
ClaudeThinkingBlock >> signature: aString [
	signature := aString
]

{ #category : 'persistence' }
ClaudeThinkingBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #thinking put: thinking.
		map at: #signature put: signature ]
]

{ #category : 'accessing' }
ClaudeThinkingBlock >> thinking [
	^ thinking
]

{ #category : 'accessing' }
ClaudeThinkingBlock >> thinking: aString [
	thinking := aString
]
