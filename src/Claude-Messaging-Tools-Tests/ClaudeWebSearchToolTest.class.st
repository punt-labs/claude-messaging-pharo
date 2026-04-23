"
Tests for ClaudeWebSearchTool server-side tool.

  ClaudeWebSearchToolTest buildSuite run
  >>> a TestResult (0 failures, 0 errors)

"
Class {
	#name : 'ClaudeWebSearchToolTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testAddWebSearchConvenience [
  "addWebSearch adds a web search tool to the request."
  | request json toolsJson |
  request := ClaudeMessageRequest new.
  request model: 'claude-sonnet-4-20250514'.
  request maxTokens: 1024.
  request addUserMessage: 'Hello'.
  request addWebSearch.
  json := request asJson.
  toolsJson := json at: 'tools'.
  self assert: toolsJson size equals: 1.
  self assert: (toolsJson first at: 'type') equals: 'web_search_20250305'.
  self assert: (toolsJson first at: 'name') equals: 'web_search'
]

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testDefaultJson [
  "Default web search tool produces type and name keys only."
  | tool json |
  tool := ClaudeWebSearchTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'web_search_20250305'.
  self assert: (json at: 'name') equals: 'web_search'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testFromJsonRoundTrip [
  "asJson then fromJson: reconstructs all config params."
  | tool json restored |
  tool := ClaudeWebSearchTool new.
  tool maxUses: 3.
  tool allowedDomains: #('docs.anthropic.com').
  tool blockedDomains: #('bad.com').
  tool userLocation: ({ 'type' -> 'approximate'. 'city' -> 'London' } asDictionary).
  tool citations: ({ 'enabled' -> true } asDictionary).
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeWebSearchTool.
  self assert: restored toolType equals: 'web_search_20250305'.
  self assert: restored toolName equals: 'web_search'.
  self assert: restored maxUses equals: 3.
  self assert: restored allowedDomains equals: #('docs.anthropic.com').
  self assert: restored blockedDomains equals: #('bad.com').
  self assert: (restored userLocation at: 'city') equals: 'London'.
  self assert: (restored citations at: 'enabled') equals: true
]

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testNilConfigFieldsAbsent [
  "Config params that are nil do not appear in JSON."
  | tool json |
  tool := ClaudeWebSearchTool new.
  json := tool asJson.
  self deny: (json includesKey: 'max_uses').
  self deny: (json includesKey: 'allowed_domains').
  self deny: (json includesKey: 'blocked_domains').
  self deny: (json includesKey: 'user_location').
  self deny: (json includesKey: 'citations')
]

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testRegisteredInTypeRegistry [
  "ClaudeWebSearchTool is registered in the server tool type registry."
  ClaudeWebSearchTool initialize.
  self assert: (ClaudeServerTool typeRegistry at: 'web_search') equals: ClaudeWebSearchTool
]

{ #category : 'tests' }
ClaudeWebSearchToolTest >> testWithAllConfig [
  "All config params serialize when set."
  | tool json loc |
  tool := ClaudeWebSearchTool new.
  tool maxUses: 5.
  tool allowedDomains: #('example.com' 'docs.anthropic.com').
  tool blockedDomains: #('spam.com').
  loc := Dictionary new.
  loc at: 'type' put: 'approximate'.
  loc at: 'city' put: 'San Francisco'.
  loc at: 'country' put: 'US'.
  loc at: 'region' put: 'California'.
  loc at: 'timezone' put: 'America/Los_Angeles'.
  tool userLocation: loc.
  tool citations: ({ 'enabled' -> true } asDictionary).
  json := tool asJson.
  self assert: (json at: 'max_uses') equals: 5.
  self assert: (json at: 'allowed_domains') equals: #('example.com' 'docs.anthropic.com').
  self assert: (json at: 'blocked_domains') equals: #('spam.com').
  self assert: ((json at: 'user_location') at: 'city') equals: 'San Francisco'.
  self assert: ((json at: 'user_location') at: 'type') equals: 'approximate'.
  self assert: ((json at: 'citations') at: 'enabled') equals: true
]
