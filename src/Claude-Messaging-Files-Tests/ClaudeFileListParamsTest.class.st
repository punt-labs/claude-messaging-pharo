"
Tests for ClaudeFileListParams query parameter conversion.
"
Class {
	#name : 'ClaudeFileListParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Files-Tests',
	#package : 'Claude-Messaging-Files-Tests'
}

{ #category : 'tests' }
ClaudeFileListParamsTest >> testAsQueryParamsAllSet [
	| p params |
	p := ClaudeFileListParams new.
	p afterId: 'file-abc'.
	p beforeId: 'file-xyz'.
	p limit: 50.
	params := p asQueryParams.
	self assert: params size equals: 3.
	self assert: (params at: 'after_id') equals: 'file-abc'.
	self assert: (params at: 'before_id') equals: 'file-xyz'.
	self assert: (params at: 'limit') equals: '50'
]

{ #category : 'tests' }
ClaudeFileListParamsTest >> testAsQueryParamsNoneSet [
	| p params |
	p := ClaudeFileListParams new.
	params := p asQueryParams.
	self assert: params isEmpty
]

{ #category : 'tests' }
ClaudeFileListParamsTest >> testAsQueryParamsOnlyAfterIdSet [
	| p params |
	p := ClaudeFileListParams new.
	p afterId: 'file-abc'.
	params := p asQueryParams.
	self assert: params size equals: 1.
	self assert: (params at: 'after_id') equals: 'file-abc'
]

{ #category : 'tests' }
ClaudeFileListParamsTest >> testLimitSerializesAsString [
	| p params |
	p := ClaudeFileListParams new.
	p limit: 100.
	params := p asQueryParams.
	self assert: (params at: 'limit') equals: '100'.
	self assert: (params at: 'limit') isString
]
