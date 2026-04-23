"
A paginated list of files returned by ``ClaudeClient >> listFiles`` and ``listFiles:``. Uses cursor-ID pagination: ``data`` holds one page of ``ClaudeFileMetadata`` entries, ``hasMore`` says whether more exist, and ``lastId`` is the cursor to pass back as ``afterId`` on the next call.

### When you touch it

Every Files-API list call returns one of these. To iterate the full history, loop on ``hasMore``:

```
| client params all page |
client := ClaudeSDKExampleSupport resolveClient.
params := ClaudeFileListParams new limit: 100; yourself.
all := OrderedCollection new.
[ page := client listFiles: params.
  all addAll: page data.
  page hasMore ] whileTrue: [
    params afterId: page lastId ].
```

Sibling of ``ClaudeSkillPage`` (page-token pagination, ``nextPage`` is an opaque token) and ``ClaudeSkillVersionPage`` (same page-token style as ``ClaudeSkillPage``). The Files API and Skills API deliberately differ here -- Files uses cursor IDs, Skills uses page tokens -- because they were added at different points in Anthropic's evolution. The SDK preserves both shapes.

### Accessors

- ``data`` -- an Array of ``ClaudeFileMetadata`` for this page; empty when no files match
- ``hasMore`` -- Boolean; true when another page exists
- ``firstId`` / ``lastId`` -- the cursor IDs of the first and last entries on this page; pass ``lastId`` back as ``afterId`` (or ``firstId`` as ``beforeId``) on the next call

### Example

```
ClaudeFilePage new hasMore
>>> false
```

```
| page |
page := ClaudeFilePage fromJson: (Dictionary newFromPairs: {
    'data'. #().
    'has_more'. true.
    'first_id'. 'file-abc'.
    'last_id'. 'file-xyz' }).
page lastId
>>> 'file-xyz'
```

### See also

``ClaudeFileListParams`` -- the request-side cursor carrier. ``ClaudeFileMetadata`` -- each ``data`` entry. ``ClaudeSkillVersionPage`` -- the page-token sibling in the Skills API.

"
Class {
	#name : 'ClaudeFilePage',
	#superclass : 'Object',
	#instVars : [
		'data',
		'hasMore',
		'firstId',
		'lastId'
	],
	#category : 'Claude-Messaging-Files',
	#package : 'Claude-Messaging-Files'
}

{ #category : 'json' }
ClaudeFilePage class >> fromJson: aDictionary [
	^ self new
		data: ((aDictionary at: 'data' ifAbsent: [ Array new ]) collect: [ :each |
			ClaudeFileMetadata fromJson: each ]);
		hasMore: (aDictionary at: 'has_more' ifAbsent: [ false ]);
		firstId: (aDictionary at: 'first_id' ifAbsent: [ nil ]);
		lastId: (aDictionary at: 'last_id' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'STON' }
ClaudeFilePage class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		data: (dict at: #data ifAbsent: [ Array new ]);
		hasMore: (dict at: #hasMore ifAbsent: [ false ]);
		firstId: (dict at: #firstId ifAbsent: [ nil ]);
		lastId: (dict at: #lastId ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeFilePage class >> jsonKeyMap [
	^ {
		#hasMore -> 'has_more'.
		#firstId -> 'first_id'.
		#lastId -> 'last_id'
	} asDictionary
]

{ #category : 'json' }
ClaudeFilePage >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'data' put: (data collect: [ :each | each asJson ]).
	dict at: 'has_more' put: hasMore.
	firstId ifNotNil: [ dict at: 'first_id' put: firstId ].
	lastId ifNotNil: [ dict at: 'last_id' put: lastId ].
	^ dict
]

{ #category : 'accessing' }
ClaudeFilePage >> data [
	^ data
]

{ #category : 'accessing' }
ClaudeFilePage >> data: anArray [
	data := anArray
]

{ #category : 'accessing' }
ClaudeFilePage >> firstId [
	^ firstId
]

{ #category : 'accessing' }
ClaudeFilePage >> firstId: aString [
	firstId := aString
]

{ #category : 'accessing' }
ClaudeFilePage >> hasMore [
	^ hasMore
]

{ #category : 'accessing' }
ClaudeFilePage >> hasMore: aBoolean [
	hasMore := aBoolean
]

{ #category : 'initialization' }
ClaudeFilePage >> initialize [
	data := Array new.
	hasMore := false
]

{ #category : 'accessing' }
ClaudeFilePage >> lastId [
	^ lastId
]

{ #category : 'accessing' }
ClaudeFilePage >> lastId: aString [
	lastId := aString
]

{ #category : 'printing' }
ClaudeFilePage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeFilePage(';
		print: data size;
		nextPutAll: ' files, hasMore: ';
		print: hasMore;
		nextPut: $)
]

{ #category : 'STON' }
ClaudeFilePage >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #data put: data.
		map at: #hasMore put: hasMore.
		firstId ifNotNil: [ map at: #firstId put: firstId ].
		lastId ifNotNil: [ map at: #lastId put: lastId ] ]
]
