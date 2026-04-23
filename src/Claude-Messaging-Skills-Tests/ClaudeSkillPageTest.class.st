"
Tests for ClaudeSkillPage (Claude-Messaging-Skills package).

  ClaudeSkillPageTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeSkillPageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'fixtures' }
ClaudeSkillPageTest >> newFullPage [
	| dict skillDict |
	skillDict := Dictionary new.
	skillDict at: 'id' put: 'sk_1'.
	skillDict at: 'created_at' put: '2026-04-19T12:00:00Z'.
	skillDict at: 'display_title' put: 'S1'.
	skillDict at: 'latest_version' put: 'v1'.
	skillDict at: 'source' put: 'custom'.
	skillDict at: 'type' put: 'skill'.
	skillDict at: 'updated_at' put: '2026-04-19T12:00:00Z'.
	dict := Dictionary new.
	dict at: 'data' put: { skillDict }.
	dict at: 'next_page' put: 'tok_xyz'.
	^ ClaudeSkillPage fromJson: dict
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testAsJsonEmitsEmptyDataArrayWhenDataIsEmpty [
	| dict |
	dict := ClaudeSkillPage new asJson.
	self assert: (dict at: 'data') isEmpty.
	self assert: (dict at: 'data') class equals: Array
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testEmptyPageHasNoData [
	self assert: ClaudeSkillPage new data isEmpty
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testEmptyPageHasNoMore [
	self deny: ClaudeSkillPage new hasMore
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testFromJsonAcceptsMissingNextPage [
	| page |
	page := ClaudeSkillPage fromJson: (Dictionary newFromPairs: { 'data'. Array new }).
	self assert: page nextPage isNil.
	self deny: page hasMore
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testFromJsonParsesDataIntoClaudeSkillInstances [
	| page |
	page := self newFullPage.
	self assert: page data size equals: 1.
	self assert: (page data first isKindOf: ClaudeSkill).
	self assert: page data first id equals: 'sk_1'
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testFromJsonReadsNextPageWhenPresent [
	| page |
	page := self newFullPage.
	self assert: page nextPage equals: 'tok_xyz'.
	self assert: page hasMore
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testPageWithNextPageHasMore [
	self assert: (ClaudeSkillPage new nextPage: 'tok'; yourself) hasMore
]

{ #category : 'tests' }
ClaudeSkillPageTest >> testRoundtripThroughAsJsonAndFromJson [
	| original restored |
	original := self newFullPage.
	restored := ClaudeSkillPage fromJson: original asJson.
	self assert: restored data size equals: 1.
	self assert: restored data first id equals: 'sk_1'.
	self assert: restored nextPage equals: 'tok_xyz'
]
