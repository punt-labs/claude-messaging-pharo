"
A base64-encoded document source for the Claude API. Used for sending PDF and other binary documents as base64 data.

### Examples

  ClaudeBase64DocumentSource new data: 'JVBERi0xLjQ='; yourself
  >>> a ClaudeBase64DocumentSource

  (ClaudeBase64DocumentSource new data: 'JVBERi0xLjQ=') sourceType
  >>> 'base64'

"
Class {
	#name : 'ClaudeBase64DocumentSource',
	#superclass : 'ClaudeDocumentSource',
	#instVars : [
		'data',
		'mediaType'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeBase64DocumentSource class >> fromJson: aDictionary [
  ^ self new
    data: (aDictionary at: 'data' ifAbsent: [ nil ]);
    mediaType: (aDictionary at: 'media_type' ifAbsent: [ 'application/pdf' ]);
    yourself
]

{ #category : 'STON' }
ClaudeBase64DocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    data: (dict at: #data ifAbsent: [ '' ]);
    mediaType: (dict at: #mediaType ifAbsent: [ 'application/pdf' ]);
    yourself
]

{ #category : 'json' }
ClaudeBase64DocumentSource >> asJson [
  ^ OrderedDictionary new
    at: 'type' put: 'base64';
    at: 'media_type' put: mediaType;
    at: 'data' put: data;
    yourself
]

{ #category : 'accessing' }
ClaudeBase64DocumentSource >> data [
  ^ data
]

{ #category : 'accessing' }
ClaudeBase64DocumentSource >> data: aString [
  data := aString
]

{ #category : 'initialization' }
ClaudeBase64DocumentSource >> initialize [
  super initialize.
  mediaType := 'application/pdf'
]

{ #category : 'accessing' }
ClaudeBase64DocumentSource >> mediaType [
  ^ mediaType
]

{ #category : 'accessing' }
ClaudeBase64DocumentSource >> mediaType: aString [
  mediaType := aString
]

{ #category : 'accessing' }
ClaudeBase64DocumentSource >> sourceType [
  ^ 'base64'
]

{ #category : 'STON' }
ClaudeBase64DocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #data put: data.
    map at: #mediaType put: mediaType ]
]
