"
Tests for ClaudeSkillListParams (Claude-Messaging-Skills package).

  ClaudeSkillListParamsTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillListParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'tests' }
ClaudeSkillListParamsTest >> testAllThreeFieldsSerialize [
	| q |
	q := (ClaudeSkillListParams new page: 'tok'; source: 'anthropic'; limit: 10; yourself) asQueryParams.
	self assert: q size equals: 3.
	self assert: (q at: 'page') equals: 'tok'.
	self assert: (q at: 'source') equals: 'anthropic'.
	self assert: (q at: 'limit') equals: '10'
]

{ #category : 'tests' }
ClaudeSkillListParamsTest >> testEmptyParamsHaveEmptyQuery [
	self assert: ClaudeSkillListParams new asQueryParams isEmpty
]

{ #category : 'tests' }
ClaudeSkillListParamsTest >> testLimitSerializedAsString [
	| q |
	q := (ClaudeSkillListParams new limit: 50; yourself) asQueryParams.
	self assert: (q at: 'limit') equals: '50'.
	self assert: (q at: 'limit') isString
]

{ #category : 'tests' }
ClaudeSkillListParamsTest >> testPageOnlySerializesPage [
	| q |
	q := (ClaudeSkillListParams new page: 'tok'; yourself) asQueryParams.
	self assert: q size equals: 1.
	self assert: (q at: 'page') equals: 'tok'
]

{ #category : 'tests' }
ClaudeSkillListParamsTest >> testSourceOnlySerializesSource [
	| q |
	q := (ClaudeSkillListParams new source: 'custom'; yourself) asQueryParams.
	self assert: q size equals: 1.
	self assert: (q at: 'source') equals: 'custom'
]
