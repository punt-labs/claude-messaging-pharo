"
A skill registered with Anthropic's Skills API. One ClaudeSkill class covers three Go SDK shapes (BetaSkillNewResponse, BetaSkillGetResponse, BetaSkillListResponse) which have identical fields. source is 'custom' (user-uploaded) or 'anthropic' (built-in). type is always 'skill'. latestVersion points at the most recent version of this skill.

  ClaudeSkill new type
  >>> 'skill'

  (ClaudeSkill new id: 'sk_abc'; displayTitle: 'My Skill'; yourself) displayTitle
  >>> 'My Skill'

  (ClaudeSkill fromJson: (Dictionary newFromPairs: { 'id'. 'sk_abc'. 'source'. 'custom' })) source
  >>> 'custom'

"
Class {
	#name : 'ClaudeSkill',
	#superclass : 'Object',
	#instVars : [
		'id',
		'createdAt',
		'displayTitle',
		'latestVersion',
		'source',
		'type',
		'updatedAt'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkill class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		createdAt: (aDictionary at: 'created_at' ifAbsent: [ nil ]);
		displayTitle: (aDictionary at: 'display_title' ifAbsent: [ nil ]);
		latestVersion: (aDictionary at: 'latest_version' ifAbsent: [ nil ]);
		source: (aDictionary at: 'source' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'skill' ]);
		updatedAt: (aDictionary at: 'updated_at' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeSkill class >> jsonKeyMap [
	^ {
		#createdAt -> 'created_at'.
		#displayTitle -> 'display_title'.
		#latestVersion -> 'latest_version'.
		#updatedAt -> 'updated_at'
	} asDictionary
]

{ #category : 'json' }
ClaudeSkill >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'id' put: id.
	dict at: 'type' put: type.
	createdAt ifNotNil: [ dict at: 'created_at' put: createdAt ].
	displayTitle ifNotNil: [ dict at: 'display_title' put: displayTitle ].
	latestVersion ifNotNil: [ dict at: 'latest_version' put: latestVersion ].
	source ifNotNil: [ dict at: 'source' put: source ].
	updatedAt ifNotNil: [ dict at: 'updated_at' put: updatedAt ].
	^ dict
]

{ #category : 'accessing' }
ClaudeSkill >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
ClaudeSkill >> createdAt: aValue [
	createdAt := aValue
]

{ #category : 'accessing' }
ClaudeSkill >> displayTitle [
	^ displayTitle
]

{ #category : 'accessing' }
ClaudeSkill >> displayTitle: aValue [
	displayTitle := aValue
]

{ #category : 'accessing' }
ClaudeSkill >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeSkill >> id: aValue [
	id := aValue
]

{ #category : 'initialization' }
ClaudeSkill >> initialize [
	type := 'skill'
]

{ #category : 'accessing' }
ClaudeSkill >> latestVersion [
	^ latestVersion
]

{ #category : 'accessing' }
ClaudeSkill >> latestVersion: aValue [
	latestVersion := aValue
]

{ #category : 'printing' }
ClaudeSkill >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeSkill(';
		nextPutAll: (id ifNil: [ '?' ]);
		nextPutAll: ' ';
		nextPutAll: (displayTitle ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeSkill >> source [
	^ source
]

{ #category : 'accessing' }
ClaudeSkill >> source: aValue [
	source := aValue
]

{ #category : 'accessing' }
ClaudeSkill >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeSkill >> type: aValue [
	type := aValue
]

{ #category : 'accessing' }
ClaudeSkill >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
ClaudeSkill >> updatedAt: aValue [
	updatedAt := aValue
]
