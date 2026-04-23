"
Tests for ClaudeDeletedSkillVersion (Claude-Messaging-Skills package).

  ClaudeDeletedSkillVersionTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeDeletedSkillVersionTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'tests' }
ClaudeDeletedSkillVersionTest >> testAsJsonEmitsIdAndType [
	| dict |
	dict := (ClaudeDeletedSkillVersion new id: '1759'; yourself) asJson.
	self assert: (dict at: 'id') equals: '1759'.
	self assert: (dict at: 'type') equals: 'skill_version_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillVersionTest >> testFromJsonDefaultsTypeWhenAbsent [
	| del |
	del := ClaudeDeletedSkillVersion fromJson: (Dictionary newFromPairs: { 'id'. '1759' }).
	self assert: del type equals: 'skill_version_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillVersionTest >> testFromJsonReadsId [
	| del |
	del := ClaudeDeletedSkillVersion fromJson: (Dictionary newFromPairs: { 'id'. '1759'. 'type'. 'skill_version_deleted' }).
	self assert: del id equals: '1759'
]

{ #category : 'tests' }
ClaudeDeletedSkillVersionTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := ClaudeDeletedSkillVersion new id: '1759'; yourself.
	restored := ClaudeDeletedSkillVersion fromJson: original asJson.
	self assert: restored id equals: '1759'.
	self assert: restored type equals: 'skill_version_deleted'
]

{ #category : 'tests' }
ClaudeDeletedSkillVersionTest >> testTypeDefaultsToSkillVersionDeleted [
	self assert: ClaudeDeletedSkillVersion new type equals: 'skill_version_deleted'
]
