"
Conversation content unit — a role with content blocks and optional model. Extracted from ClaudeMessage to separate conversation data from response metadata.

### Examples

```
ClaudeTurn role: user content: { ClaudeTextBlock text: hello }
>>> a ClaudeTurn

(ClaudeTurn role: assistant content: { ClaudeTextBlock text: hi }) role
>>> #assistant

(ClaudeTurn role: assistant content: { ClaudeTextBlock text: hi }) textContent
>>> hi

(ClaudeTurn role: assistant content: { ClaudeTextBlock text: hi }) asParam
>>> an OrderedDictionary(role->assistant content->#(an OrderedDictionary(type->text text->hi) ) )
```

"
Class {
	#name : 'ClaudeTurn',
	#superclass : 'Object',
	#instVars : [
		'role',
		'content',
		'model'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeTurn class >> fromJson: aDictionary [
	"Parse from a flat top-level API response dict."
	^ self new
		role: (aDictionary at: 'role' ifAbsent: [ nil ]);
		content: ((aDictionary at: 'content' ifAbsent: [ #() ])
			collect: [ :each | ClaudeContentBlock fromJson: each ]) asOrderedCollection;
		model: (aDictionary at: 'model' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeTurn class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		role: (dict at: #role ifAbsent: [ nil ]);
		content: (dict at: #content ifAbsent: [ nil ]);
		model: (dict at: #model ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeTurn class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'instance creation' }
ClaudeTurn class >> role: aString content: aCollection [
	^ self new
		role: aString;
		content: aCollection;
		yourself
]

{ #category : 'json' }
ClaudeTurn >> asJson [
	| dict |
	dict := OrderedDictionary new.
	role ifNotNil: [ dict at: 'role' put: role asString ].
	content ifNotNil: [ dict at: 'content' put: (content collect: [ :b | b asJson ]) asArray ].
	model ifNotNil: [ dict at: 'model' put: model ].
	^ dict
]

{ #category : 'converting' }
ClaudeTurn >> asParam [
	"Serialize for the messages[] array."
	| dict |
	dict := OrderedDictionary new.
	dict at: 'role' put: role asString.
	dict at: 'content' put: (content collect: [ :b | b asJson ]) asArray.
	^ dict
]

{ #category : 'accessing' }
ClaudeTurn >> content [
	^ content
]

{ #category : 'accessing' }
ClaudeTurn >> content: aCollection [
	content := aCollection
]

{ #category : 'initialization' }
ClaudeTurn >> initialize [
	super initialize.
	content := OrderedCollection new
]

{ #category : 'accessing' }
ClaudeTurn >> model [
	^ model
]

{ #category : 'accessing' }
ClaudeTurn >> model: aString [
	model := aString
]

{ #category : 'printing' }
ClaudeTurn >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeTurn(';
		nextPutAll: (role ifNil: [ '?' ]);
		nextPutAll: ' blocks: ';
		print: (content ifNil: [ #() ]) size;
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeTurn >> role [
	^ role
]

{ #category : 'accessing' }
ClaudeTurn >> role: aStringOrSymbol [
	role := aStringOrSymbol ifNotNil: [ :v | v asSymbol ]
]

{ #category : 'persistence' }
ClaudeTurn >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		role ifNotNil: [ map at: #role put: role ].
		content ifNotNil: [ map at: #content put: content ].
		model ifNotNil: [ map at: #model put: model ] ]
]

{ #category : 'accessing' }
ClaudeTurn >> textContent [
	"Return the concatenated text of all text blocks."
	content ifNil: [ ^ '' ].
	^ String streamContents: [ :s |
		content do: [ :block |
			block isTextBlock ifTrue: [ s nextPutAll: block text ] ] ]
]

{ #category : 'accessing' }
ClaudeTurn >> toolUseBlocks [
	"Return tool_use blocks from content."
	content ifNil: [ ^ OrderedCollection new ].
	^ (content select: [ :b | b isToolUseBlock ]) asOrderedCollection
]
