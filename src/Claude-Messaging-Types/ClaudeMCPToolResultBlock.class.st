"
An mcp_tool_result content block from a Claude API response. Returned in response to a prior mcp_tool_use block; tool_use_id refers back to that block's id. The content slot is a polymorphic union: either a String (when Anthropic sends a plain text result) or an OrderedCollection of ClaudeTextBlock (when the result is structured). asJson and fromJson: dispatch on the content's runtime type so the wire shape is preserved.

  ClaudeMCPToolResultBlock new type
  >>> 'mcp_tool_result'

  ClaudeMCPToolResultBlock new isMCPToolResultBlock
  >>> true

  (ClaudeMCPToolResultBlock new content: 'ok'; content) isString
  >>> true

"
Class {
	#name : 'ClaudeMCPToolResultBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'toolUseId',
		'content',
		'isError'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeMCPToolResultBlock class >> fromJson: aDictionary [
	| rawContent block |
	rawContent := aDictionary at: 'content' ifAbsent: [ nil ].
	block := self new
		toolUseId: (aDictionary at: 'tool_use_id' ifAbsent: [ nil ]);
		isError: (aDictionary at: 'is_error' ifAbsent: [ nil ]);
		yourself.
	rawContent ifNotNil: [
		block content: (rawContent isString
			ifTrue: [ rawContent ]
			ifFalse: [ (rawContent collect: [ :c | ClaudeTextBlock fromJson: c ]) asOrderedCollection ]) ].
	^ block
]

{ #category : 'json' }
ClaudeMCPToolResultBlock class >> jsonKeyMap [
	^ {
		#toolUseId -> 'tool_use_id'.
		#isError -> 'is_error'
	} asDictionary
]

{ #category : 'json' }
ClaudeMCPToolResultBlock >> asJson [
	| dict |
	toolUseId ifNil: [ self error: 'tool_use_id is required' ].
	dict := OrderedDictionary new.
	dict at: 'type' put: 'mcp_tool_result'.
	dict at: 'tool_use_id' put: toolUseId.
	isError ifNotNil: [ dict at: 'is_error' put: isError ].
	content ifNotNil: [
		dict at: 'content' put: (content isString
			ifTrue: [ content ]
			ifFalse: [ (content collect: [ :b | b asJson ]) asArray ]) ].
	^ dict
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> content [
	^ content
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> content: anObject [
	content := anObject
]

{ #category : 'initialization' }
ClaudeMCPToolResultBlock >> initialize [
	super initialize.
	type := 'mcp_tool_result'
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> isError [
	^ isError
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> isError: aBoolean [
	isError := aBoolean
]

{ #category : 'testing' }
ClaudeMCPToolResultBlock >> isMCPToolResultBlock [
	^ true
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> toolUseId [
	^ toolUseId
]

{ #category : 'accessing' }
ClaudeMCPToolResultBlock >> toolUseId: aString [
	toolUseId := aString
]
