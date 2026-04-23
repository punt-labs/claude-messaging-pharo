"
Model metadata from the Claude Models API. Contains model identity, display name, token limits, and creation timestamp. Returned by ClaudeClient>>listModels and ClaudeClient>>getModel:.

### Examples

```
ClaudeModelInfo new id: 'claude-opus-4-6'; id
>>> 'claude-opus-4-6'

ClaudeModelInfo new displayName: 'Claude Opus 4.6'; displayName
>>> 'Claude Opus 4.6'
```

"
Class {
	#name : 'ClaudeModelInfo',
	#superclass : 'Object',
	#instVars : [
		'id',
		'displayName',
		'maxInputTokens',
		'maxTokens',
		'type',
		'createdAt'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeModelInfo class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		displayName: (aDictionary at: 'display_name' ifAbsent: [ nil ]);
		maxInputTokens: (aDictionary at: 'max_input_tokens' ifAbsent: [ nil ]);
		maxTokens: (aDictionary at: 'max_tokens' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ nil ]);
		createdAt: (aDictionary at: 'created_at' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeModelInfo class >> jsonKeyMap [
	^ {
		#displayName -> 'display_name'.
		#maxInputTokens -> 'max_input_tokens'.
		#maxTokens -> 'max_tokens'.
		#createdAt -> 'created_at'
	} asDictionary
]

{ #category : 'json' }
ClaudeModelInfo >> asJson [
	| dict |
	dict := OrderedDictionary new.
	id ifNotNil: [ dict at: 'id' put: id ].
	displayName ifNotNil: [ dict at: 'display_name' put: displayName ].
	maxInputTokens ifNotNil: [ dict at: 'max_input_tokens' put: maxInputTokens ].
	maxTokens ifNotNil: [ dict at: 'max_tokens' put: maxTokens ].
	type ifNotNil: [ dict at: 'type' put: type ].
	createdAt ifNotNil: [ dict at: 'created_at' put: createdAt ].
	^ dict
]

{ #category : 'accessing' }
ClaudeModelInfo >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
ClaudeModelInfo >> createdAt: aString [
	createdAt := aString
]

{ #category : 'accessing' }
ClaudeModelInfo >> displayName [
	^ displayName
]

{ #category : 'accessing' }
ClaudeModelInfo >> displayName: aString [
	displayName := aString
]

{ #category : 'accessing' }
ClaudeModelInfo >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeModelInfo >> id: aString [
	id := aString
]

{ #category : 'accessing' }
ClaudeModelInfo >> maxInputTokens [
	^ maxInputTokens
]

{ #category : 'accessing' }
ClaudeModelInfo >> maxInputTokens: anInteger [
	maxInputTokens := anInteger
]

{ #category : 'accessing' }
ClaudeModelInfo >> maxTokens [
	^ maxTokens
]

{ #category : 'accessing' }
ClaudeModelInfo >> maxTokens: anInteger [
	maxTokens := anInteger
]

{ #category : 'printing' }
ClaudeModelInfo >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeModelInfo(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeModelInfo >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeModelInfo >> type: aString [
	type := aString
]
