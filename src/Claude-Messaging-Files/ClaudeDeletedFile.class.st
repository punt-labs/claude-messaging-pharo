"
The confirmation record returned by ``ClaudeClient >> deleteFile:``. Carries the id of the deleted file and a literal ``type`` tag of ``'file_deleted'`` so callers can disambiguate from other response shapes on wire logs.

### When you see it

Only as the return value of ``deleteFile:``. A successful delete returns one of these; failure raises a ``ClaudeApiError`` subclass. There is no content -- the object exists to make the confirmation typed rather than a bare Dictionary.

### Accessors

- ``id`` -- the file id that was deleted, echoed back from the request
- ``type`` -- always ``'file_deleted'``; the Files-API discriminator

### Example

```
(ClaudeDeletedFile new id: 'file-abc'; yourself) type
>>> 'file_deleted'
```

```
(ClaudeDeletedFile new id: 'file-abc'; yourself) id
>>> 'file-abc'
```

### See also

``ClaudeDeletedSkill`` / ``ClaudeDeletedSkillVersion`` -- the Skills-API siblings with the same shape (``id`` + ``type``) but different discriminator strings. ``ClaudeClient >> deleteFile:`` -- the API entry that returns this.

"
Class {
	#name : 'ClaudeDeletedFile',
	#superclass : 'Object',
	#instVars : [
		'id',
		'type'
	],
	#category : 'Claude-Messaging-Files',
	#package : 'Claude-Messaging-Files'
}

{ #category : 'json' }
ClaudeDeletedFile class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [nil]);
		type: (aDictionary at: 'type' ifAbsent: [ 'file_deleted' ]);
		yourself
]

{ #category : 'STON' }
ClaudeDeletedFile class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		id: (dict at: #id ifAbsent: [ nil ]);
		type: (dict at: #type ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeDeletedFile >> asJson [
	^ OrderedDictionary new
		at: 'id' put: id;
		at: 'type' put: type;
		yourself
]

{ #category : 'accessing' }
ClaudeDeletedFile >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeDeletedFile >> id: aString [
	id := aString
]

{ #category : 'initialization' }
ClaudeDeletedFile >> initialize [
	type := 'file_deleted'
]

{ #category : 'printing' }
ClaudeDeletedFile >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeDeletedFile(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'STON' }
ClaudeDeletedFile >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		id ifNotNil: [ map at: #id put: id ].
		type ifNotNil: [ map at: #type put: type ] ]
]

{ #category : 'accessing' }
ClaudeDeletedFile >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeDeletedFile >> type: aString [
	type := aString
]
