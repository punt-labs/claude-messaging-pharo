"
A paginated list of ``ClaudeSkillVersion`` returned by ``ClaudeClient >> listVersionsFor:`` and ``listVersionsFor:params:``. Uses page-token pagination: ``data`` holds one page of version entries, ``nextPage`` is the opaque token to pass back as ``page`` on ``ClaudeSkillVersionListParams`` to fetch more, or nil when this is the last page.

### When you touch it

Every Skills-API list-versions call returns one of these. To walk every version of a skill:

```
| client params all page |
client := ClaudeSDKExampleSupport resolveClient.
params := ClaudeSkillVersionListParams new limit: 100; yourself.
all := OrderedCollection new.
[ page := client listVersionsFor: 'sk_example' params: params.
  all addAll: page data.
  page hasMore ] whileTrue: [
    params page: page nextPage ].
```

Same shape as ``ClaudeSkillPage``. Sibling of ``ClaudeFilePage`` which uses cursor-ID pagination (``afterId`` / ``lastId``) instead of page tokens. Cross-reference to ``ClaudeSkillPage`` is the key point: the Skills API is uniform internally, different from Files.

### Accessors

- ``data`` -- an Array of ``ClaudeSkillVersion`` for this page
- ``nextPage`` -- the token to pass as ``page`` on the next request, or nil when this is the last page
- ``hasMore`` -- derived Boolean: ``nextPage notNil``

### Example

```
ClaudeSkillVersionPage new hasMore
>>> false
```

```
(ClaudeSkillVersionPage new nextPage: 'tok_xyz'; yourself) hasMore
>>> true
```

### See also

``ClaudeSkillVersionListParams`` -- the request-side page-token carrier. ``ClaudeSkillPage`` -- same pagination style, for the parent skill list. ``ClaudeFilePage`` -- the cursor-ID sibling in the Files API.

"
Class {
	#name : 'ClaudeSkillVersionPage',
	#superclass : 'Object',
	#instVars : [
		'data',
		'nextPage'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkillVersionPage class >> fromJson: aDictionary [
	^ self new
		data: ((aDictionary at: 'data' ifAbsent: [ Array new ])
			collect: [ :each | ClaudeSkillVersion fromJson: each ]);
		nextPage: (aDictionary at: 'next_page' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeSkillVersionPage class >> jsonKeyMap [
	^ {
		#nextPage -> 'next_page'
	} asDictionary
]

{ #category : 'json' }
ClaudeSkillVersionPage >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'data' put: (data collect: [ :each | each asJson ]) asArray.
	nextPage ifNotNil: [ dict at: 'next_page' put: nextPage ].
	^ dict
]

{ #category : 'accessing' }
ClaudeSkillVersionPage >> data [
	^ data
]

{ #category : 'accessing' }
ClaudeSkillVersionPage >> data: aCollection [
	data := aCollection
]

{ #category : 'testing' }
ClaudeSkillVersionPage >> hasMore [
	"Answer true if there is another page after this one."
	^ nextPage notNil
]

{ #category : 'initialization' }
ClaudeSkillVersionPage >> initialize [
	data := Array new
]

{ #category : 'accessing' }
ClaudeSkillVersionPage >> nextPage [
	^ nextPage
]

{ #category : 'accessing' }
ClaudeSkillVersionPage >> nextPage: aString [
	nextPage := aString
]

{ #category : 'printing' }
ClaudeSkillVersionPage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeSkillVersionPage(';
		print: data size;
		nextPutAll: ' versions'.
	nextPage ifNotNil: [ aStream nextPutAll: ', nextPage: '; nextPutAll: nextPage ].
	aStream nextPut: $)
]
