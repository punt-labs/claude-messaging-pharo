"
A tool_result content block sent in a user message to provide the result of a tool invocation. References the original tool_use block by toolUseId. The content is a string or collection of content blocks. isError indicates a tool failure. cacheControl enables prompt caching.

### Examples

```
ClaudeToolResultBlock new type
>>> 'tool_result'

ClaudeToolResultBlock new toolUseId: 'toolu_1'; toolUseId
>>> 'toolu_1'
```

"
Class {
	#name : 'ClaudeToolResultBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'toolUseId',
		'content',
		'isError',
		'cacheControl'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeToolResultBlock class >> fromJson: aDictionary [
	^ self new
		toolUseId: (aDictionary at: 'tool_use_id' ifAbsent: [ nil ]);
		content: (aDictionary at: 'content' ifAbsent: [ nil ]);
		isError: (aDictionary at: 'is_error' ifAbsent: [ nil ]);
		cacheControl: (aDictionary at: 'cache_control' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeToolResultBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #content ifAbsent: [ nil ].
	^ self new
		toolUseId: (dict at: #toolUseId ifAbsent: [ nil ]);
		content: (raw isCollection
			ifTrue: [ raw isString ifTrue: [ raw ] ifFalse: [ raw asOrderedCollection ] ]
			ifFalse: [ raw ]);
		isError: (dict at: #isError ifAbsent: [ nil ]);
		cacheControl: (dict at: #cacheControl ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeToolResultBlock class >> jsonKeyMap [
	^ {
		#toolUseId -> 'tool_use_id'.
		#isError -> 'is_error'.
		#cacheControl -> 'cache_control'
	} asDictionary
]

{ #category : 'instance creation' }
ClaudeToolResultBlock class >> toolUseId: anId content: aString [
	^ self new
		toolUseId: anId;
		content: aString;
		yourself
]

{ #category : 'instance creation' }
ClaudeToolResultBlock class >> toolUseId: anId content: aString isError: aBoolean [
	^ self new
		toolUseId: anId;
		content: aString;
		isError: aBoolean;
		yourself
]

{ #category : 'json' }
ClaudeToolResultBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'tool_result'.
	dict at: 'tool_use_id' put: toolUseId.
	content ifNotNil: [ dict at: 'content' put: content ].
	isError ifNotNil: [ dict at: 'is_error' put: isError ].
	cacheControl ifNotNil: [ dict at: 'cache_control' put: cacheControl ].
	^ dict
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> cacheControl [
	^ cacheControl
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> cacheControl: aDictionary [
	cacheControl := aDictionary
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> content [
	^ content
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> content: anObject [
	content := anObject
]

{ #category : 'initialization' }
ClaudeToolResultBlock >> initialize [
	super initialize.
	type := 'tool_result'
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> isError [
	^ isError
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> isError: aBoolean [
	isError := aBoolean
]

{ #category : 'testing' }
ClaudeToolResultBlock >> isToolResultBlock [
	^ true
]

{ #category : 'persistence' }
ClaudeToolResultBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #toolUseId put: toolUseId.
		content ifNotNil: [ map at: #content put: content ].
		isError ifNotNil: [ map at: #isError put: isError ].
		cacheControl ifNotNil: [ map at: #cacheControl put: cacheControl ] ]
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> toolUseId [
	^ toolUseId
]

{ #category : 'accessing' }
ClaudeToolResultBlock >> toolUseId: aString [
	toolUseId := aString
]
