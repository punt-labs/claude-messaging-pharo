"
A file-based document source for the Claude API. References a document by its file ID.

### Examples

  ClaudeFileDocumentSource new fileId: 'file_abc123'; yourself
  >>> a ClaudeFileDocumentSource

  (ClaudeFileDocumentSource new fileId: 'file_abc123') sourceType
  >>> 'file'

"
Class {
	#name : 'ClaudeFileDocumentSource',
	#superclass : 'ClaudeDocumentSource',
	#instVars : [
		'fileId'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeFileDocumentSource class >> fromJson: aDictionary [
  ^ self new
    fileId: (aDictionary at: 'file_id' ifAbsent: [ nil ]);
    yourself
]

{ #category : 'STON' }
ClaudeFileDocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    fileId: (dict at: #fileId ifAbsent: [ nil ]);
    yourself
]

{ #category : 'json' }
ClaudeFileDocumentSource >> asJson [
  ^ OrderedDictionary new
    at: 'type' put: 'file';
    at: 'file_id' put: fileId;
    yourself
]

{ #category : 'accessing' }
ClaudeFileDocumentSource >> fileId [
  ^ fileId
]

{ #category : 'accessing' }
ClaudeFileDocumentSource >> fileId: aString [
  fileId := aString
]

{ #category : 'accessing' }
ClaudeFileDocumentSource >> sourceType [
  ^ 'file'
]

{ #category : 'STON' }
ClaudeFileDocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #fileId put: fileId ]
]
