"
Tests for ClaudeSkillVersionPage (Claude-Messaging-Skills package).

  ClaudeSkillVersionPageTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillVersionPageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'fixtures' }
ClaudeSkillVersionPageTest >> newFullPage [
	| dict vDict |
	vDict := Dictionary new.
	vDict at: 'id' put: '1759'.
	vDict at: 'created_at' put: '2026-04-19T12:00:00Z'.
	vDict at: 'description' put: 'd'.
	vDict at: 'directory' put: 'my-skill'.
	vDict at: 'name' put: 'my-skill'.
	vDict at: 'skill_id' put: 'sk_abc'.
	vDict at: 'type' put: 'skill_version'.
	vDict at: 'version' put: '1759'.
	dict := Dictionary new.
	dict at: 'data' put: { vDict }.
	dict at: 'next_page' put: 'tok_v'.
	^ ClaudeSkillVersionPage fromJson: dict
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testEmptyPageHasNoData [
	self assert: ClaudeSkillVersionPage new data isEmpty
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testEmptyPageHasNoMore [
	self deny: ClaudeSkillVersionPage new hasMore
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testFromJsonAcceptsMissingNextPage [
	| page |
	page := ClaudeSkillVersionPage fromJson: (Dictionary newFromPairs: { 'data'. Array new }).
	self assert: page nextPage isNil.
	self deny: page hasMore
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testFromJsonParsesDataIntoClaudeSkillVersionInstances [
	| page |
	page := self newFullPage.
	self assert: page data size equals: 1.
	self assert: (page data first isKindOf: ClaudeSkillVersion).
	self assert: page data first skillId equals: 'sk_abc'
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testPageWithNextPageHasMore [
	self assert: (ClaudeSkillVersionPage new nextPage: 'tok'; yourself) hasMore
]

{ #category : 'tests' }
ClaudeSkillVersionPageTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := self newFullPage.
	restored := ClaudeSkillVersionPage fromJson: original asJson.
	self assert: restored data size equals: 1.
	self assert: restored data first version equals: '1759'.
	self assert: restored nextPage equals: 'tok_v'
]
