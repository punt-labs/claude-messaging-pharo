"
The confirmation record returned by ``ClaudeClient >> deleteSkill:``. Carries the id of the deleted skill and a literal ``type`` tag of ``'skill_deleted'`` so callers can disambiguate from other response shapes on wire logs.

### When you see it

Only as the return value of ``deleteSkill:``. A successful delete returns one of these; failure raises a ``ClaudeApiError`` subclass. Note: ``deleteSkill:`` requires that every version of the skill already be deleted via ``deleteVersion:for:`` -- calling it on a skill with live versions raises a 400. Enumerate ``listVersionsFor:`` + ``deleteVersion:for:`` first, then ``deleteSkill:``.

### Accessors

- ``id`` -- the skill id that was deleted, echoed back from the request
- ``type`` -- always ``'skill_deleted'``; the Skills-API discriminator

### Example

```
(ClaudeDeletedSkill new id: 'sk_abc'; yourself) type
>>> 'skill_deleted'
```

```
(ClaudeDeletedSkill new id: 'sk_abc'; yourself) id
>>> 'sk_abc'
```

### See also

``ClaudeDeletedSkillVersion`` -- the per-version companion; use it to walk versions before the skill delete. ``ClaudeDeletedFile`` -- the Files-API sibling with the same shape. ``ClaudeClient >> deleteSkill:`` / ``deleteVersion:for:`` -- the API entries.

"
Class {
	#name : 'ClaudeDeletedSkill',
	#superclass : 'Object',
	#instVars : [
		'id',
		'type'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeDeletedSkill class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'skill_deleted' ]);
		yourself
]

{ #category : 'json' }
ClaudeDeletedSkill class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'json' }
ClaudeDeletedSkill >> asJson [
	^ OrderedDictionary new
		at: 'id' put: id;
		at: 'type' put: type;
		yourself
]

{ #category : 'accessing' }
ClaudeDeletedSkill >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeDeletedSkill >> id: aValue [
	id := aValue
]

{ #category : 'initialization' }
ClaudeDeletedSkill >> initialize [
	type := 'skill_deleted'
]

{ #category : 'printing' }
ClaudeDeletedSkill >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeDeletedSkill(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeDeletedSkill >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeDeletedSkill >> type: aValue [
	type := aValue
]
