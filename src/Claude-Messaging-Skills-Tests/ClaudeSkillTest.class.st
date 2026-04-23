"
Tests for ClaudeSkill (Claude-Messaging-Skills package).

  ClaudeSkillTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'fixtures' }
ClaudeSkillTest >> newFullSkill [
	| dict |
	dict := Dictionary new.
	dict at: 'id' put: 'sk_abc'.
	dict at: 'created_at' put: '2026-04-19T12:00:00Z'.
	dict at: 'display_title' put: 'My Skill'.
	dict at: 'latest_version' put: '1759178010641129'.
	dict at: 'source' put: 'custom'.
	dict at: 'type' put: 'skill'.
	dict at: 'updated_at' put: '2026-04-19T12:30:00Z'.
	^ ClaudeSkill fromJson: dict
]

{ #category : 'tests' }
ClaudeSkillTest >> testAsJsonEmitsAllSevenFields [
	| dict |
	dict := self newFullSkill asJson.
	self assert: (dict at: 'id') equals: 'sk_abc'.
	self assert: (dict at: 'created_at') equals: '2026-04-19T12:00:00Z'.
	self assert: (dict at: 'display_title') equals: 'My Skill'.
	self assert: (dict at: 'latest_version') equals: '1759178010641129'.
	self assert: (dict at: 'source') equals: 'custom'.
	self assert: (dict at: 'type') equals: 'skill'.
	self assert: (dict at: 'updated_at') equals: '2026-04-19T12:30:00Z'.
	self assert: dict size equals: 7
]

{ #category : 'tests' }
ClaudeSkillTest >> testAsJsonOmitsNilOptionalFields [
	"Regression: optional fields with nil values must not appear in the
	 emitted JSON. Only id and type are unconditional."
	| dict |
	dict := (ClaudeSkill new id: 'sk_x'; yourself) asJson.
	self assert: dict size equals: 2.
	self assert: (dict includesKey: 'id').
	self assert: (dict includesKey: 'type').
	self deny: (dict includesKey: 'created_at').
	self deny: (dict includesKey: 'display_title').
	self deny: (dict includesKey: 'latest_version').
	self deny: (dict includesKey: 'source').
	self deny: (dict includesKey: 'updated_at')
]

{ #category : 'tests' }
ClaudeSkillTest >> testFromJsonDefaultsTypeToSkillWhenAbsent [
	| skill |
	skill := ClaudeSkill fromJson: (Dictionary newFromPairs: { 'id'. 'sk_x' }).
	self assert: skill type equals: 'skill'
]

{ #category : 'tests' }
ClaudeSkillTest >> testFromJsonReadsAllSevenFields [
	| skill |
	skill := self newFullSkill.
	self assert: skill id equals: 'sk_abc'.
	self assert: skill createdAt equals: '2026-04-19T12:00:00Z'.
	self assert: skill displayTitle equals: 'My Skill'.
	self assert: skill latestVersion equals: '1759178010641129'.
	self assert: skill source equals: 'custom'.
	self assert: skill type equals: 'skill'.
	self assert: skill updatedAt equals: '2026-04-19T12:30:00Z'
]

{ #category : 'tests' }
ClaudeSkillTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := self newFullSkill.
	restored := ClaudeSkill fromJson: original asJson.
	self assert: restored id equals: original id.
	self assert: restored createdAt equals: original createdAt.
	self assert: restored displayTitle equals: original displayTitle.
	self assert: restored latestVersion equals: original latestVersion.
	self assert: restored source equals: original source.
	self assert: restored type equals: original type.
	self assert: restored updatedAt equals: original updatedAt
]

{ #category : 'tests' }
ClaudeSkillTest >> testSourceAcceptsCustomAndAnthropic [
	| custom anth |
	custom := ClaudeSkill fromJson: (Dictionary newFromPairs: { 'source'. 'custom' }).
	anth := ClaudeSkill fromJson: (Dictionary newFromPairs: { 'source'. 'anthropic' }).
	self assert: custom source equals: 'custom'.
	self assert: anth source equals: 'anthropic'
]

{ #category : 'tests' }
ClaudeSkillTest >> testTypeDefaultsToSkill [
	self assert: ClaudeSkill new type equals: 'skill'
]
