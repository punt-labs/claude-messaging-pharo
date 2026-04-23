"
Tests for ClaudeMCPToolUseBlock JSON dispatch and field preservation.

  ClaudeMCPToolUseBlockTest buildSuite run
  >>> 11 ran, 11 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected



"
Class {
	#name : 'ClaudeMCPToolUseBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'fixtures' }
ClaudeMCPToolUseBlockTest >> mcpToolUseFixture [
	^ Dictionary newFromPairs: {
		'type'. 'mcp_tool_use'.
		'id'. 'mcp_use_001'.
		'name'. 'echo'.
		'server_name'. 'example'.
		'input'. (Dictionary newFromPairs: { 'message'. 'hello' }) }
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testApplyDeltaAccumulatesPartialJson [
	"applyDelta: accumulates input_json_delta partial_json fragments into a
	String. After finalizeAfterStreaming the accumulated String parses into
	a Dictionary. Mirrors ClaudeToolUseBlock streaming behavior."
	| block |
	block := ClaudeMCPToolUseBlock new.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'input_json_delta'. 'partial_json'. '{"a":' }).
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'input_json_delta'. 'partial_json'. '1}' }).
	self assert: block input equals: '{"a":1}'.
	block finalizeAfterStreaming.
	self assert: block input isDictionary.
	self assert: (block input at: 'a') equals: 1 
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testAsJsonHandlesNilOrEmptyInput [
	"A freshly constructed block (no fromJson:) defaults input to an empty Dictionary,
	so asJson emits a valid empty input object rather than null. Anthropic's API rejects
	null for the required input field."
	| block dict |
	block := ClaudeMCPToolUseBlock new.
	dict := block asJson.
	self assert: (dict includesKey: 'input').
	self assert: (dict at: 'input') isDictionary.
	self assert: (dict at: 'input') isEmpty
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testFromJsonMissingInputDefaultsToEmptyDictionary [
	"When the wire dict omits input (or carries an explicit null), fromJson:
	must default to an empty Dictionary so asJson emits a valid empty input
	object rather than null. Anthropic rejects null for the required input field."
	| missingBlock nilBlock |
	missingBlock := ClaudeMCPToolUseBlock fromJson: (Dictionary newFromPairs: {
		'type'. 'mcp_tool_use'.
		'id'. 'id1'.
		'name'. 'nm'.
		'server_name'. 'sv' }).
	self assert: missingBlock input isDictionary.
	self assert: missingBlock input isEmpty.
	self assert: (missingBlock asJson at: 'input') isDictionary.

	nilBlock := ClaudeMCPToolUseBlock fromJson: (Dictionary newFromPairs: {
		'type'. 'mcp_tool_use'.
		'id'. 'id1'.
		'name'. 'nm'.
		'server_name'. 'sv'.
		'input'. nil }).
	self assert: nilBlock input isDictionary.
	self assert: nilBlock input isEmpty.
	self assert: (nilBlock asJson at: 'input') isDictionary
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testFromJsonPreservesArbitraryInputDict [
	| block input |
	input := Dictionary newFromPairs: {
		'nested'. (Dictionary newFromPairs: { 'a'. 1. 'b'. 2 }).
		'array'. #(1 2 3) }.
	block := ClaudeMCPToolUseBlock fromJson: (Dictionary newFromPairs: {
		'type'. 'mcp_tool_use'.
		'id'. 'id1'.
		'name'. 'nm'.
		'server_name'. 'sv'.
		'input'. input }).
	self assert: ((block input at: 'nested') at: 'a') equals: 1.
	self assert: (block input at: 'array') equals: #(1 2 3)
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testFromJsonReadsAllRequiredFields [
	| block |
	block := ClaudeMCPToolUseBlock fromJson: self mcpToolUseFixture.
	self assert: block id equals: 'mcp_use_001'.
	self assert: block name equals: 'echo'.
	self assert: block serverName equals: 'example'.
	self assert: (block input at: 'message') equals: 'hello'
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testIsMCPToolUseBlock [
	self assert: ClaudeMCPToolUseBlock new isMCPToolUseBlock.
	self deny: ClaudeTextBlock new isMCPToolUseBlock
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testRoundtripThroughAsJsonAndFromJson [
	| original dict restored |
	original := ClaudeMCPToolUseBlock fromJson: self mcpToolUseFixture.
	dict := original asJson.
	restored := ClaudeMCPToolUseBlock fromJson: dict.
	self assert: restored id equals: original id.
	self assert: restored name equals: original name.
	self assert: restored serverName equals: original serverName.
	self assert: (restored input at: 'message') equals: 'hello'
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testSetterGuardsAgainstNilInput [
	"Post-construction mutation must preserve the input-not-nil invariant:
	Anthropic rejects null on the required input field. The setter normalizes
	nil to an empty Dictionary so asJson cannot emit nullish input even after
	a caller assigns nil."
	| block |
	block := ClaudeMCPToolUseBlock fromJson: (Dictionary newFromPairs: {
		'type'. 'mcp_tool_use'.
		'id'. 'id1'.
		'name'. 'nm'.
		'server_name'. 'sv'.
		'input'. (Dictionary newFromPairs: { 'a'. 1 }) }).
	block input: nil.
	self assert: block input isDictionary.
	self assert: block input isEmpty.
	self assert: (block asJson at: 'input') isDictionary 
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testStreamingFinalizationParsesInput [
	"Full streaming pipeline through ClaudeMessage>>accumulate:: a
	content_block_start with mcp_tool_use, two content_block_delta events
	with input_json_delta, then content_block_stop. The block's input
	must be a parsed Dictionary after content_block_stop."
	| msg block |
	msg := ClaudeMessage new.
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_start';
		at: 'data' put: (Dictionary new
			at: 'message' put: (Dictionary new
				at: 'id' put: 'msg_1';
				at: 'type' put: 'message';
				at: 'role' put: 'assistant';
				at: 'model' put: 'claude';
				yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary newFromPairs: {
				'type'. 'mcp_tool_use'.
				'id'. 'mcp_use_1'.
				'name'. 'echo'.
				'server_name'. 'example' });
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'input_json_delta'; at: 'partial_json' put: '{"mes';yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'input_json_delta'; at: 'partial_json' put: 'sage":"hi"}';yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).
	block := msg content first.
	self assert: block class equals: ClaudeMCPToolUseBlock.
	self assert: block input isDictionary.
	self assert: (block input at: 'message') equals: 'hi' 
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testTypeIsMcpToolUse [
	self assert: ClaudeMCPToolUseBlock new type equals: 'mcp_tool_use'
]

{ #category : 'tests' }
ClaudeMCPToolUseBlockTest >> testTypeRegistryDispatchesToThisClass [
	| block |
	block := ClaudeContentBlock fromJson: self mcpToolUseFixture.
	self assert: block class equals: ClaudeMCPToolUseBlock.
	self assert: block isMCPToolUseBlock
]
