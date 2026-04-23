"
A paginated list of ``ClaudeSkill`` returned by ``ClaudeClient >> listSkills`` and ``listSkills:``. Uses page-token pagination: ``data`` holds one page of skill entries, ``nextPage`` is the opaque token to pass back as ``page`` on the next request, or nil when this is the last page.

### When you touch it

Every Skills-API list call returns one of these. To walk every skill in the workspace:

```
| client params all page |
client := ClaudeSDKExampleSupport resolveClient.
params := ClaudeSkillListParams new limit: 100; yourself.
all := OrderedCollection new.
[ page := client listSkills: params.
  all addAll: page data.
  page hasMore ] whileTrue: [
    params page: page nextPage ].
```

Sibling of ``ClaudeSkillVersionPage`` (same page-token shape, for the version list under a single skill) and ``ClaudeFilePage`` (cursor-ID pagination via ``afterId`` / ``lastId``, Files API). The Skills API and Files API deliberately differ here -- Skills uses page tokens, Files uses cursor IDs -- because they were added at different points in Anthropic's evolution. The SDK preserves both shapes.

### Accessors

- ``data`` -- an Array of ``ClaudeSkill`` for this page; empty when no skills match
- ``nextPage`` -- the token to pass as ``page`` on the next request, or nil when this is the last page
- ``hasMore`` -- derived Boolean: ``nextPage notNil``

### Example

```
ClaudeSkillPage new hasMore
>>> false
```

```
(ClaudeSkillPage new nextPage: 'tok_xyz'; yourself) hasMore
>>> true
```

### See also

``ClaudeSkillListParams`` -- the request-side page-token carrier. ``ClaudeSkillVersionPage`` -- same pagination style, for the version list of a single skill. ``ClaudeFilePage`` -- the cursor-ID sibling in the Files API.

"
Class {
	#name : 'ClaudeSkillPage',
	#superclass : 'Object',
	#instVars : [
		'data',
		'nextPage'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkillPage class >> fromJson: aDictionary [
	^ self new
		data: ((aDictionary at: 'data' ifAbsent: [ Array new ])
			collect: [ :each | ClaudeSkill fromJson: each ]);
		nextPage: (aDictionary at: 'next_page' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeSkillPage class >> jsonKeyMap [
	^ {
		#nextPage -> 'next_page'
	} asDictionary
]

{ #category : 'json' }
ClaudeSkillPage >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'data' put: (data collect: [ :each | each asJson ]) asArray.
	nextPage ifNotNil: [ dict at: 'next_page' put: nextPage ].
	^ dict
]

{ #category : 'accessing' }
ClaudeSkillPage >> data [
	^ data
]

{ #category : 'accessing' }
ClaudeSkillPage >> data: aCollection [
	data := aCollection
]

{ #category : 'testing' }
ClaudeSkillPage >> hasMore [
	"Answer true if there is another page after this one."
	^ nextPage notNil
]

{ #category : 'initialization' }
ClaudeSkillPage >> initialize [
	data := Array new
]

{ #category : 'accessing' }
ClaudeSkillPage >> nextPage [
	^ nextPage
]

{ #category : 'accessing' }
ClaudeSkillPage >> nextPage: aString [
	nextPage := aString
]

{ #category : 'printing' }
ClaudeSkillPage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeSkillPage(';
		print: data size;
		nextPutAll: ' skills'.
	nextPage ifNotNil: [ aStream nextPutAll: ', nextPage: '; nextPutAll: nextPage ].
	aStream nextPut: $)
]
