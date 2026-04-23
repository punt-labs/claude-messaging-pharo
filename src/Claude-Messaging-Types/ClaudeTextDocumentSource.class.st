"
A text document source for the Claude API. Used for sending plain text documents.

### Examples

  ClaudeTextDocumentSource new data: 'Hello world'; yourself
  >>> a ClaudeTextDocumentSource

  (ClaudeTextDocumentSource new data: 'Hello') sourceType
  >>> 'text'

"
Class {
	#name : 'ClaudeTextDocumentSource',
	#superclass : 'ClaudeDocumentSource',
	#instVars : [
		'data',
		'mediaType'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeTextDocumentSource class >> fromJson: aDictionary [
  ^ self new
    data: (aDictionary at: 'data' ifAbsent: [ nil ]);
    mediaType: (aDictionary at: 'media_type' ifAbsent: [ 'text/plain' ]);
    yourself
]

{ #category : 'STON' }
ClaudeTextDocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    data: (dict at: #data ifAbsent: [ '' ]);
    mediaType: (dict at: #mediaType ifAbsent: [ 'text/plain' ]);
    yourself
]

{ #category : 'json' }
ClaudeTextDocumentSource >> asJson [
  ^ OrderedDictionary new
    at: 'type' put: 'text';
    at: 'media_type' put: mediaType;
    at: 'data' put: data;
    yourself
]

{ #category : 'accessing' }
ClaudeTextDocumentSource >> data [
  ^ data
]

{ #category : 'accessing' }
ClaudeTextDocumentSource >> data: aString [
  data := aString
]

{ #category : 'initialization' }
ClaudeTextDocumentSource >> initialize [
  super initialize.
  mediaType := 'text/plain'
]

{ #category : 'accessing' }
ClaudeTextDocumentSource >> mediaType [
  ^ mediaType
]

{ #category : 'accessing' }
ClaudeTextDocumentSource >> mediaType: aString [
  mediaType := aString
]

{ #category : 'accessing' }
ClaudeTextDocumentSource >> sourceType [
  ^ 'text'
]

{ #category : 'STON' }
ClaudeTextDocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #data put: data.
    map at: #mediaType put: mediaType ]
]
