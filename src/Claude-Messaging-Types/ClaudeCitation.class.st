"
A citation reference on a text block. When the model cites source content, citations appear on ClaudeTextBlock with the cited text, document index, title, and character range.

### Examples

```
| d |
d := Dictionary new.
d at: 'type' put: 'char_location'.
d at: 'cited_text' put: 'hello world'.
d at: 'document_index' put: 0.
d at: 'start_char_index' put: 0.
d at: 'end_char_index' put: 11.
(ClaudeCitation fromJson: d) citedText
>>> 'hello world'
```

"
Class {
	#name : 'ClaudeCitation',
	#superclass : 'Object',
	#instVars : [
		'citedText',
		'documentIndex',
		'documentTitle',
		'startCharIndex',
		'endCharIndex'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeCitation class >> fromJson: aDictionary [
	^ self new
		citedText: (aDictionary at: 'cited_text' ifAbsent: [ nil ]);
		documentIndex: (aDictionary at: 'document_index' ifAbsent: [ nil ]);
		documentTitle: (aDictionary at: 'document_title' ifAbsent: [ nil ]);
		startCharIndex: (aDictionary at: 'start_char_index' ifAbsent: [ nil ]);
		endCharIndex: (aDictionary at: 'end_char_index' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeCitation class >> jsonKeyMap [
	^ {
		#citedText -> 'cited_text'.
		#documentIndex -> 'document_index'.
		#documentTitle -> 'document_title'.
		#startCharIndex -> 'start_char_index'.
		#endCharIndex -> 'end_char_index'
	} asDictionary
]

{ #category : 'json' }
ClaudeCitation >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'char_location'.
	dict at: 'cited_text' put: citedText.
	dict at: 'document_index' put: documentIndex.
	dict at: 'document_title' put: documentTitle.
	dict at: 'start_char_index' put: startCharIndex.
	dict at: 'end_char_index' put: endCharIndex.
	^ dict
]

{ #category : 'accessing' }
ClaudeCitation >> citedText [
	^ citedText
]

{ #category : 'accessing' }
ClaudeCitation >> citedText: aString [
	citedText := aString
]

{ #category : 'accessing' }
ClaudeCitation >> documentIndex [
	^ documentIndex
]

{ #category : 'accessing' }
ClaudeCitation >> documentIndex: anInteger [
	documentIndex := anInteger
]

{ #category : 'accessing' }
ClaudeCitation >> documentTitle [
	^ documentTitle
]

{ #category : 'accessing' }
ClaudeCitation >> documentTitle: aString [
	documentTitle := aString
]

{ #category : 'accessing' }
ClaudeCitation >> endCharIndex [
	^ endCharIndex
]

{ #category : 'accessing' }
ClaudeCitation >> endCharIndex: anInteger [
	endCharIndex := anInteger
]

{ #category : 'printing' }
ClaudeCitation >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeCitation(';
		print: (documentTitle ifNil: [ '?' ]);
		nextPutAll: ' ';
		print: (startCharIndex ifNil: [ 0 ]);
		nextPut: $-;
		print: (endCharIndex ifNil: [ 0 ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeCitation >> startCharIndex [
	^ startCharIndex
]

{ #category : 'accessing' }
ClaudeCitation >> startCharIndex: anInteger [
	startCharIndex := anInteger
]
