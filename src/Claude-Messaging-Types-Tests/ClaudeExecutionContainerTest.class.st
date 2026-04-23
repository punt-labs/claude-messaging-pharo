"
Tests for ClaudeExecutionContainer construction, nested JSON parsing, and STON round-trip.
"
Class {
	#name : 'ClaudeExecutionContainerTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testAsJson [
	| ec json |
	ec := ClaudeExecutionContainer new.
	ec containerId: 'ctr_abc123'.
	ec expiresAt: '2026-04-18T12:00:00Z'.
	json := ec asJson.
	self assert: (json at: 'id') equals: 'ctr_abc123'.
	self assert: (json at: 'expires_at') equals: '2026-04-18T12:00:00Z'
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testAsJsonEmitsSkillsWhenSet [
	| ec dict |
	ec := ClaudeExecutionContainer new.
	ec containerId: 'ctr_x'.
	ec skills: { ClaudeSkillSpec skillId: 'sk_1' type: 'custom'. ClaudeSkillSpec skillId: 'sk_2' type: 'anthropic' }.
	dict := ec asJson.
	self assert: (dict at: 'skills') size equals: 2
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testAsJsonOmitsSkillsWhenEmpty [
	| ec dict |
	ec := ClaudeExecutionContainer new.
	ec containerId: 'ctr_x'.
	ec skills: OrderedCollection new.
	dict := ec asJson.
	self deny: (dict includesKey: 'skills')
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testConstruction [
	| ec |
	ec := ClaudeExecutionContainer new.
	ec containerId: 'ctr_abc123'.
	ec expiresAt: '2026-04-18T12:00:00Z'.
	self assert: ec containerId equals: 'ctr_abc123'.
	self assert: ec expiresAt equals: '2026-04-18T12:00:00Z'
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testFromJson [
	| json ec |
	json := Dictionary new.
	json at: 'container' put: (Dictionary newFromPairs: {
		'id'. 'ctr_abc123'.
		'expires_at'. '2026-04-18T12:00:00Z' }).
	ec := ClaudeExecutionContainer fromJson: json.
	self assert: ec containerId equals: 'ctr_abc123'.
	self assert: ec expiresAt equals: '2026-04-18T12:00:00Z'
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testFromJsonAcceptsMissingSkills [
	| outer ec |
	outer := Dictionary new.
	outer at: 'container' put: (Dictionary newFromPairs: { 'id'. 'ctr_x' }).
	ec := ClaudeExecutionContainer fromJson: outer.
	self assert: ec skills isNil
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testFromJsonNilContainer [
	| json ec |
	json := Dictionary new.
	ec := ClaudeExecutionContainer fromJson: json.
	self assert: ec isNil
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testFromJsonNilDict [
	self assert: (ClaudeExecutionContainer fromJson: nil) isNil
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testFromJsonParsesSkillsArrayIntoClaudeSkillSpecInstances [
	| outer ec |
	outer := Dictionary new.
	outer at: 'container' put: (Dictionary newFromPairs: {
		'id'. 'ctr_x'.
		'expires_at'. '2026-04-19T13:00:00Z'.
		'skills'. (Array
			with: (Dictionary newFromPairs: { 'skill_id'. 'sk_1'. 'type'. 'custom' })
			with: (Dictionary newFromPairs: { 'skill_id'. 'sk_2'. 'type'. 'anthropic' })) }).
	ec := ClaudeExecutionContainer fromJson: outer.
	self assert: ec skills size equals: 2.
	ec skills do: [ :s | self assert: (s isKindOf: ClaudeSkillSpec) ]
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testJsonRoundTrip [
	| original json restored |
	original := ClaudeExecutionContainer new.
	original containerId: 'ctr_abc123'.
	original expiresAt: '2026-04-18T12:00:00Z'.
	json := Dictionary new.
	json at: 'container' put: original asJson.
	restored := ClaudeExecutionContainer fromJson: json.
	self assert: restored containerId equals: original containerId.
	self assert: restored expiresAt equals: original expiresAt
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testStonRoundTrip [
	| original ston restored |
	original := ClaudeExecutionContainer new.
	original containerId: 'ctr_abc123'.
	original expiresAt: '2026-04-18T12:00:00Z'.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored containerId equals: 'ctr_abc123'.
	self assert: restored expiresAt equals: '2026-04-18T12:00:00Z'
]

{ #category : 'tests' }
ClaudeExecutionContainerTest >> testStonRoundtripPreservesSkills [
	| original ston restored |
	original := ClaudeExecutionContainer new.
	original containerId: 'ctr_x'.
	original skills: { ClaudeSkillSpec skillId: 'sk_1' type: 'custom' }.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored skills size equals: 1.
	self assert: restored skills first skillId equals: 'sk_1'
]
