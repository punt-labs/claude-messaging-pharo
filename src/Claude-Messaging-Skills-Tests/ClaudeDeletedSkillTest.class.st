"
Tests for ClaudeDeletedSkill (Claude-Messaging-Skills package).

  ClaudeDeletedSkillTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeDeletedSkillTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'tests' }
ClaudeDeletedSkillTest >> testAsJsonEmitsIdAndType [
	| dict |
	dict := (ClaudeDeletedSkill new id: 'sk_abc'; yourself) asJson.
	self assert: (dict at: 'id') equals: 'sk_abc'.
	self assert: (dict at: 'type') equals: 'skill_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillTest >> testFromJsonDefaultsTypeWhenAbsent [
	| del |
	del := ClaudeDeletedSkill fromJson: (Dictionary newFromPairs: { 'id'. 'sk_abc' }).
	self assert: del type equals: 'skill_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillTest >> testFromJsonReadsId [
	| del |
	del := ClaudeDeletedSkill fromJson: (Dictionary newFromPairs: { 'id'. 'sk_abc'. 'type'. 'skill_deleted' }).
	self assert: del id equals: 'sk_abc'
]

{ #category : 'tests' }
ClaudeDeletedSkillTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := ClaudeDeletedSkill new id: 'sk_abc'; yourself.
	restored := ClaudeDeletedSkill fromJson: original asJson.
	self assert: restored id equals: 'sk_abc'.
	self assert: restored type equals: 'skill_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillTest >> testTypeDefaultsToSkillDeleted [
	self assert: ClaudeDeletedSkill new type equals: 'skill_deleted'
]
