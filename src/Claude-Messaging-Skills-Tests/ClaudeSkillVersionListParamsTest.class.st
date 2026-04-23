"
Tests for ClaudeSkillVersionListParams (Claude-Messaging-Skills package).

  ClaudeSkillVersionListParamsTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillVersionListParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'tests' }
ClaudeSkillVersionListParamsTest >> testBothFieldsSerialize [
	| q |
	q := (ClaudeSkillVersionListParams new page: 'tok'; limit: 25; yourself) asQueryParams.
	self assert: q size equals: 2.
	self assert: (q at: 'page') equals: 'tok'.
	self assert: (q at: 'limit') equals: '25'
]

{ #category : 'tests' }
ClaudeSkillVersionListParamsTest >> testEmptyParamsHaveEmptyQuery [
	self assert: ClaudeSkillVersionListParams new asQueryParams isEmpty
]

{ #category : 'tests' }
ClaudeSkillVersionListParamsTest >> testLimitSerializedAsString [
	| q |
	q := (ClaudeSkillVersionListParams new limit: 50; yourself) asQueryParams.
	self assert: (q at: 'limit') equals: '50'
]

{ #category : 'tests' }
ClaudeSkillVersionListParamsTest >> testNoSourceField [
	"Guard against drift toward the Files-API shape: version listing has no source filter."
	| q |
	q := (ClaudeSkillVersionListParams new page: 'tok'; limit: 25; yourself) asQueryParams.
	self deny: (q keys includes: 'source')
]

{ #category : 'tests' }
ClaudeSkillVersionListParamsTest >> testPageOnlySerializesPage [
	| q |
	q := (ClaudeSkillVersionListParams new page: 'tok'; yourself) asQueryParams.
	self assert: q size equals: 1.
	self assert: (q at: 'page') equals: 'tok'
]
