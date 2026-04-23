"
Tests for ClaudeModelInfo JSON serialization, accessors, and round-trip. Verifies snake_case wire format, nil omission for optional fields, and jsonKeyMap completeness.
"
Class {
	#name : 'ClaudeModelInfoTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeModelInfoTest >> testAsJson [
	| info json |
	info := ClaudeModelInfo new.
	info id: 'claude-opus-4-0'.
	info displayName: 'Claude 4 Opus'.
	info maxInputTokens: 200000.
	info maxTokens: 4096.
	info type: 'model'.
	info createdAt: '2025-03-01T00:00:00Z'.
	json := info asJson.
	self assert: (json at: 'id') equals: 'claude-opus-4-0'.
	self assert: (json at: 'display_name') equals: 'Claude 4 Opus'.
	self assert: (json at: 'max_input_tokens') equals: 200000.
	self assert: (json at: 'max_tokens') equals: 4096.
	self assert: (json at: 'type') equals: 'model'.
	self assert: (json at: 'created_at') equals: '2025-03-01T00:00:00Z'
]

{ #category : 'tests' }
ClaudeModelInfoTest >> testFromJson [
	| json info |
	json := Dictionary new.
	json at: 'id' put: 'claude-sonnet-4-5'.
	json at: 'display_name' put: 'Claude 3.5 Sonnet'.
	json at: 'max_input_tokens' put: 200000.
	json at: 'max_tokens' put: 8192.
	json at: 'type' put: 'model'.
	json at: 'created_at' put: '2025-01-01T00:00:00Z'.
	info := ClaudeModelInfo fromJson: json.
	self assert: info id equals: 'claude-sonnet-4-5'.
	self assert: info displayName equals: 'Claude 3.5 Sonnet'.
	self assert: info maxInputTokens equals: 200000.
	self assert: info maxTokens equals: 8192.
	self assert: info type equals: 'model'.
	self assert: info createdAt equals: '2025-01-01T00:00:00Z'
]

{ #category : 'tests' }
ClaudeModelInfoTest >> testJsonKeyMap [
	| map |
	map := ClaudeModelInfo jsonKeyMap.
	self assert: (map at: #displayName) equals: 'display_name'.
	self assert: (map at: #maxInputTokens) equals: 'max_input_tokens'.
	self assert: (map at: #maxTokens) equals: 'max_tokens'.
	self assert: (map at: #createdAt) equals: 'created_at'.
	self assert: map size equals: 4
]

{ #category : 'tests' }
ClaudeModelInfoTest >> testJsonRoundTrip [
	| original restored |
	original := ClaudeModelInfo new.
	original id: 'claude-sonnet-4-5'.
	original displayName: 'Claude 3.5 Sonnet'.
	original maxInputTokens: 200000.
	original maxTokens: 8192.
	original type: 'model'.
	original createdAt: '2025-01-01T00:00:00Z'.
	restored := ClaudeModelInfo fromJson: original asJson.
	self assert: restored id equals: original id.
	self assert: restored displayName equals: original displayName.
	self assert: restored maxInputTokens equals: original maxInputTokens.
	self assert: restored maxTokens equals: original maxTokens.
	self assert: restored type equals: original type.
	self assert: restored createdAt equals: original createdAt
]

{ #category : 'tests' }
ClaudeModelInfoTest >> testNilOmission [
	| info json |
	info := ClaudeModelInfo new.
	info id: 'claude-sonnet-4-5'.
	info type: 'model'.
	json := info asJson.
	self assert: (json includesKey: 'id').
	self assert: (json includesKey: 'type').
	self deny: (json includesKey: 'display_name').
	self deny: (json includesKey: 'max_input_tokens').
	self deny: (json includesKey: 'max_tokens').
	self deny: (json includesKey: 'created_at')
]
