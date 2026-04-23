"
Tests for ClaudeContentBlock hierarchy — type dispatch, JSON serialization, helper constructors.
"
Class {
	#name : 'ClaudeContentBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeContentBlockTest >> testApplyDeltaDefaultIgnored [
	| block |
	block := ClaudeImageBlock new.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'unknown_delta' }).
	"Should not raise an error - default does nothing"
	self assert: block type equals: 'image'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testApplyInputJsonDelta [
	| block |
	block := ClaudeToolUseBlock new.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'input_json_delta'. 'partial_json'. '{"ci' }).
	self assert: block input equals: '{"ci'.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'input_json_delta'. 'partial_json'. 'ty": "NYC"}' }).
	self assert: block input equals: '{"city": "NYC"}'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testApplyTextDelta [
	| block |
	block := ClaudeTextBlock new.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'text_delta'. 'text'. 'Hello' }).
	self assert: block text equals: 'Hello'.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'text_delta'. 'text'. ' world' }).
	self assert: block text equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testApplyThinkingDelta [
	| block |
	block := ClaudeThinkingBlock new.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'thinking_delta'. 'thinking'. 'Let me' }).
	self assert: block thinking equals: 'Let me'.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'thinking_delta'. 'thinking'. ' think' }).
	self assert: block thinking equals: 'Let me think'.
	block applyDelta: (Dictionary newFromPairs: { 'type'. 'signature_delta'. 'signature'. 'sig123' }).
	self assert: block signature equals: 'sig123'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testAsParamForRedactedThinkingBlock [
	| block param |
	block := ClaudeRedactedThinkingBlock data: 'opaque-data'.
	param := block asParam.
	self assert: (param at: 'type') equals: 'redacted_thinking'.
	self assert: (param at: 'data') equals: 'opaque-data'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testAsParamForThinkingBlock [
	| block param |
	block := ClaudeThinkingBlock thinking: 'reasoning' signature: 'sig456'.
	param := block asParam.
	self assert: (param at: 'type') equals: 'thinking'.
	self assert: (param at: 'thinking') equals: 'reasoning'.
	self assert: (param at: 'signature') equals: 'sig456'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testImageBlock [
	| block json |
	block := ClaudeImageBlock base64: 'iVBORw0KGgo=' mediaType: 'image/png'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'image'.
	self assert: ((json at: 'source') at: 'type') equals: 'base64'.
	self assert: ((json at: 'source') at: 'media_type') equals: 'image/png'.
	self assert: ((json at: 'source') at: 'data') equals: 'iVBORw0KGgo='
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testImageBlockBase64StillWorks [
	"Regression: base64 source creation and serialization unaffected by URL support"
	| block json source |
	block := ClaudeImageBlock base64: 'iVBORw0KGgo=' mediaType: 'image/png'.
	self assert: block type equals: 'image'.
	self assert: (block source at: 'type') equals: 'base64'.
	self assert: (block source at: 'media_type') equals: 'image/png'.
	self assert: (block source at: 'data') equals: 'iVBORw0KGgo='.
	json := block asJson.
	source := json at: 'source'.
	self assert: (source at: 'type') equals: 'base64'.
	self assert: (source at: 'media_type') equals: 'image/png'.
	self assert: (source at: 'data') equals: 'iVBORw0KGgo='
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testImageBlockFromUrl [
	"Test that fromUrl: creates an image block with URL source"
	| block json |
	block := ClaudeImageBlock fromUrl: 'https://example.com/image.jpg'.
	
	self assert: block class equals: ClaudeImageBlock.
	self assert: block type equals: 'image'.
	self assert: (block source at: 'type') equals: 'url'.
	self assert: (block source at: 'url') equals: 'https://example.com/image.jpg'.
	
	json := block asJson.
	self assert: (json at: 'type') equals: 'image'.
	self assert: ((json at: 'source') at: 'type') equals: 'url'.
	self assert: ((json at: 'source') at: 'url') equals: 'https://example.com/image.jpg'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testImageBlockUrlAsJson [
	"Test that URL source image block serializes correctly"
	| block json source |
	block := ClaudeImageBlock fromUrl: 'https://example.com/photo.png'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'image'.
	source := json at: 'source'.
	self assert: (source at: 'type') equals: 'url'.
	self assert: (source at: 'url') equals: 'https://example.com/photo.png'.
	self deny: (source includesKey: 'media_type').
	self deny: (source includesKey: 'data')
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testImageBlockUrlFromJson [
	"Test round-trip: JSON -> ClaudeImageBlock -> JSON for URL source"
	| json block roundTripped |
	json := Dictionary new.
	json at: 'type' put: 'image'.
	json at: 'source' put: (OrderedDictionary new
		at: 'type' put: 'url';
		at: 'url' put: 'https://example.com/cat.jpg';
		yourself).
	block := ClaudeContentBlock fromJson: json.
	self assert: block class equals: ClaudeImageBlock.
	self assert: (block source at: 'type') equals: 'url'.
	self assert: (block source at: 'url') equals: 'https://example.com/cat.jpg'.
	roundTripped := block asJson.
	self assert: ((roundTripped at: 'source') at: 'type') equals: 'url'.
	self assert: ((roundTripped at: 'source') at: 'url') equals: 'https://example.com/cat.jpg'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testIsTextBlock [
	self assert: ClaudeTextBlock new isTextBlock.
	self deny: ClaudeToolUseBlock new isTextBlock.
	self deny: ClaudeThinkingBlock new isTextBlock.
	self deny: ClaudeToolResultBlock new isTextBlock.
	self deny: ClaudeContentBlock new isTextBlock
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testIsToolResultBlock [
	self assert: ClaudeToolResultBlock new isToolResultBlock.
	self deny: ClaudeTextBlock new isToolResultBlock.
	self deny: ClaudeToolUseBlock new isToolResultBlock.
	self deny: ClaudeThinkingBlock new isToolResultBlock.
	self deny: ClaudeContentBlock new isToolResultBlock
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testRedactedThinkingBlock [
	| block json restored |
	block := ClaudeRedactedThinkingBlock data: 'redacted-data-string'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'redacted_thinking'.
	self assert: (json at: 'data') equals: 'redacted-data-string'.
	restored := ClaudeRedactedThinkingBlock fromJson: json.
	self assert: restored data equals: 'redacted-data-string'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testServerToolUseBlock [
	| json block restored |
	json := Dictionary new.
	json at: 'type' put: 'server_tool_use'.
	json at: 'id' put: 'stu_123'.
	json at: 'name' put: 'web_search'.
	json at: 'input' put: (Dictionary new at: 'query' put: 'weather'; yourself).
	block := ClaudeServerToolUseBlock fromJson: json.
	self assert: block type equals: 'server_tool_use'.
	restored := block asJson.
	self assert: (restored at: 'type') equals: 'server_tool_use'.
	self assert: (restored at: 'id') equals: 'stu_123'.
	self assert: (restored at: 'name') equals: 'web_search'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testTextBlockAsJson [
	| block json |
	block := ClaudeTextBlock text: 'hello'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'text'.
	self assert: (json at: 'text') equals: 'hello'.
	self deny: (json includesKey: 'citations')
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testTextBlockFromJson [
	| json block |
	json := Dictionary new.
	json at: 'type' put: 'text'.
	json at: 'text' put: 'hello'.
	block := ClaudeTextBlock fromJson: json.
	self assert: block text equals: 'hello'.
	self assert: block type equals: 'text'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testTextBlockWithCitations [
	| json block citations citation |
	citation := Dictionary new.
	citation at: 'cited_text' put: 'some text'.
	citation at: 'document_index' put: 0.
	citation at: 'document_title' put: 'Doc'.
	citation at: 'start_char_index' put: 10.
	citation at: 'end_char_index' put: 20.
	json := Dictionary new.
	json at: 'type' put: 'text'.
	json at: 'text' put: 'hello'.
	json at: 'citations' put: { citation }.
	block := ClaudeTextBlock fromJson: json.
	self assert: block text equals: 'hello'.
	citations := block citations.
	self assert: citations size equals: 1.
	self assert: citations first class equals: ClaudeCitation.
	self assert: citations first citedText equals: 'some text'.
	self assert: citations first documentIndex equals: 0.
	self assert: citations first documentTitle equals: 'Doc'.
	self assert: citations first startCharIndex equals: 10.
	self assert: citations first endCharIndex equals: 20
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testThinkingBlockRoundTrip [
	| block json restored |
	block := ClaudeThinkingBlock thinking: 'Let me reason...' signature: 'sig123'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'thinking'.
	self assert: (json at: 'thinking') equals: 'Let me reason...'.
	self assert: (json at: 'signature') equals: 'sig123'.
	restored := ClaudeThinkingBlock fromJson: json.
	self assert: restored thinking equals: 'Let me reason...'.
	self assert: restored signature equals: 'sig123'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testToolResultBlockAsJson [
	| block json |
	block := ClaudeToolResultBlock toolUseId: 'tu_abc' content: 'Sunny, 22C'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'tool_result'.
	self assert: (json at: 'tool_use_id') equals: 'tu_abc'.
	self assert: (json at: 'content') equals: 'Sunny, 22C'.
	self deny: (json includesKey: 'is_error')
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testToolResultBlockFromJson [
	| json block |
	json := Dictionary new.
	json at: 'type' put: 'tool_result'.
	json at: 'tool_use_id' put: 'tu_abc'.
	json at: 'content' put: 'Sunny, 22C'.
	json at: 'is_error' put: true.
	block := ClaudeToolResultBlock fromJson: json.
	self assert: block toolUseId equals: 'tu_abc'.
	self assert: block content equals: 'Sunny, 22C'.
	self assert: block isError equals: true.
	self assert: block type equals: 'tool_result'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testToolResultBlockWithError [
	| block json |
	block := ClaudeToolResultBlock toolUseId: 'tu_abc' content: 'Not found' isError: true.
	json := block asJson.
	self assert: (json at: 'type') equals: 'tool_result'.
	self assert: (json at: 'tool_use_id') equals: 'tu_abc'.
	self assert: (json at: 'content') equals: 'Not found'.
	self assert: (json at: 'is_error') equals: true
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testToolUseBlockAsJson [
	| block json |
	block := ClaudeToolUseBlock id: 'tu_abc' name: 'GetWeather' input: (Dictionary new at: 'city' put: 'London'; yourself).
	json := block asJson.
	self assert: (json at: 'type') equals: 'tool_use'.
	self assert: (json at: 'id') equals: 'tu_abc'.
	self assert: (json at: 'name') equals: 'GetWeather'.
	self assert: ((json at: 'input') at: 'city') equals: 'London'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testToolUseBlockFromJson [
	| json block |
	json := Dictionary new.
	json at: 'type' put: 'tool_use'.
	json at: 'id' put: 'tu_abc'.
	json at: 'name' put: 'GetWeather'.
	json at: 'input' put: (Dictionary new at: 'city' put: 'London'; yourself).
	block := ClaudeToolUseBlock fromJson: json.
	self assert: block id equals: 'tu_abc'.
	self assert: block name equals: 'GetWeather'.
	self assert: (block input at: 'city') equals: 'London'.
	self assert: block type equals: 'tool_use'
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testTypeDispatch [
	| types |
	types := {
		'text' -> ClaudeTextBlock.
		'tool_use' -> ClaudeToolUseBlock.
		'tool_result' -> ClaudeToolResultBlock.
		'thinking' -> ClaudeThinkingBlock.
		'redacted_thinking' -> ClaudeRedactedThinkingBlock.
		'image' -> ClaudeImageBlock.
		'server_tool_use' -> ClaudeServerToolUseBlock.
		'web_search_tool_result' -> ClaudeWebSearchResultBlock.
		'web_fetch_tool_result' -> ClaudeWebFetchResultBlock.
		'code_execution_tool_result' -> ClaudeCodeExecutionResultBlock.
		'bash_code_execution_tool_result' -> ClaudeBashResultBlock.
		'text_editor_code_execution_tool_result' -> ClaudeTextEditorResultBlock.
		'tool_search_tool_result' -> ClaudeToolSearchResultBlock.
		'container_upload' -> ClaudeContainerUploadBlock.
		'compaction' -> ClaudeCompactionBlock
	}.
	types do: [ :assoc |
		| json block |
		json := Dictionary new.
		json at: 'type' put: assoc key.
		block := ClaudeContentBlock fromJson: json.
		self assert: block class equals: assoc value ]
]

{ #category : 'tests' }
ClaudeContentBlockTest >> testUnknownType [
	| json block |
	json := Dictionary new.
	json at: 'type' put: 'future_block_type'.
	json at: 'data' put: 'some payload'.
	block := ClaudeContentBlock fromJson: json.
	self assert: block class equals: ClaudeContentBlock.
	self assert: block type equals: 'future_block_type'.
	self assert: (block asJson at: 'type') equals: 'future_block_type'.
	self assert: (block asJson at: 'data') equals: 'some payload'
]
