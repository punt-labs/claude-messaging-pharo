"
Demonstrate the MCP connector beta. Builds a request that sets the mcp-client-2025-04-04 beta header and attaches one MCP server (mcp.deepwiki.com) with the read_wiki_contents, read_wiki_structure, ask_question tools allow-listed.

This example exercises the connector mode of MCP: the URL of an externally hosted MCP server is passed in mcp_servers, and Anthropic's infrastructure makes the outbound connection to that server during message generation. Anthropic acts as the MCP client. This is NOT exposing the Pharo image as an MCP server (a separate feature, not v1.0), and it is unrelated to Claude Code's own MCP runtime that hosts biff/quarry/lux.

  ClaudeMessagingMCPExample buildRequest mcpServers first name
  >>> 'deepwiki'

  ClaudeMessagingMCPExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingMCPExample buildRequest requestOptions betaHeader
  >>> 'mcp-client-2025-04-04'



"
Class {
	#name : 'ClaudeMessagingMCPExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingMCPExample class >> buildRequest [
	"Build a request that activates the MCP connector beta and attaches one MCP server.
	 The user opts in by setting both betas: and mcpServers: explicitly."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 1024.
	req betas: #('mcp-client-2025-04-04').
	req mcpServers: { self exampleServer }.
	req addUserMessage: 'Use the deepwiki MCP server to look up https://github.com/modelcontextprotocol/python-sdk. Briefly summarize what it is in one sentence.'.
	^ req
]

{ #category : 'building' }
ClaudeMessagingMCPExample class >> exampleServer [
	"Build the documentation example MCP server definition. The server runs externally —
	 Anthropic's infrastructure connects to it during message generation."
	| server |
	server := ClaudeMCPServerDefinition
		name: 'deepwiki'
		url: 'https://mcp.deepwiki.com/mcp'.
	server toolConfiguration: (ClaudeMCPToolConfiguration
		enabled: true
		allowedTools: #('read_wiki_contents' 'read_wiki_structure' 'ask_question')).
	^ server
]

{ #category : 'private' }
ClaudeMessagingMCPExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingMCPExample class >> run [
	"Send the example MCP request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingMCPExample class >> runOn: aClient [
	"Send the example MCP request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]
