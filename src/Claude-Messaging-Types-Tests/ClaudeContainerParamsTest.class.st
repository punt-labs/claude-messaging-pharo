"
Tests for ClaudeContainerParams (Claude-Messaging-Types package).

  ClaudeContainerParamsTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeContainerParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeContainerParamsTest >> testEmptyParamsSerializeToEmptyDict [
	self assert: ClaudeContainerParams new asJson isEmpty
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testEmptySkillsCollectionOmitsKey [
	| params |
	params := ClaudeContainerParams new.
	params skills: OrderedCollection new.
	self deny: (params asJson includesKey: 'skills')
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testFromJsonAcceptsMissingId [
	| params |
	params := ClaudeContainerParams fromJson: (Dictionary newFromPairs: { 'skills'. (Array with: (Dictionary newFromPairs: { 'skill_id'. 'sk_1'. 'type'. 'custom' })) }).
	self assert: params id isNil.
	self assert: params skills size equals: 1
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testFromJsonAcceptsMissingSkills [
	| params |
	params := ClaudeContainerParams fromJson: (Dictionary newFromPairs: { 'id'. 'ctr' }).
	self assert: params id equals: 'ctr'.
	self assert: params skills isNil
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testFromJsonPreservesUnknownFields [
	"A future container variant adding fields beyond id and skills must
	 roundtrip back through asJson. Mirrors the forward-compat strategy
	 ClaudeMCPServerDefinition uses for unknown transport variants."
	| restored emitted |
	restored := ClaudeContainerParams fromJson: (Dictionary newFromPairs: {
		'id'. 'ctr_abc'.
		'experimental_setting'. 42 }).
	self assert: (restored extraFields at: 'experimental_setting') equals: 42.
	emitted := restored asJson.
	self assert: (emitted at: 'experimental_setting') equals: 42
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testFullParamsRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := ClaudeContainerParams new.
	original id: 'ctr_abc'.
	original skills: { ClaudeSkillSpec skillId: 'sk_1' type: 'custom' }.
	restored := ClaudeContainerParams fromJson: original asJson.
	self assert: restored id equals: 'ctr_abc'.
	self assert: restored skills size equals: 1.
	self assert: restored skills first skillId equals: 'sk_1'
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testIdOnlySerializesId [
	| dict |
	dict := (ClaudeContainerParams new id: 'ctr_abc'; yourself) asJson.
	self assert: dict size equals: 1.
	self assert: (dict at: 'id') equals: 'ctr_abc'
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testRoundtripPreservesUnknownNestedJson [
	"Nested unknown values (Dictionary, Array) must survive the roundtrip
	 unchanged. Preservation is by-reference so downstream consumers reading
	 nested keys after the SDK passed the message through still see the
	 original structure."
	| restored emitted region |
	restored := ClaudeContainerParams fromJson: (Dictionary newFromPairs: {
		'id'. 'ctr_abc'.
		'metadata'. (Dictionary newFromPairs: { 'region'. 'us-west' }) }).
	emitted := restored asJson.
	region := (emitted at: 'metadata') at: 'region'.
	self assert: region equals: 'us-west'.
	self assert: (emitted at: 'metadata') class equals: Dictionary
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testSkillsOnlySerializesSkills [
	| dict params |
	params := ClaudeContainerParams new.
	params skills: { ClaudeSkillSpec skillId: 'sk_1' type: 'custom' }.
	dict := params asJson.
	self assert: dict size equals: 1.
	self assert: ((dict at: 'skills') first at: 'skill_id') equals: 'sk_1'
]

{ #category : 'tests' }
ClaudeContainerParamsTest >> testSkillsParseToClaudeSkillSpecInstances [
	| params |
	params := ClaudeContainerParams fromJson: (Dictionary newFromPairs: { 'skills'. (Array
		with: (Dictionary newFromPairs: { 'skill_id'. 'sk_1'. 'type'. 'custom' })
		with: (Dictionary newFromPairs: { 'skill_id'. 'sk_2'. 'type'. 'anthropic' })) }).
	self assert: params skills size equals: 2.
	params skills do: [ :s | self assert: (s isKindOf: ClaudeSkillSpec) ]
]
