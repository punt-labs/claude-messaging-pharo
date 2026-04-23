"
Extended thinking configuration for the Claude Messages API. Wraps the type, budgetTokens, and display fields that the API sends as a nested thinking dictionary. Supports three modes: enabled (always think, requires budget), disabled (no thinking), and adaptive (model decides whether to think, optional display).

### Examples

```
ClaudeThinkingParams enabled: 1024
>>> a ClaudeThinkingParams

(ClaudeThinkingParams enabled: 5000) asDictionary
>>> a Dictionary('budget_tokens'->5000 'type'->'enabled' )

ClaudeThinkingParams adaptive asDictionary
>>> a Dictionary('type'->'adaptive' )

(ClaudeThinkingParams adaptiveWithDisplay: 'summarized') asDictionary
>>> a Dictionary('display'->'summarized' 'type'->'adaptive' )

ClaudeThinkingParams disabled asDictionary
>>> a Dictionary('type'->'disabled' )
```

"
Class {
	#name : 'ClaudeThinkingParams',
	#superclass : 'Object',
	#instVars : [
		'type',
		'budgetTokens',
		'display'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeThinkingParams class >> adaptive [
	"Create adaptive thinking params — the model decides whether to think."
	^ self new
		type: 'adaptive';
		yourself
]

{ #category : 'instance creation' }
ClaudeThinkingParams class >> adaptiveWithDisplay: aString [
	"Create adaptive thinking params with a display option (e.g. 'summarized' or 'omitted')."
	^ self new
		type: 'adaptive';
		display: aString;
		yourself
]

{ #category : 'instance creation' }
ClaudeThinkingParams class >> disabled [
	"Create disabled thinking params — no thinking."
	^ self new
		type: 'disabled';
		yourself
]

{ #category : 'instance creation' }
ClaudeThinkingParams class >> enabled: anInteger [
	"Create enabled thinking params with the given budget."
	^ self new
		type: 'enabled';
		budgetTokens: anInteger;
		yourself
]

{ #category : 'json' }
ClaudeThinkingParams class >> jsonKeyMap [
	^ {
		#budgetTokens -> 'budget_tokens'.
		#display -> 'display'
	} asDictionary
]

{ #category : 'json' }
ClaudeThinkingParams >> addFieldsTo: dict [
	type ifNotNil: [ | thinkingDict |
		thinkingDict := Dictionary new
			at: 'type' put: type;
			yourself.
		budgetTokens ifNotNil: [ thinkingDict at: 'budget_tokens' put: budgetTokens ].
		display ifNotNil: [ thinkingDict at: 'display' put: display ].
		dict at: 'thinking' put: thinkingDict ]
]

{ #category : 'converting' }
ClaudeThinkingParams >> asDictionary [
	"Return the thinking configuration as a Dictionary matching the API wire format, or nil if not configured."
	| d |
	type ifNil: [ ^ nil ].
	d := Dictionary new.
	d at: 'type' put: type.
	budgetTokens ifNotNil: [ d at: 'budget_tokens' put: budgetTokens ].
	display ifNotNil: [ d at: 'display' put: display ].
	^ d
]

{ #category : 'accessing' }
ClaudeThinkingParams >> budgetTokens [
	^ budgetTokens
]

{ #category : 'accessing' }
ClaudeThinkingParams >> budgetTokens: anInteger [
	budgetTokens := anInteger
]

{ #category : 'accessing' }
ClaudeThinkingParams >> display [
	^ display
]

{ #category : 'accessing' }
ClaudeThinkingParams >> display: aStringOrNil [
	display := aStringOrNil
]

{ #category : 'converting' }
ClaudeThinkingParams >> fromDictionary: aDictionaryOrNil [
	"Populate from an API-format dictionary with type, budget_tokens, and display keys."
	aDictionaryOrNil ifNil: [
		type := nil.
		budgetTokens := nil.
		display := nil.
		^ self ].
	type := aDictionaryOrNil at: 'type'.
	budgetTokens := aDictionaryOrNil at: 'budget_tokens' ifAbsent: [ nil ].
	display := aDictionaryOrNil at: 'display' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeThinkingParams >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeThinkingParams >> type: aString [
	type := aString
]
