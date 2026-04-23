"
Tests for ClaudeSkillSpec (Claude-Messaging-Types package).

  ClaudeSkillSpecTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillSpecTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeSkillSpecTest >> testAsJsonRequiresSkillIdAndType [
	"Both skill_id and type are required by the wire. Missing them would
	 emit nulls and trigger an API 400. Raise explicitly to surface bugs
	 at construction time instead of inside the network round-trip."
	| spec |
	spec := ClaudeSkillSpec new.
	self should: [ spec asJson ] raise: Error.
	spec skillId: 'sk_abc'.
	self should: [ spec asJson ] raise: Error.
	spec type: 'custom'.
	self shouldnt: [ spec asJson ] raise: Error
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testFromJsonAcceptsMissingVersion [
	| spec |
	spec := ClaudeSkillSpec fromJson: (Dictionary newFromPairs: { 'skill_id'. 'sk'. 'type'. 'custom' }).
	self assert: spec version isNil
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testFromJsonPreservesUnknownFields [
	"A future skill spec adding fields beyond skill_id, type, and version
	 must roundtrip back through asJson. Mirrors the forward-compat strategy
	 ClaudeMCPServerDefinition uses for unknown transport variants."
	| restored emitted |
	restored := ClaudeSkillSpec fromJson: (Dictionary newFromPairs: {
		'skill_id'. 'sk_abc'.
		'type'. 'custom'.
		'experimental_setting'. 42 }).
	self assert: (restored extraFields at: 'experimental_setting') equals: 42.
	emitted := restored asJson.
	self assert: (emitted at: 'experimental_setting') equals: 42
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testFromJsonReadsAllFields [
	| spec dict |
	dict := Dictionary newFromPairs: { 'skill_id'. 'sk_abc'. 'type'. 'anthropic'. 'version'. 'v1' }.
	spec := ClaudeSkillSpec fromJson: dict.
	self assert: spec skillId equals: 'sk_abc'.
	self assert: spec type equals: 'anthropic'.
	self assert: spec version equals: 'v1'
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testRequiredFieldsSerialize [
	| dict |
	dict := (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom') asJson.
	self assert: (dict at: 'skill_id') equals: 'sk_abc'.
	self assert: (dict at: 'type') equals: 'custom'
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testRoundtripPreservesUnknownNestedJson [
	"Nested unknown values (Dictionary, Array) must survive the roundtrip
	 unchanged. Preservation is by-reference so downstream consumers reading
	 nested keys after the SDK passed the message through still see the
	 original structure."
	| restored emitted region |
	restored := ClaudeSkillSpec fromJson: (Dictionary newFromPairs: {
		'skill_id'. 'sk_abc'.
		'type'. 'custom'.
		'metadata'. (Dictionary newFromPairs: { 'region'. 'us-west' }) }).
	emitted := restored asJson.
	region := (emitted at: 'metadata') at: 'region'.
	self assert: region equals: 'us-west'.
	self assert: (emitted at: 'metadata') class equals: Dictionary
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := ClaudeSkillSpec skillId: 'sk_abc' type: 'custom' version: 'v1'.
	restored := ClaudeSkillSpec fromJson: original asJson.
	self assert: restored skillId equals: original skillId.
	self assert: restored type equals: original type.
	self assert: restored version equals: original version
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testTypeAcceptsCustomAndAnthropic [
	| custom anth |
	custom := ClaudeSkillSpec skillId: 'sk' type: 'custom'.
	anth := ClaudeSkillSpec skillId: 'sk' type: 'anthropic'.
	self assert: custom type equals: 'custom'.
	self assert: anth type equals: 'anthropic'
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testVersionOmittedWhenNil [
	| dict |
	dict := (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom') asJson.
	self deny: (dict includesKey: 'version')
]

{ #category : 'tests' }
ClaudeSkillSpecTest >> testVersionSerializedWhenSet [
	| dict |
	dict := (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom' version: '1759178010641129') asJson.
	self assert: (dict at: 'version') equals: '1759178010641129'
]
