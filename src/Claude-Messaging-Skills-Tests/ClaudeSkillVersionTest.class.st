"
Tests for ClaudeSkillVersion (Claude-Messaging-Skills package).

  ClaudeSkillVersionTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillVersionTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'fixtures' }
ClaudeSkillVersionTest >> newFullVersion [
	| dict |
	dict := Dictionary new.
	dict at: 'id' put: '1759178010641129'.
	dict at: 'created_at' put: '2026-04-19T12:00:00Z'.
	dict at: 'description' put: 'describes the skill'.
	dict at: 'directory' put: 'my-skill'.
	dict at: 'name' put: 'my-skill'.
	dict at: 'skill_id' put: 'sk_abc'.
	dict at: 'type' put: 'skill_version'.
	dict at: 'version' put: '1759178010641129'.
	^ ClaudeSkillVersion fromJson: dict
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testAsJsonEmitsAllEightFields [
	| dict |
	dict := self newFullVersion asJson.
	self assert: dict size equals: 8.
	self assert: (dict at: 'id') equals: '1759178010641129'.
	self assert: (dict at: 'skill_id') equals: 'sk_abc'.
	self assert: (dict at: 'type') equals: 'skill_version'
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testAsJsonOmitsNilOptionalFields [
	"Regression: optional fields with nil values must not appear in the
	 emitted JSON. Only id and type are unconditional."
	| dict |
	dict := (ClaudeSkillVersion new id: 'ver_x'; yourself) asJson.
	self assert: dict size equals: 2.
	self assert: (dict includesKey: 'id').
	self assert: (dict includesKey: 'type').
	self deny: (dict includesKey: 'created_at').
	self deny: (dict includesKey: 'description').
	self deny: (dict includesKey: 'directory').
	self deny: (dict includesKey: 'name').
	self deny: (dict includesKey: 'skill_id').
	self deny: (dict includesKey: 'version')
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testFromJsonDefaultsTypeToSkillVersionWhenAbsent [
	| v |
	v := ClaudeSkillVersion fromJson: (Dictionary newFromPairs: { 'id'. '123' }).
	self assert: v type equals: 'skill_version'
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testFromJsonReadsAllEightFields [
	| v |
	v := self newFullVersion.
	self assert: v id equals: '1759178010641129'.
	self assert: v createdAt equals: '2026-04-19T12:00:00Z'.
	self assert: v description equals: 'describes the skill'.
	self assert: v directory equals: 'my-skill'.
	self assert: v name equals: 'my-skill'.
	self assert: v skillId equals: 'sk_abc'.
	self assert: v type equals: 'skill_version'.
	self assert: v version equals: '1759178010641129'
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := self newFullVersion.
	restored := ClaudeSkillVersion fromJson: original asJson.
	self assert: restored id equals: original id.
	self assert: restored skillId equals: original skillId.
	self assert: restored version equals: original version.
	self assert: restored description equals: original description
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testSkillIdReferencesParentSkill [
	| v |
	v := ClaudeSkillVersion fromJson: (Dictionary newFromPairs: { 'skill_id'. 'sk_abc' }).
	self assert: v skillId equals: 'sk_abc'.
	self assert: v skillId isString
]

{ #category : 'tests' }
ClaudeSkillVersionTest >> testTypeDefaultsToSkillVersion [
	self assert: ClaudeSkillVersion new type equals: 'skill_version'
]
