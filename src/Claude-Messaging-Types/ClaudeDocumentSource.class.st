"
Abstract base for document source types in the Claude API. Dispatches on the ""type"" field to create the correct concrete subclass. Unknown source types preserve the raw dictionary for forward compatibility.

### Examples

  ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'base64'. 'media_type'. 'application/pdf'. 'data'. 'JVBERi0xLjQ=' })
  >>> a ClaudeBase64DocumentSource

  (ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'file'. 'file_id'. 'file_123' })) sourceType
  >>> 'file'

  (ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'unknown_type' })) sourceType
  >>> 'unknown_type'

"
Class {
	#name : 'ClaudeDocumentSource',
	#superclass : 'Object',
	#instVars : [
		'rawDict'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeDocumentSource class >> fromJson: aDictionary [
  "Dispatch on source type to create the correct concrete subclass."
  | sourceType |
  sourceType := aDictionary at: 'type' ifAbsent: [ nil ].
  sourceType = 'base64' ifTrue: [ ^ ClaudeBase64DocumentSource fromJson: aDictionary ].
  sourceType = 'text' ifTrue: [ ^ ClaudeTextDocumentSource fromJson: aDictionary ].
  sourceType = 'content' ifTrue: [ ^ ClaudeContentDocumentSource fromJson: aDictionary ].
  sourceType = 'url' ifTrue: [ ^ ClaudeURLDocumentSource fromJson: aDictionary ].
  sourceType = 'file' ifTrue: [ ^ ClaudeFileDocumentSource fromJson: aDictionary ].
  ^ self new rawDict: aDictionary; yourself
]

{ #category : 'STON' }
ClaudeDocumentSource class >> fromSton: stonReader [
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new rawDict: (dict at: #rawDict ifAbsent: [ Dictionary new ]); yourself
]

{ #category : 'json' }
ClaudeDocumentSource >> asJson [
  "Return JSON dictionary for this source."
  rawDict ifNotNil: [ ^ rawDict ].
  ^ self subclassResponsibility
]

{ #category : 'accessing' }
ClaudeDocumentSource >> data [
	"Polymorphic default: most document sources don't carry inline data
	 (URL, file, content sources reference the document remotely or by id).
	 Subclasses that DO carry inline data — ClaudeBase64DocumentSource,
	 ClaudeTextDocumentSource — override this. Returning nil here lets
	 ClaudeDocumentBlock>>data delegate without a respondsTo: guard."
	^ nil
]

{ #category : 'accessing' }
ClaudeDocumentSource >> mediaType [
	"Polymorphic default: most document sources don't advertise a media
	 type at the source layer (URL sources let the server sniff, content
	 sources are inline blocks). Subclasses that DO know their media type
	 — ClaudeBase64DocumentSource, ClaudeTextDocumentSource — override."
	^ nil
]

{ #category : 'accessing' }
ClaudeDocumentSource >> rawDict [
  ^ rawDict
]

{ #category : 'accessing' }
ClaudeDocumentSource >> rawDict: aDictionary [
  rawDict := aDictionary
]

{ #category : 'accessing' }
ClaudeDocumentSource >> sourceType [
  "Return the source type string."
  rawDict ifNotNil: [ ^ rawDict at: 'type' ifAbsent: [ 'unknown' ] ].
  ^ self subclassResponsibility
]

{ #category : 'STON' }
ClaudeDocumentSource >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawDict put: rawDict ]
]
