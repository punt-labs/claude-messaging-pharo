"
Tests for ClaudeWebFetchTool server-side tool.

  ClaudeWebFetchToolTest buildSuite run
  >>> a TestResult (0 failures, 0 errors)

"
Class {
	#name : 'ClaudeWebFetchToolTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testAddWebFetchConvenience [
  "addWebFetch adds a web fetch tool to the request."
  | request json toolsJson |
  request := ClaudeMessageRequest new.
  request model: 'claude-sonnet-4-20250514'.
  request maxTokens: 1024.
  request addUserMessage: 'Hello'.
  request addWebFetch.
  json := request asJson.
  toolsJson := json at: 'tools'.
  self assert: toolsJson size equals: 1.
  self assert: (toolsJson first at: 'type') equals: 'web_fetch_20250910'.
  self assert: (toolsJson first at: 'name') equals: 'web_fetch'
]

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testDefaultJson [
  "Default web fetch tool produces type and name keys only."
  | tool json |
  tool := ClaudeWebFetchTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'web_fetch_20250910'.
  self assert: (json at: 'name') equals: 'web_fetch'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testFromJsonRoundTrip [
  "asJson then fromJson: reconstructs all config params."
  | tool json restored |
  tool := ClaudeWebFetchTool new.
  tool maxUses: 7.
  tool allowedDomains: #('example.com').
  tool blockedDomains: #('bad.com').
  tool maxContentTokens: 15000.
  tool useCache: false.
  tool citations: ({ 'enabled' -> false } asDictionary).
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeWebFetchTool.
  self assert: restored toolType equals: 'web_fetch_20250910'.
  self assert: restored toolName equals: 'web_fetch'.
  self assert: restored maxUses equals: 7.
  self assert: restored allowedDomains equals: #('example.com').
  self assert: restored blockedDomains equals: #('bad.com').
  self assert: restored maxContentTokens equals: 15000.
  self assert: restored useCache equals: false.
  self assert: (restored citations at: 'enabled') equals: false
]

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testNilConfigFieldsAbsent [
  "Config params that are nil do not appear in JSON."
  | tool json |
  tool := ClaudeWebFetchTool new.
  json := tool asJson.
  self deny: (json includesKey: 'max_uses').
  self deny: (json includesKey: 'allowed_domains').
  self deny: (json includesKey: 'blocked_domains').
  self deny: (json includesKey: 'max_content_tokens').
  self deny: (json includesKey: 'use_cache').
  self deny: (json includesKey: 'citations')
]

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testRegisteredInTypeRegistry [
  "ClaudeWebFetchTool is registered in the server tool type registry."
  self assert: (ClaudeServerTool typeRegistry at: 'web_fetch') equals: ClaudeWebFetchTool
]

{ #category : 'tests' }
ClaudeWebFetchToolTest >> testWithConfig [
  "All config params serialize when set."
  | tool json |
  tool := ClaudeWebFetchTool new.
  tool maxUses: 10.
  tool allowedDomains: #('docs.anthropic.com').
  tool blockedDomains: #('spam.com').
  tool maxContentTokens: 20000.
  tool useCache: true.
  tool citations: ({ 'enabled' -> true } asDictionary).
  json := tool asJson.
  self assert: (json at: 'max_uses') equals: 10.
  self assert: (json at: 'allowed_domains') equals: #('docs.anthropic.com').
  self assert: (json at: 'blocked_domains') equals: #('spam.com').
  self assert: (json at: 'max_content_tokens') equals: 20000.
  self assert: (json at: 'use_cache') equals: true.
  self assert: ((json at: 'citations') at: 'enabled') equals: true
]
