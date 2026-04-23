"
A text content block from a Claude API response. Contains the text string and optional citations referencing source documents.

### Examples

```
(ClaudeTextBlock text: 'hello') text
>>> 'hello'

ClaudeTextBlock new type
>>> 'text'
```

"
Class {
	#name : 'ClaudeTextBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'text',
		'citations',
		'cacheControl'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeTextBlock class >> fromJson: aDictionary [
	| block |
	block := self new
		text: (aDictionary at: 'text' ifAbsent: [ nil ]);
		yourself.
	(aDictionary at: 'citations' ifAbsent: [ nil ]) ifNotNil: [ :cits |
		block citations: (cits collect: [ :c | ClaudeCitation fromJson: c ]) asOrderedCollection ].
	(aDictionary at: 'cache_control' ifAbsent: [ nil ]) ifNotNil: [ :cc |
		block cacheControl: (ClaudeCacheControl fromJson: cc) ].
	^ block
]

{ #category : 'persistence' }
ClaudeTextBlock class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		text: (dict at: #text ifAbsent: [ '' ]);
		citations: (dict at: #citations ifAbsent: [ nil ]);
		cacheControl: (dict at: #cacheControl ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeTextBlock class >> jsonKeyMap [
	^ {
		#cacheControl -> 'cache_control'
	} asDictionary
]

{ #category : 'instance creation' }
ClaudeTextBlock class >> text: aString [
	^ self new
		text: aString;
		yourself
]

{ #category : 'streaming' }
ClaudeTextBlock >> applyDelta: aDeltaDict [
	| deltaType |
	deltaType := aDeltaDict at: 'type'.
	deltaType = 'text_delta' ifTrue: [
		text := (text ifNil: [ '' ]) , (aDeltaDict at: 'text').
		^ self ].
	deltaType = 'citations_delta' ifFalse: [ ^ self ].
	citations ifNil: [ citations := OrderedCollection new ].
	citations add: (ClaudeCitation fromJson: (aDeltaDict at: 'citation'))
]

{ #category : 'json' }
ClaudeTextBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'text'.
	dict at: 'text' put: text.
	citations ifNotNil: [
		citations ifNotEmpty: [
			dict at: 'citations' put: (citations collect: [ :c | c asJson ]) asArray ] ].
	cacheControl ifNotNil: [ dict at: 'cache_control' put: cacheControl asJson ].
	^ dict
]

{ #category : 'accessing' }
ClaudeTextBlock >> cacheControl [
	^ cacheControl
]

{ #category : 'accessing' }
ClaudeTextBlock >> cacheControl: aClaudeCacheControl [
	cacheControl := aClaudeCacheControl
]

{ #category : 'accessing' }
ClaudeTextBlock >> citations [
	^ citations
]

{ #category : 'accessing' }
ClaudeTextBlock >> citations: aCollection [
	citations := aCollection
]

{ #category : 'initialization' }
ClaudeTextBlock >> initialize [
	super initialize.
	type := 'text'
]

{ #category : 'testing' }
ClaudeTextBlock >> isTextBlock [
	^ true
]

{ #category : 'persistence' }
ClaudeTextBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #text put: text.
		citations ifNotNil: [ map at: #citations put: citations ].
		cacheControl ifNotNil: [ map at: #cacheControl put: cacheControl ] ]
]

{ #category : 'accessing' }
ClaudeTextBlock >> text [
	^ text
]

{ #category : 'accessing' }
ClaudeTextBlock >> text: aString [
	text := aString
]
