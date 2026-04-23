"
A version of a registered skill. One ClaudeSkillVersion class covers three Go SDK shapes (BetaSkillVersionNewResponse, BetaSkillVersionGetResponse, BetaSkillVersionListResponse) which have identical fields. type is always 'skill_version'. version is a Unix epoch timestamp string. skillId points back to the parent ClaudeSkill.

  ClaudeSkillVersion new type
  >>> 'skill_version'

  (ClaudeSkillVersion new skillId: 'sk_abc'; version: '1759178010641129'; yourself) version
  >>> '1759178010641129'

  (ClaudeSkillVersion fromJson: (Dictionary newFromPairs: { 'skill_id'. 'sk_abc' })) skillId
  >>> 'sk_abc'

"
Class {
	#name : 'ClaudeSkillVersion',
	#superclass : 'Object',
	#instVars : [
		'id',
		'createdAt',
		'description',
		'directory',
		'name',
		'skillId',
		'type',
		'version'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkillVersion class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		createdAt: (aDictionary at: 'created_at' ifAbsent: [ nil ]);
		description: (aDictionary at: 'description' ifAbsent: [ nil ]);
		directory: (aDictionary at: 'directory' ifAbsent: [ nil ]);
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		skillId: (aDictionary at: 'skill_id' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'skill_version' ]);
		version: (aDictionary at: 'version' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeSkillVersion class >> jsonKeyMap [
	^ {
		#createdAt -> 'created_at'.
		#skillId -> 'skill_id'
	} asDictionary
]

{ #category : 'json' }
ClaudeSkillVersion >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'id' put: id.
	dict at: 'type' put: type.
	createdAt ifNotNil: [ dict at: 'created_at' put: createdAt ].
	description ifNotNil: [ dict at: 'description' put: description ].
	directory ifNotNil: [ dict at: 'directory' put: directory ].
	name ifNotNil: [ dict at: 'name' put: name ].
	skillId ifNotNil: [ dict at: 'skill_id' put: skillId ].
	version ifNotNil: [ dict at: 'version' put: version ].
	^ dict
]

{ #category : 'accessing' }
ClaudeSkillVersion >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
ClaudeSkillVersion >> createdAt: aValue [
	createdAt := aValue
]

{ #category : 'accessing' }
ClaudeSkillVersion >> description [
	^ description
]

{ #category : 'accessing' }
ClaudeSkillVersion >> description: aValue [
	description := aValue
]

{ #category : 'accessing' }
ClaudeSkillVersion >> directory [
	^ directory
]

{ #category : 'accessing' }
ClaudeSkillVersion >> directory: aValue [
	directory := aValue
]

{ #category : 'accessing' }
ClaudeSkillVersion >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeSkillVersion >> id: aValue [
	id := aValue
]

{ #category : 'initialization' }
ClaudeSkillVersion >> initialize [
	type := 'skill_version'
]

{ #category : 'accessing' }
ClaudeSkillVersion >> name [
	^ name
]

{ #category : 'accessing' }
ClaudeSkillVersion >> name: aValue [
	name := aValue
]

{ #category : 'printing' }
ClaudeSkillVersion >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeSkillVersion(';
		nextPutAll: (skillId ifNil: [ '?' ]);
		nextPutAll: ' v';
		nextPutAll: (version ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeSkillVersion >> skillId [
	^ skillId
]

{ #category : 'accessing' }
ClaudeSkillVersion >> skillId: aValue [
	skillId := aValue
]

{ #category : 'accessing' }
ClaudeSkillVersion >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeSkillVersion >> type: aValue [
	type := aValue
]

{ #category : 'accessing' }
ClaudeSkillVersion >> version [
	^ version
]

{ #category : 'accessing' }
ClaudeSkillVersion >> version: aValue [
	version := aValue
]
