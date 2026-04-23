"
Tests for ClaudeTurn construction, accessors, JSON round-trip, and STON round-trip.
"
Class {
	#name : 'ClaudeTurnTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeTurnTest >> testAsJson [
	| turn json |
	turn := ClaudeTurn new.
	turn role: 'assistant'.
	turn content: { ClaudeTextBlock text: 'hi' } asOrderedCollection.
	turn model: 'claude-sonnet-4-20250514'.
	json := turn asJson.
	self assert: (json at: 'role') equals: 'assistant'.
	self assert: (json at: 'role') isString.
	self assert: (json at: 'model') equals: 'claude-sonnet-4-20250514'.
	self assert: (json at: 'content') size equals: 1
]

{ #category : 'tests' }
ClaudeTurnTest >> testAsParam [
	| turn param |
	turn := ClaudeTurn role: 'assistant' content: { ClaudeTextBlock text: 'hi' }.
	param := turn asParam.
	self assert: (param at: 'role') equals: 'assistant'.
	self assert: (param at: 'role') isString.
	self assert: (param at: 'content') size equals: 1.
	self assert: ((param at: 'content') first at: 'type') equals: 'text'
]

{ #category : 'tests' }
ClaudeTurnTest >> testConstruction [
	| turn |
	turn := ClaudeTurn new.
	turn role: 'assistant'.
	turn content: { ClaudeTextBlock text: 'hello' } asOrderedCollection.
	turn model: 'claude-sonnet-4-20250514'.
	self assert: turn role equals: #assistant.
	self assert: turn content size equals: 1.
	self assert: turn model equals: 'claude-sonnet-4-20250514'
]

{ #category : 'tests' }
ClaudeTurnTest >> testFactoryMethod [
	| turn |
	turn := ClaudeTurn role: 'user' content: { ClaudeTextBlock text: 'hi' }.
	self assert: turn role equals: #user.
	self assert: turn content size equals: 1.
	self assert: turn content first text equals: 'hi'
]

{ #category : 'tests' }
ClaudeTurnTest >> testFromJson [
	| json turn |
	json := Dictionary new.
	json at: 'role' put: 'assistant'.
	json at: 'content' put: {
		Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hello' } }.
	json at: 'model' put: 'claude-sonnet-4-20250514'.
	turn := ClaudeTurn fromJson: json.
	self assert: turn role equals: #assistant.
	self assert: turn content size equals: 1.
	self assert: turn content first isTextBlock.
	self assert: turn content first text equals: 'hello'.
	self assert: turn model equals: 'claude-sonnet-4-20250514'
]

{ #category : 'tests' }
ClaudeTurnTest >> testFromJsonContentIsOrderedCollection [
	| json turn |
	json := Dictionary new.
	json at: 'role' put: 'assistant'.
	json at: 'content' put: {
		Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hello' } }.
	turn := ClaudeTurn fromJson: json.
	self assert: (turn content isKindOf: OrderedCollection)
]

{ #category : 'tests' }
ClaudeTurnTest >> testJsonRoundTrip [
	| original json restored |
	original := ClaudeTurn new.
	original role: 'assistant'.
	original content: { ClaudeTextBlock text: 'hello' } asOrderedCollection.
	original model: 'claude-sonnet-4-20250514'.
	json := original asJson.
	restored := ClaudeTurn fromJson: json.
	self assert: restored role equals: original role.
	self assert: restored content size equals: original content size.
	self assert: restored content first text equals: original content first text.
	self assert: restored model equals: original model
]

{ #category : 'tests' }
ClaudeTurnTest >> testStonRoundTrip [
	| original ston restored |
	original := ClaudeTurn new.
	original role: 'assistant'.
	original content: { ClaudeTextBlock text: 'hello' } asOrderedCollection.
	original model: 'claude-sonnet-4-20250514'.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored role equals: #assistant.
	self assert: restored content size equals: 1.
	self assert: restored content first text equals: 'hello'.
	self assert: restored model equals: 'claude-sonnet-4-20250514'
]

{ #category : 'tests' }
ClaudeTurnTest >> testTextContent [
	| turn |
	turn := ClaudeTurn role: 'assistant' content: {
		ClaudeTextBlock text: 'hello'.
		ClaudeTextBlock text: 'world' }.
	self assert: (turn textContent includesSubstring: 'hello').
	self assert: (turn textContent includesSubstring: 'world')
]

{ #category : 'tests' }
ClaudeTurnTest >> testTextContentEmpty [
	| turn |
	turn := ClaudeTurn new.
	turn content: nil.
	self assert: turn textContent equals: ''
]

{ #category : 'tests' }
ClaudeTurnTest >> testToolUseBlocks [
	| turn |
	turn := ClaudeTurn role: 'assistant' content: {
		ClaudeTextBlock text: 'thinking...'.
		ClaudeToolUseBlock id: 'tu_1' name: 'get_weather' input: (Dictionary newFromPairs: { 'city'. 'NYC' }) }.
	self assert: turn toolUseBlocks size equals: 1.
	self assert: turn toolUseBlocks first name equals: 'get_weather'
]

{ #category : 'tests' }
ClaudeTurnTest >> testToolUseBlocksNilContent [
	| turn |
	turn := ClaudeTurn new.
	self assert: turn toolUseBlocks isEmpty
]
