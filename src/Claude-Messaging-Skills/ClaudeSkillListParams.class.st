"
Query parameters for listing skills via ClaudeClient listSkills:. Skills uses page-token pagination (not cursor IDs like Files). page is the token from a previous response's nextPage. source filters to 'custom' or 'anthropic'. limit is 1-100 (default 20 server-side).

  (ClaudeSkillListParams new page: 'tok_abc'; source: 'custom'; limit: 50; yourself) asQueryParams size
  >>> 3

  ClaudeSkillListParams new asQueryParams isEmpty
  >>> true

"
Class {
	#name : 'ClaudeSkillListParams',
	#superclass : 'Object',
	#instVars : [
		'page',
		'source',
		'limit'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkillListParams class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'converting' }
ClaudeSkillListParams >> asQueryParams [
	| params |
	params := Dictionary new.
	page ifNotNil: [ params at: 'page' put: page ].
	source ifNotNil: [ params at: 'source' put: source ].
	limit ifNotNil: [ params at: 'limit' put: limit printString ].
	^ params
]

{ #category : 'accessing' }
ClaudeSkillListParams >> limit [
	^ limit
]

{ #category : 'accessing' }
ClaudeSkillListParams >> limit: anInteger [
	limit := anInteger
]

{ #category : 'accessing' }
ClaudeSkillListParams >> page [
	^ page
]

{ #category : 'accessing' }
ClaudeSkillListParams >> page: aString [
	page := aString
]

{ #category : 'printing' }
ClaudeSkillListParams >> printOn: aStream [
	aStream nextPutAll: 'ClaudeSkillListParams('.
	page ifNotNil: [ aStream nextPutAll: 'page: '; nextPutAll: page; nextPut: $  ].
	source ifNotNil: [ aStream nextPutAll: 'source: '; nextPutAll: source; nextPut: $  ].
	limit ifNotNil: [ aStream nextPutAll: 'limit: '; print: limit ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
ClaudeSkillListParams >> source [
	^ source
]

{ #category : 'accessing' }
ClaudeSkillListParams >> source: aString [
	source := aString
]
