"
A URL-based document source for the Claude API. References a document by URL.

### Examples

  ClaudeURLDocumentSource new url: 'https://example.com/doc.pdf'; yourself
  >>> a ClaudeURLDocumentSource

  (ClaudeURLDocumentSource new url: 'https://example.com/doc.pdf') sourceType
  >>> 'url'

"
Class {
	#name : 'ClaudeURLDocumentSource',
	#superclass : 'ClaudeDocumentSource',
	#instVars : [
		'url'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeURLDocumentSource class >> fromJson: aDictionary [
  ^ self new
    url: (aDictionary at: 'url' ifAbsent: [ nil ]);
    yourself
]

{ #category : 'STON' }
ClaudeURLDocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    url: (dict at: #url ifAbsent: [ nil ]);
    yourself
]

{ #category : 'json' }
ClaudeURLDocumentSource >> asJson [
  ^ OrderedDictionary new
    at: 'type' put: 'url';
    at: 'url' put: url;
    yourself
]

{ #category : 'accessing' }
ClaudeURLDocumentSource >> sourceType [
  ^ 'url'
]

{ #category : 'STON' }
ClaudeURLDocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #url put: url ]
]

{ #category : 'accessing' }
ClaudeURLDocumentSource >> url [
  ^ url
]

{ #category : 'accessing' }
ClaudeURLDocumentSource >> url: aString [
  url := aString
]
