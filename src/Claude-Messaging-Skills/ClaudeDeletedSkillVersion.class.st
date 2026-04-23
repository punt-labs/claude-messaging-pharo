"
The confirmation record returned by ``ClaudeClient >> deleteVersion:for:``. Carries the id of the deleted skill version and a literal ``type`` tag of ``'skill_version_deleted'`` so callers can disambiguate from other response shapes on wire logs.

### When you see it

Only as the return value of ``deleteVersion:for:``. A successful delete returns one of these; failure raises a ``ClaudeApiError`` subclass. Use this one per version; when every version is gone, call ``deleteSkill:`` to delete the parent skill itself -- that returns a ``ClaudeDeletedSkill``. Calling ``deleteSkill:`` while versions remain raises a 400.

### Accessors

- ``id`` -- the skill-version id that was deleted, echoed back from the request
- ``type`` -- always ``'skill_version_deleted'``; the Skills-API discriminator

### Example

```
(ClaudeDeletedSkillVersion new id: 'skv_abc'; yourself) type
>>> 'skill_version_deleted'
```

```
(ClaudeDeletedSkillVersion new id: 'skv_abc'; yourself) id
>>> 'skv_abc'
```

### See also

``ClaudeDeletedSkill`` -- the parent-skill companion, returned by ``deleteSkill:`` after every version is deleted. ``ClaudeDeletedFile`` -- the Files-API sibling with the same shape (``id`` + ``type``) but the ``'file_deleted'`` discriminator. ``ClaudeClient >> deleteVersion:for:`` / ``listVersionsFor:`` -- the API entries.

"
Class {
	#name : 'ClaudeDeletedSkillVersion',
	#superclass : 'Object',
	#instVars : [
		'id',
		'type'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeDeletedSkillVersion class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'skill_version_deleted' ]);
		yourself
]

{ #category : 'json' }
ClaudeDeletedSkillVersion class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'json' }
ClaudeDeletedSkillVersion >> asJson [
	^ OrderedDictionary new
		at: 'id' put: id;
		at: 'type' put: type;
		yourself
]

{ #category : 'accessing' }
ClaudeDeletedSkillVersion >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeDeletedSkillVersion >> id: aValue [
	id := aValue
]

{ #category : 'initialization' }
ClaudeDeletedSkillVersion >> initialize [
	type := 'skill_version_deleted'
]

{ #category : 'printing' }
ClaudeDeletedSkillVersion >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeDeletedSkillVersion(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeDeletedSkillVersion >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeDeletedSkillVersion >> type: aValue [
	type := aValue
]
