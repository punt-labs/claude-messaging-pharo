"
Round-trip tests for STON serialization on Claude-SDK-Types content blocks. Each test serializes via STON toString:, deserializes via STON fromString:, and asserts both the value and the class of the result. Stage 1 of bead 9kz (workbench conversation persistence).
"
Class {
	#name : 'ClaudeMessageStonTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageStonTest >> testClaudeMessageRoundTrip [
	| original ston restored |
	original := ClaudeMessage new
		id: 'msg_001';
		role: #assistant;
		content: (OrderedCollection new add: (ClaudeTextBlock text: 'Hello world'); yourself);
		model: 'claude-opus-4-6';
		stopReason: #end_turn;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeMessage.
	self assert: restored id equals: 'msg_001'.
	self assert: restored role equals: #assistant.
	self assert: restored model equals: 'claude-opus-4-6'.
	self assert: restored stopReason equals: #end_turn.
	self assert: restored content size equals: 1.
	self assert: restored content first class equals: ClaudeTextBlock.
	self assert: restored content first text equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testHeterogeneousMessageContentRoundTrip [
	| textBlock toolUseBlock original ston restored |
	textBlock := ClaudeTextBlock text: 'I will use a tool'.
	toolUseBlock := ClaudeToolUseBlock new
		id: 'toolu_xyz';
		name: 'BrowseClass';
		input: (Dictionary new at: 'className' put: 'Object'; yourself);
		yourself.
	original := ClaudeMessage new
		role: #assistant;
		content: (OrderedCollection new add: textBlock; add: toolUseBlock; yourself);
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeMessage.
	self assert: restored content size equals: 2.
	self assert: restored content first class equals: ClaudeTextBlock.
	self assert: restored content first text equals: 'I will use a tool'.
	self assert: restored content second class equals: ClaudeToolUseBlock.
	self assert: restored content second id equals: 'toolu_xyz'.
	self assert: restored content second name equals: 'BrowseClass'.
	self assert: (restored content second input at: 'className') equals: 'Object'
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testImageBlockLargeBase64RoundTrip [
	| largeData alphabet original ston restored |
	alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	largeData := String streamContents: [ :s |
		1 to: 102400 do: [ :i |
			s nextPut: (alphabet at: ((i rem: 64) + 1)) ] ].
	self assert: largeData size equals: 102400.
	original := ClaudeImageBlock new
		source: (OrderedDictionary new
			at: 'type' put: 'base64';
			at: 'media_type' put: 'image/png';
			at: 'data' put: largeData;
			yourself);
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeImageBlock.
	self assert: (restored source at: 'data') size equals: 102400.
	self assert: (restored source at: 'data') equals: largeData
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testImageBlockRoundTrip [
	| original ston restored |
	original := ClaudeImageBlock new
		source: (OrderedDictionary new
			at: 'type' put: 'base64';
			at: 'media_type' put: 'image/png';
			at: 'data' put: 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
			yourself);
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeImageBlock.
	self assert: (restored source at: 'type') equals: 'base64'.
	self assert: (restored source at: 'media_type') equals: 'image/png'.
	self assert: (restored source at: 'data') size equals: (original source at: 'data') size
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testMessageWithUsageRoundTrip [
	| original ston restored |
	original := ClaudeMessage new
		role: #assistant;
		content: (OrderedCollection new add: (ClaudeTextBlock text: 'hi'); yourself);
		usage: (ClaudeUsage new
			inputTokens: 100;
			outputTokens: 250;
			cacheCreationInputTokens: 50;
			cacheReadInputTokens: 25;
			yourself);
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeMessage.
	self assert: restored usage class equals: ClaudeUsage.
	self assert: restored usage inputTokens equals: 100.
	self assert: restored usage outputTokens equals: 250.
	self assert: restored usage cacheCreationInputTokens equals: 50.
	self assert: restored usage cacheReadInputTokens equals: 25
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testRedactedThinkingBlockRoundTrip [
	| originalData original ston restored |
	originalData := 'ENC[redacted_payload_xyz==/+]'.
	original := ClaudeRedactedThinkingBlock new
		data: originalData;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeRedactedThinkingBlock.
	self assert: restored data equals: originalData.
	self assert: restored data size equals: originalData size
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testRoleAndStopReasonAreSymbols [
	| original ston restored |
	original := ClaudeMessage new
		role: #user;
		content: (OrderedCollection new add: (ClaudeTextBlock text: 'hello'); yourself);
		stopReason: #end_turn;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored role isSymbol description: 'role must be a Symbol after round-trip'.
	self assert: restored stopReason isSymbol description: 'stopReason must be a Symbol after round-trip'.
	self assert: restored role equals: #user.
	self assert: restored stopReason equals: #end_turn
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testServerToolUseBlockRoundTrip [
	| original raw ston restored |
	raw := Dictionary new.
	raw at: 'type' put: 'server_tool_use'.
	raw at: 'id' put: 'srv_tool_001'.
	raw at: 'name' put: 'web_search'.
	raw at: 'input' put: (Dictionary new at: 'query' put: 'Pharo'; yourself).
	original := ClaudeServerToolUseBlock new
		rawJson: raw;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeServerToolUseBlock.
	self assert: (restored rawJson at: 'id') equals: 'srv_tool_001'.
	self assert: (restored rawJson at: 'name') equals: 'web_search'.
	self assert: ((restored rawJson at: 'input') at: 'query') equals: 'Pharo'
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testTextBlockRoundTrip [
	| original ston restored |
	original := ClaudeTextBlock text: 'hello world'.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeTextBlock.
	self assert: restored text equals: 'hello world'.
	self assert: restored citations equals: nil
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testTextBlockWithCitationsRoundTrip [
	| original citation ston restored |
	citation := ClaudeCitation new
		citedText: 'cited fragment';
		documentTitle: 'Doc1';
		documentIndex: 0;
		startCharIndex: 10;
		endCharIndex: 24;
		yourself.
	original := ClaudeTextBlock new
		text: 'The body';
		citations: { citation };
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeTextBlock.
	self assert: restored text equals: 'The body'.
	self assert: restored citations size equals: 1.
	self assert: restored citations first citedText equals: 'cited fragment'
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testThinkingBlockRoundTrip [
	| original ston restored |
	original := ClaudeThinkingBlock new
		thinking: 'Let me think about this...';
		signature: 'sig_abc123xyz';
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeThinkingBlock.
	self assert: restored thinking equals: 'Let me think about this...'.
	self assert: restored signature notNil.
	self assert: restored signature isNotEmpty
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testThinkingBlockSignaturePreservedVerbatim [
	| originalSig original ston restored |
	originalSig := 'ABCdef123+/=ZyXw==signature_with_special_chars!@#$'.
	original := ClaudeThinkingBlock new
		thinking: 'chain of thought';
		signature: originalSig;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored signature equals: originalSig.
	self assert: restored signature size equals: originalSig size.
	1 to: originalSig size do: [ :i |
		self assert: (restored signature at: i) equals: (originalSig at: i) ]
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testToolResultBlockContentPolymorphism [
	| stringContent collectionContent stringRestored collectionRestored block |
	stringContent := ClaudeToolResultBlock new
		toolUseId: 'toolu_str';
		content: 'plain string content';
		yourself.
	stringRestored := STON fromString: (STON toString: stringContent).
	self assert: stringRestored class equals: ClaudeToolResultBlock.
	self assert: stringRestored content isString.
	self assert: stringRestored content equals: 'plain string content'.

	block := ClaudeTextBlock text: 'nested text'.
	collectionContent := ClaudeToolResultBlock new
		toolUseId: 'toolu_coll';
		content: (OrderedCollection new add: block; yourself);
		yourself.
	collectionRestored := STON fromString: (STON toString: collectionContent).
	self assert: collectionRestored class equals: ClaudeToolResultBlock.
	self deny: collectionRestored content isString.
	self assert: collectionRestored content size equals: 1.
	self assert: collectionRestored content first class equals: ClaudeTextBlock.
	self assert: collectionRestored content first text equals: 'nested text'
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testToolResultBlockRoundTrip [
	| original ston restored |
	original := ClaudeToolResultBlock new
		toolUseId: 'toolu_01abc';
		content: 'Result text';
		isError: true;
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeToolResultBlock.
	self assert: restored toolUseId equals: 'toolu_01abc'.
	self assert: restored content equals: 'Result text'.
	self assert: restored isError equals: true
]

{ #category : 'tests' }
ClaudeMessageStonTest >> testToolUseBlockRoundTrip [
	| original ston restored |
	original := ClaudeToolUseBlock new
		id: 'toolu_01abc';
		name: 'BrowseClass';
		input: (Dictionary new at: 'className' put: 'ClaudeMessage'; yourself);
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored class equals: ClaudeToolUseBlock.
	self assert: restored id equals: 'toolu_01abc'.
	self assert: restored name equals: 'BrowseClass'.
	self assert: (restored input at: 'className') equals: 'ClaudeMessage'
]
