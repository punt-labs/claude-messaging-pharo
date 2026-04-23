"
Tests for ClaudeModel factory methods.
"
Class {
	#name : 'ClaudeModelTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeModelTest >> testHaiku35 [
	self assert: ClaudeModel haiku35 equals: 'claude-3-haiku-20240307'
]

{ #category : 'tests' }
ClaudeModelTest >> testHaiku45 [
	self assert: ClaudeModel haiku45 equals: 'claude-haiku-4-5-20251001'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus4 [
	self assert: ClaudeModel opus4 equals: 'claude-opus-4-20250514'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus46 [
	self assert: ClaudeModel opus46 equals: 'claude-opus-4-6'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus46v [
	self assert: ClaudeModel opus46v equals: 'claude-opus-4-6'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus47 [
	self assert: ClaudeModel opus47 equals: 'claude-opus-4-7'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus47v [
	self assert: ClaudeModel opus47v equals: 'claude-opus-4-7'
]

{ #category : 'tests' }
ClaudeModelTest >> testOpus4v [
	self assert: ClaudeModel opus4v equals: 'claude-opus-4-20250514'
]

{ #category : 'tests' }
ClaudeModelTest >> testSonnet45 [
	self assert: ClaudeModel sonnet45 equals: 'claude-sonnet-4-5-20250929'
]

{ #category : 'tests' }
ClaudeModelTest >> testSonnet45v [
	self assert: ClaudeModel sonnet45v equals: 'claude-sonnet-4-5-20250929'
]

{ #category : 'tests' }
ClaudeModelTest >> testSonnet46 [
	self assert: ClaudeModel sonnet46 equals: 'claude-sonnet-4-6'
]
