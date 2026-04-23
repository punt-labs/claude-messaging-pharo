"
Tests for ClaudeMessageTokensCount JSON serialization and round-trip. Verifies parsing from the count_tokens API response and correct snake_case wire format.
"
Class {
	#name : 'ClaudeMessageTokensCountTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageTokensCountTest >> testAsJson [
	| count json |
	count := ClaudeMessageTokensCount new.
	count inputTokens: 99.
	json := count asJson.
	self assert: (json at: 'input_tokens') equals: 99
]

{ #category : 'tests' }
ClaudeMessageTokensCountTest >> testFromJson [
	| result |
	result := ClaudeMessageTokensCount fromJson: (Dictionary newFromPairs: { 'input_tokens'. 42 }).
	self assert: result inputTokens equals: 42
]

{ #category : 'tests' }
ClaudeMessageTokensCountTest >> testJsonRoundTrip [
	| original restored |
	original := ClaudeMessageTokensCount new.
	original inputTokens: 77.
	restored := ClaudeMessageTokensCount fromJson: original asJson.
	self assert: restored inputTokens equals: original inputTokens
]
