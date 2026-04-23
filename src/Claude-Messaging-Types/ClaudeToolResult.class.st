"
I represent a structured result from a ClaudeCommand execution. I carry a content string, an isError flag, and an optional payload for structured data.

The content string is what the LLM sees. The payload is for infrastructure (composites and direct callers) to inspect without parsing the content string. The exchange forwards only content and isError to the API wire format. When payload is nil, I behave exactly as before the payload slot was added.

Use my class-side factory methods:
  ClaudeToolResult text: 'some result'    ""normal result, no payload""
  ClaudeToolResult errorText: 'some error'    ""error result, no payload""
  ClaudeToolResult text: 'some result' payload: anObject    ""normal result with payload""
  ClaudeToolResult errorText: 'some error' payload: anObject    ""error result with payload""

### Examples

  (ClaudeToolResult text: 'done') content
  >>> 'done'

  (ClaudeToolResult text: 'done') isError
  >>> false

  (ClaudeToolResult errorText: 'failed') isError
  >>> true

  (ClaudeToolResult text: 'done') payload
  >>> nil

  (ClaudeToolResult text: 'done' payload: 42) payload
  >>> 42

"
Class {
	#name : 'ClaudeToolResult',
	#superclass : 'Object',
	#instVars : [
		'content',
		'isError',
		'payload'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeToolResult class >> contentBlocks: anArray [
	"Create a result with an array of content blocks (text, image, etc). Each element must respond to asJson."
	^ self new
		content: (anArray collect: [:block | block asJson]) asArray;
		yourself
]

{ #category : 'instance creation' }
ClaudeToolResult class >> errorText: aString [
	^ self new
		content: aString;
		isError: true;
		yourself
]

{ #category : 'instance creation' }
ClaudeToolResult class >> errorText: aString payload: anObject [
	^ self new
		content: aString;
		isError: true;
		payload: anObject;
		yourself
]

{ #category : 'instance creation' }
ClaudeToolResult class >> text: aString [
	^ self new
		content: aString;
		yourself
]

{ #category : 'instance creation' }
ClaudeToolResult class >> text: aString payload: anObject [
	^ self new
		content: aString;
		payload: anObject;
		yourself
]

{ #category : 'accessing' }
ClaudeToolResult >> content [
	^ content
]

{ #category : 'accessing' }
ClaudeToolResult >> content: aString [
	content := aString
]

{ #category : 'initialization' }
ClaudeToolResult >> initialize [
	isError := false
]

{ #category : 'accessing' }
ClaudeToolResult >> isError [
	^ isError
]

{ #category : 'accessing' }
ClaudeToolResult >> isError: aBoolean [
	isError := aBoolean
]

{ #category : 'testing' }
ClaudeToolResult >> isToolResult [
	^ true
]

{ #category : 'accessing' }
ClaudeToolResult >> payload [
	^ payload
]

{ #category : 'accessing' }
ClaudeToolResult >> payload: anObject [
	payload := anObject
]

{ #category : 'printing' }
ClaudeToolResult >> printOn: aStream [
	aStream
		nextPutAll: self className;
		nextPut: $(;
		nextPutAll: (isError ifTrue: [ 'error' ] ifFalse: [ 'ok' ]);
		nextPutAll: ': ';
		nextPutAll: (content ifNil: [ '' ]);
		nextPut: $)
]
