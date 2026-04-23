"
The canonical response shape for a file in the Claude Files API. Returned by ``ClaudeClient >> uploadFile:``, ``getFileMetadata:``, and as each entry of ``ClaudeFilePage >> data`` from ``listFiles``.

### When you see it

Every Files-API call that names one file or lists many returns one or more of these. It is the bridge between an opaque Files-API ``id`` and everything your code knows about that file -- the filename you uploaded with, the MIME type the server inferred, the byte count on disk, and when it was created.

### Accessors

- ``id`` -- the Files-API id (String); opaque, non-guessable, the handle for every other Files call
- ``filename`` -- the name the file was uploaded with (String)
- ``mimeType`` -- wire field ``mime_type``; inferred from the upload filename extension, overrideable via ``uploadFile:filename:mimeType:``
- ``sizeBytes`` -- wire field ``size_bytes``; byte count (Integer)
- ``createdAt`` -- wire field ``created_at``; ISO-8601 timestamp (String)
- ``type`` -- literal ``'file'``; the Files-API discriminator
- ``downloadable`` -- Boolean; true when the file can be retrieved via ``downloadFile:``

### Example

```
(ClaudeFileMetadata new id: 'file-abc'; filename: 'test.pdf'; yourself) filename
>>> 'test.pdf'
```

```
| meta |
meta := ClaudeFileMetadata fromJson: (Dictionary newFromPairs: {
    'id'. 'file-abc'.
    'filename'. 'test.pdf'.
    'size_bytes'. 1024.
    'mime_type'. 'application/pdf' }).
meta sizeBytes
>>> 1024
```

### See also

``ClaudeFilePage >> data`` -- collection of these returned by ``listFiles``. ``ClaudeFileDocumentSource`` -- how to reference an uploaded file in a subsequent message's content. ``ClaudeDeletedFile`` -- the confirmation shape returned after ``deleteFile:``.

"
Class {
	#name : 'ClaudeFileMetadata',
	#superclass : 'Object',
	#instVars : [
		'id',
		'filename',
		'mimeType',
		'sizeBytes',
		'createdAt',
		'type',
		'downloadable'
	],
	#category : 'Claude-Messaging-Files',
	#package : 'Claude-Messaging-Files'
}

{ #category : 'json' }
ClaudeFileMetadata class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [nil]);
		filename: (aDictionary at: 'filename' ifAbsent: [nil]);
		mimeType: (aDictionary at: 'mime_type' ifAbsent: [ nil ]);
		sizeBytes: (aDictionary at: 'size_bytes' ifAbsent: [ nil ]);
		createdAt: (aDictionary at: 'created_at' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'file' ]);
		downloadable: (aDictionary at: 'downloadable' ifAbsent: [ false ]);
		yourself
]

{ #category : 'STON' }
ClaudeFileMetadata class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		id: (dict at: #id ifAbsent: [ nil ]);
		filename: (dict at: #filename ifAbsent: [ nil ]);
		mimeType: (dict at: #mimeType ifAbsent: [ nil ]);
		sizeBytes: (dict at: #sizeBytes ifAbsent: [ nil ]);
		createdAt: (dict at: #createdAt ifAbsent: [ nil ]);
		type: (dict at: #type ifAbsent: [ nil ]);
		downloadable: (dict at: #downloadable ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeFileMetadata class >> jsonKeyMap [
	^ {
		#mimeType -> 'mime_type'.
		#sizeBytes -> 'size_bytes'.
		#createdAt -> 'created_at'
	} asDictionary
]

{ #category : 'json' }
ClaudeFileMetadata >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'id' put: id.
	dict at: 'filename' put: filename.
	dict at: 'type' put: type.
	mimeType ifNotNil: [ dict at: 'mime_type' put: mimeType ].
	sizeBytes ifNotNil: [ dict at: 'size_bytes' put: sizeBytes ].
	createdAt ifNotNil: [ dict at: 'created_at' put: createdAt ].
	downloadable ifNotNil: [ dict at: 'downloadable' put: downloadable ].
	^ dict
]

{ #category : 'accessing' }
ClaudeFileMetadata >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
ClaudeFileMetadata >> createdAt: aString [
	createdAt := aString
]

{ #category : 'accessing' }
ClaudeFileMetadata >> downloadable [
	^ downloadable
]

{ #category : 'accessing' }
ClaudeFileMetadata >> downloadable: aBoolean [
	downloadable := aBoolean
]

{ #category : 'accessing' }
ClaudeFileMetadata >> filename [
	^ filename
]

{ #category : 'accessing' }
ClaudeFileMetadata >> filename: aString [
	filename := aString
]

{ #category : 'accessing' }
ClaudeFileMetadata >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeFileMetadata >> id: aString [
	id := aString
]

{ #category : 'initialization' }
ClaudeFileMetadata >> initialize [
	type := 'file'
]

{ #category : 'accessing' }
ClaudeFileMetadata >> mimeType [
	^ mimeType
]

{ #category : 'accessing' }
ClaudeFileMetadata >> mimeType: aString [
	mimeType := aString
]

{ #category : 'printing' }
ClaudeFileMetadata >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeFileMetadata(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPutAll: ' ';
		nextPutAll: (filename ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeFileMetadata >> sizeBytes [
	^ sizeBytes
]

{ #category : 'accessing' }
ClaudeFileMetadata >> sizeBytes: anInteger [
	sizeBytes := anInteger
]

{ #category : 'STON' }
ClaudeFileMetadata >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		id ifNotNil: [ map at: #id put: id ].
		filename ifNotNil: [ map at: #filename put: filename ].
		mimeType ifNotNil: [ map at: #mimeType put: mimeType ].
		sizeBytes ifNotNil: [ map at: #sizeBytes put: sizeBytes ].
		createdAt ifNotNil: [ map at: #createdAt put: createdAt ].
		type ifNotNil: [ map at: #type put: type ].
		downloadable ifNotNil: [ map at: #downloadable put: downloadable ] ]
]

{ #category : 'accessing' }
ClaudeFileMetadata >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeFileMetadata >> type: aString [
	type := aString
]
