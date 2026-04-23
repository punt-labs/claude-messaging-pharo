"
Tests for ClaudeMemoryTool, ClaudeToolSearchBm25Tool, and ClaudeToolSearchRegexTool utility server tools.

  ClaudeUtilityToolTest buildSuite run
  >>> a TestResult (0 failures, 0 errors)

"
Class {
	#name : 'ClaudeUtilityToolTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'tests' }
ClaudeUtilityToolTest >> testConvenienceMethods [
  "addMemory, addToolSearchBm25, addToolSearchRegex add tools to the request."
  | request json toolsJson |
  request := ClaudeMessageRequest new.
  request model: 'claude-sonnet-4-20250514'.
  request maxTokens: 1024.
  request addUserMessage: 'Hello'.
  request addMemory.
  request addToolSearchBm25.
  request addToolSearchRegex.
  json := request asJson.
  toolsJson := json at: 'tools'.
  self assert: toolsJson size equals: 3.
  self assert: (toolsJson first at: 'type') equals: 'memory_20250818'.
  self assert: (toolsJson first at: 'name') equals: 'memory'.
  self assert: (toolsJson second at: 'type') equals: 'tool_search_tool_bm25_20251119'.
  self assert: (toolsJson second at: 'name') equals: 'tool_search_tool_bm25'.
  self assert: (toolsJson third at: 'type') equals: 'tool_search_tool_regex_20251119'.
  self assert: (toolsJson third at: 'name') equals: 'tool_search_tool_regex'
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testMemoryDefaultJson [
  "Default memory tool produces type and name keys only."
  | tool json |
  tool := ClaudeMemoryTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'memory_20250818'.
  self assert: (json at: 'name') equals: 'memory'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testMemoryFromJsonRoundTrip [
  "asJson then fromJson: reconstructs memory tool with base params."
  | tool json restored |
  tool := ClaudeMemoryTool new.
  tool strict: true.
  tool deferLoading: false.
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeMemoryTool.
  self assert: restored toolType equals: 'memory_20250818'.
  self assert: restored toolName equals: 'memory'.
  self assert: restored strict equals: true.
  self assert: restored deferLoading equals: false
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchBm25DefaultJson [
  "Default BM25 tool search produces type and name keys only."
  | tool json |
  tool := ClaudeToolSearchBm25Tool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'tool_search_tool_bm25_20251119'.
  self assert: (json at: 'name') equals: 'tool_search_tool_bm25'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchBm25FromJsonRoundTrip [
  "asJson then fromJson: reconstructs maxResults on BM25 tool search."
  | tool json restored |
  tool := ClaudeToolSearchBm25Tool new.
  tool maxResults: 25.
  tool deferLoading: true.
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeToolSearchBm25Tool.
  self assert: restored toolType equals: 'tool_search_tool_bm25_20251119'.
  self assert: restored toolName equals: 'tool_search_tool_bm25'.
  self assert: restored maxResults equals: 25.
  self assert: restored deferLoading equals: true
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchBm25WithMaxResults [
  "maxResults serializes when set on BM25 tool search."
  | tool json |
  tool := ClaudeToolSearchBm25Tool new.
  tool maxResults: 20.
  json := tool asJson.
  self assert: (json at: 'max_results') equals: 20.
  self assert: (json at: 'type') equals: 'tool_search_tool_bm25_20251119'.
  self assert: json size equals: 3
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchRegexDefaultJson [
  "Default regex tool search produces type and name keys only."
  | tool json |
  tool := ClaudeToolSearchRegexTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'tool_search_tool_regex_20251119'.
  self assert: (json at: 'name') equals: 'tool_search_tool_regex'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchRegexFromJsonRoundTrip [
  "asJson then fromJson: reconstructs maxResults on regex tool search."
  | tool json restored |
  tool := ClaudeToolSearchRegexTool new.
  tool maxResults: 30.
  tool strict: false.
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeToolSearchRegexTool.
  self assert: restored toolType equals: 'tool_search_tool_regex_20251119'.
  self assert: restored toolName equals: 'tool_search_tool_regex'.
  self assert: restored maxResults equals: 30.
  self assert: restored strict equals: false
]

{ #category : 'tests' }
ClaudeUtilityToolTest >> testToolSearchRegexWithMaxResults [
  "maxResults serializes when set on regex tool search."
  | tool json |
  tool := ClaudeToolSearchRegexTool new.
  tool maxResults: 15.
  json := tool asJson.
  self assert: (json at: 'max_results') equals: 15.
  self assert: (json at: 'type') equals: 'tool_search_tool_regex_20251119'.
  self assert: json size equals: 3
]
