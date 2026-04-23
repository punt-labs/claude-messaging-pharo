"
Query parameters for listing skill versions via ClaudeClient listVersionsFor: / listVersionsFor:params:. Same page-token pagination as ClaudeSkillListParams, but without source (versions don't have a source -- they belong to a parent skill which carries the source).

  (ClaudeSkillVersionListParams new page: 'tok_abc'; limit: 50; yourself) asQueryParams size
  >>> 2

  ClaudeSkillVersionListParams new asQueryParams isEmpty
  >>> true

"
Class {
	#name : 'ClaudeSkillVersionListParams',
	#superclass : 'Object',
	#instVars : [
		'page',
		'limit'
	],
	#category : 'Claude-Messaging-Skills',
	#package : 'Claude-Messaging-Skills'
}

{ #category : 'json' }
ClaudeSkillVersionListParams class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'converting' }
ClaudeSkillVersionListParams >> asQueryParams [
	| params |
	params := Dictionary new.
	page ifNotNil: [ params at: 'page' put: page ].
	limit ifNotNil: [ params at: 'limit' put: limit printString ].
	^ params
]

{ #category : 'accessing' }
ClaudeSkillVersionListParams >> limit [
	^ limit
]

{ #category : 'accessing' }
ClaudeSkillVersionListParams >> limit: anInteger [
	limit := anInteger
]

{ #category : 'accessing' }
ClaudeSkillVersionListParams >> page [
	^ page
]

{ #category : 'accessing' }
ClaudeSkillVersionListParams >> page: aString [
	page := aString
]

{ #category : 'printing' }
ClaudeSkillVersionListParams >> printOn: aStream [
	aStream nextPutAll: 'ClaudeSkillVersionListParams('.
	page ifNotNil: [ aStream nextPutAll: 'page: '; nextPutAll: page; nextPut: $  ].
	limit ifNotNil: [ aStream nextPutAll: 'limit: '; print: limit ].
	aStream nextPut: $)
]
