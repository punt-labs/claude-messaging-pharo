"
A content-based document source for the Claude API. Contains an ordered collection of content blocks.

### Examples

  ClaudeContentDocumentSource new
  >>> a ClaudeContentDocumentSource

  ClaudeContentDocumentSource new sourceType
  >>> 'content'

"
Class {
	#name : 'ClaudeContentDocumentSource',
	#superclass : 'ClaudeDocumentSource',
	#instVars : [
		'content'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeContentDocumentSource class >> fromJson: aDictionary [
  | blocks |
  blocks := (aDictionary at: 'content' ifAbsent: [ #() ])
    collect: [ :each | ClaudeContentBlock fromJson: each ].
  ^ self new
    content: blocks asOrderedCollection;
    yourself
]

{ #category : 'STON' }
ClaudeContentDocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    content: (dict at: #content ifAbsent: [ OrderedCollection new ]);
    yourself
]

{ #category : 'json' }
ClaudeContentDocumentSource >> asJson [
  ^ OrderedDictionary new
    at: 'type' put: 'content';
    at: 'content' put: (content collect: [ :b | b asJson ]);
    yourself
]

{ #category : 'accessing' }
ClaudeContentDocumentSource >> content [
  ^ content
]

{ #category : 'accessing' }
ClaudeContentDocumentSource >> content: aCollection [
  content := aCollection
]

{ #category : 'initialization' }
ClaudeContentDocumentSource >> initialize [
  super initialize.
  content := OrderedCollection new
]

{ #category : 'accessing' }
ClaudeContentDocumentSource >> sourceType [
  ^ 'content'
]

{ #category : 'STON' }
ClaudeContentDocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #content put: content ]
]
