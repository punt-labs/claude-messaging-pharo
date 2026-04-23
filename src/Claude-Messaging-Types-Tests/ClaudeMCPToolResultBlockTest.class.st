"
Tests for ClaudeMCPToolResultBlock content union (string vs text block array) and round-trip fidelity.

  ClaudeMCPToolResultBlockTest buildSuite run
  >>> 9 ran, 9 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected


"
Class {
	#name : 'ClaudeMCPToolResultBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'fixtures' }
ClaudeMCPToolResultBlockTest >> mcpResultFixtureWithArrayContent [
	^ Dictionary newFromPairs: {
		'type'. 'mcp_tool_result'.
		'tool_use_id'. 'mcp_use_001'.
		'is_error'. false.
		'content'. {
			Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'first' }.
			Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'second' } } }
]

{ #category : 'fixtures' }
ClaudeMCPToolResultBlockTest >> mcpResultFixtureWithStringContent [
	^ Dictionary newFromPairs: {
		'type'. 'mcp_tool_result'.
		'tool_use_id'. 'mcp_use_001'.
		'is_error'. false.
		'content'. 'hello world' }
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testAsJsonRequiresToolUseId [
	"tool_use_id is required by the wire — silently emitting null would corrupt the
	round-trip back to the originating mcp_tool_use block. Guard raises explicitly."
	| block |
	block := ClaudeMCPToolResultBlock new.
	block content: 'ok'.
	self should: [ block asJson ] raise: Error
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testAsJsonStringContentRoundtripsAsString [
	| block dict |
	block := ClaudeMCPToolResultBlock fromJson: self mcpResultFixtureWithStringContent.
	dict := block asJson.
	self assert: (dict at: 'content') equals: 'hello world'.
	self assert: (dict at: 'content') isString
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testAsJsonTextBlockArrayContentRoundtripsAsArray [
	| block dict content |
	block := ClaudeMCPToolResultBlock fromJson: self mcpResultFixtureWithArrayContent.
	dict := block asJson.
	content := dict at: 'content'.
	self assert: content isArray.
	self assert: content size equals: 2.
	self assert: (content first at: 'type') equals: 'text'.
	self assert: (content first at: 'text') equals: 'first'
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testFromJsonArrayContentBecomesOrderedCollectionOfTextBlocks [
	| block |
	block := ClaudeMCPToolResultBlock fromJson: self mcpResultFixtureWithArrayContent.
	self assert: (block content isKindOf: OrderedCollection).
	self assert: block content size equals: 2.
	block content do: [ :b | self assert: (b isKindOf: ClaudeTextBlock) ].
	self assert: block content first text equals: 'first'.
	self assert: block content second text equals: 'second'
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testFromJsonStringContentStaysString [
	| block |
	block := ClaudeMCPToolResultBlock fromJson: self mcpResultFixtureWithStringContent.
	self assert: block content equals: 'hello world'.
	self assert: block content isString
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testIsMCPToolResultBlock [
	self assert: ClaudeMCPToolResultBlock new isMCPToolResultBlock.
	self deny: ClaudeTextBlock new isMCPToolResultBlock
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testRoundtripPreservesIsError [
	| block dict restored |
	block := ClaudeMCPToolResultBlock new.
	block toolUseId: 'mcp_use_x'.
	block isError: true.
	block content: 'oops'.
	dict := block asJson.
	restored := ClaudeMCPToolResultBlock fromJson: dict.
	self assert: restored isError equals: true
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testTypeIsMcpToolResult [
	self assert: ClaudeMCPToolResultBlock new type equals: 'mcp_tool_result'
]

{ #category : 'tests' }
ClaudeMCPToolResultBlockTest >> testTypeRegistryDispatchesToThisClass [
	| block |
	block := ClaudeContentBlock fromJson: self mcpResultFixtureWithStringContent.
	self assert: block class equals: ClaudeMCPToolResultBlock.
	self assert: block isMCPToolResultBlock
]
