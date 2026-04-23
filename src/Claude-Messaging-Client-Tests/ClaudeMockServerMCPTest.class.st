"
End-to-end mock-server test for the MCP connector. Verifies request-side serialization (mcp_servers field, anthropic-beta header) and response-side decoding (mcp_tool_use and mcp_tool_result blocks via TypeRegistry dispatch).

  ClaudeMockServerMCPTest buildSuite run
  >>> 5 ran, 5 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected

"
Class {
	#name : 'ClaudeMockServerMCPTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeMockServerMCPTest >> mcpResponseJsonWithArrayContent [
	^ '{"id": "msg_mcp_test", "type": "message", "role": "assistant", "model": "claude-sonnet-4-5-20250514", "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 5, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}, "content": [{"type": "mcp_tool_use", "id": "mcp_use_001", "name": "echo", "server_name": "example", "input": {"message": "hi"}}, {"type": "mcp_tool_result", "tool_use_id": "mcp_use_001", "is_error": false, "content": [{"type": "text", "text": "hi"}]}]}'
]

{ #category : 'fixtures' }
ClaudeMockServerMCPTest >> mcpResponseJsonWithStringContent [
	^ '{"id": "msg_mcp_test", "type": "message", "role": "assistant", "model": "claude-sonnet-4-5-20250514", "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 5, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}, "content": [{"type": "mcp_tool_use", "id": "mcp_use_001", "name": "echo", "server_name": "example", "input": {"message": "hi"}}, {"type": "mcp_tool_result", "tool_use_id": "mcp_use_001", "is_error": false, "content": "hi"}]}'
]

{ #category : 'fixtures' }
ClaudeMockServerMCPTest >> newMcpRequest [
	| req |
	req := ClaudeMessageRequest new.
	req model: 'claude-sonnet-4-5-20250514'.
	req maxTokens: 1024.
	req betas: #('mcp-client-2025-04-04').
	req mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://example-server.modelcontextprotocol.io/sse' }.
	req addUserMessage: 'Use echo'.
	^ req
]

{ #category : 'running' }
ClaudeMockServerMCPTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5
]

{ #category : 'running' }
ClaudeMockServerMCPTest >> tearDown [
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeMockServerMCPTest >> testRequestSendsBetaHeader [
	| header |
	mockServer respondTo: '/v1/messages' with: self mcpResponseJsonWithArrayContent.
	client sendMessage: self newMcpRequest.
	header := mockServer lastRequestHeaders at: 'anthropic-beta'.
	self assert: header equals: 'mcp-client-2025-04-04'
]

{ #category : 'tests' }
ClaudeMockServerMCPTest >> testRequestSerializesMcpServers [
	| body mcp |
	mockServer respondTo: '/v1/messages' with: self mcpResponseJsonWithArrayContent.
	client sendMessage: self newMcpRequest.
	body := mockServer lastRequestBody.
	mcp := body at: 'mcp_servers'.
	self assert: mcp size equals: 1.
	self assert: (mcp first at: 'name') equals: 'example'.
	self assert: (mcp first at: 'url') equals: 'https://example-server.modelcontextprotocol.io/sse'
]

{ #category : 'tests' }
ClaudeMockServerMCPTest >> testResponseDecodesMcpToolResultBlock [
	| msg resultBlock |
	mockServer respondTo: '/v1/messages' with: self mcpResponseJsonWithArrayContent.
	msg := client sendMessage: self newMcpRequest.
	resultBlock := msg content detect: [ :b | b isMCPToolResultBlock ].
	self assert: resultBlock class equals: ClaudeMCPToolResultBlock.
	self assert: resultBlock toolUseId equals: 'mcp_use_001'.
	self assert: resultBlock isError equals: false.
	self assert: (resultBlock content isKindOf: OrderedCollection).
	self assert: resultBlock content size equals: 1.
	self assert: resultBlock content first text equals: 'hi'
]

{ #category : 'tests' }
ClaudeMockServerMCPTest >> testResponseDecodesMcpToolResultBlockWithStringContent [
	| msg resultBlock |
	mockServer respondTo: '/v1/messages' with: self mcpResponseJsonWithStringContent.
	msg := client sendMessage: self newMcpRequest.
	resultBlock := msg content detect: [ :b | b isMCPToolResultBlock ].
	self assert: resultBlock content equals: 'hi'.
	self assert: resultBlock content isString
]

{ #category : 'tests' }
ClaudeMockServerMCPTest >> testResponseDecodesMcpToolUseBlock [
	| msg useBlock |
	mockServer respondTo: '/v1/messages' with: self mcpResponseJsonWithArrayContent.
	msg := client sendMessage: self newMcpRequest.
	useBlock := msg content detect: [ :b | b isMCPToolUseBlock ].
	self assert: useBlock class equals: ClaudeMCPToolUseBlock.
	self assert: useBlock id equals: 'mcp_use_001'.
	self assert: useBlock name equals: 'echo'.
	self assert: useBlock serverName equals: 'example'.
	self assert: (useBlock input at: 'message') equals: 'hi'
]
