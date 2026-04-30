"
Live end-to-end integration test for the MCP connector beta. Exercises the
full round-trip: our request sets the `mcp-client-2025-04-04` beta header
and attaches the DeepWiki MCP server, Anthropic's infrastructure opens an
outbound connection to `mcp.deepwiki.com`, the external MCP server returns
a tool result, and the final response carries both a `ClaudeMCPToolUseBlock`
and a `ClaudeMCPToolResultBlock` alongside any assistant text.

This test exists because the MCP connector (PR #101) has two moving parts
that cannot be mock-verified end-to-end: the Anthropic beta header and the
outbound connection to an external MCP server. Live proof is the only proof.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present the test skips via
`self skip` -- it does not fail on a key-less image. The default suite
(`ClaudeMessagingTestSuite suite`) excludes this class by protocol; only
`integrationSuite` includes it.

**External-infrastructure dependency.** Message generation drives an
outbound call from Anthropic's infrastructure to `mcp.deepwiki.com/mcp`
-- a public MCP server we do not control. A DeepWiki outage or API change
can make this test fail red without any bug in our code. That failure mode
is acceptable for a nightly CI job (visible but not blocking, via
`continue-on-error: true` on the slow-suite workflow). First-line triage
on a failure should distinguish upstream infra from our code.

**Server-computed assertions.** Every assertion targets a value the server
produces. The client cannot fake these:

- at least one `ClaudeMCPToolUseBlock` in the response content -- proves
  Anthropic decided to invoke an MCP tool during generation
- `serverName = 'deepwiki'` on the tool_use block -- echo of what we sent
  in the request's `mcpServers:` list, NOT a server-generated value;
  kept as a structural integrity check that Anthropic preserves the field
- at least one `ClaudeMCPToolResultBlock` in the response content -- proves
  Anthropic's infrastructure successfully connected to the external MCP
  server and parsed its result back into a content block
- `response stopReason = #end_turn` -- proves the server completed
  generation cleanly after the MCP tool-use round-trip (compared as a
  Symbol; `stopReason:` coerces via `asSymbol`)

Text content is deliberately not asserted. The prompt targets an external
MCP server's answer quality, which drifts without any change on our side.
Structural round-trip properties matter; string content does not.

**No cleanup.** MCP connector mode is stateless on our side -- there are
no server-side resources created by this test (no skill uploaded, no file
stored). Absence of an `ensure:` block is intentional.

  ClaudeMCPIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeMCPIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-MCP-Tests',
	#package : 'Claude-Messaging-MCP-Tests'
}

{ #category : 'accessing' }
ClaudeMCPIntegrationTest >> defaultTimeLimit [
	"MCP connector round-trip issues a message request whose generation
	 itself depends on an outbound call from Anthropic to an external MCP
	 server (DeepWiki). Two network hops end-to-end; the default 10 s test
	 timeout fires before a healthy round-trip can complete. 2 minutes
	 matches ClaudeServerToolIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeMCPIntegrationTest >> testMCPConnectorRoundTripsAgainstAnthropic [
	"Drive a full MCP connector round-trip against api.anthropic.com and
	 assert server-computed structural properties of the response. Skips
	 cleanly when no API key is configured. No cleanup: MCP connector mode
	 creates no server-side resources on our side."

	| client response mcpToolUseBlocks mcpToolResultBlocks resultBlock resultContent |
	client := [ ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingMCPExample runOn: client.

	mcpToolUseBlocks := response content select: [ :b | b isMCPToolUseBlock ].
	self
		assert: mcpToolUseBlocks isNotEmpty
		description: 'response must contain at least one server-generated mcp_tool_use block'.

	self
		assert: mcpToolUseBlocks first serverName = 'deepwiki'
		description: 'Anthropic must echo the server name from the mcpServers list (structural round-trip)'.

	mcpToolResultBlocks := response content select: [ :b | b isMCPToolResultBlock ].
	self
		assert: mcpToolResultBlocks isNotEmpty
		description: 'response must contain at least one mcp_tool_result block from the external MCP server'.

	"Non-vacuous success: a structurally present mcp_tool_result block could still
	 carry an error flag or empty payload. Guard against a test that would pass
	 green while the external MCP server actually reported failure."
	resultBlock := mcpToolResultBlocks first.
	self
		deny: resultBlock isError
		description: 'server returned a non-error result from the external MCP server'.

	"content is polymorphic: a String (plain text) or an OrderedCollection of
	 ClaudeTextBlock (structured). isNotEmpty is polymorphic across both."
	resultContent := resultBlock content.
	self
		assert: (resultContent isNil not and: [ resultContent isNotEmpty ])
		description: 'server returned non-empty content from the external MCP server'.

	self
		assert: response stopReason = #end_turn
		description: 'server must complete generation cleanly after the MCP tool-use round-trip'
]

{ #category : 'tests-integration' }
ClaudeMCPIntegrationTest >> testMCPToolResultBlockContentUnionAgainstAnthropic [
	"Assert the polymorphic content slot on ClaudeMCPToolResultBlock
	 matches one of its two documented wire shapes: a String (plain
	 text) or a non-empty collection of ClaudeTextBlock (structured).
	 The mock tests already cover both shapes structurally; this live
	 test proves the server delivers a consistent wire shape end-to-end
	 for the MCP connector round-trip. Skips cleanly when no API key
	 is present. No cleanup: MCP connector mode creates no server-side
	 resources on our side.

	 Strict-collection check uses allSatisfy: rather than first
	 isTextBlock; the contract is that EVERY element of the collection
	 is a ClaudeTextBlock, not just the head. A mixed collection (e.g.
	 a future server-side hybrid that interleaves block kinds) would
	 violate the documented union shape and must fail red here, not
	 slip through because the first element happened to be text."

	| client response resultBlocks content |
	client := [ ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingMCPExample runOn: client.
	resultBlocks := response content select: [ :b | b isMCPToolResultBlock ].
	self
		assert: resultBlocks isNotEmpty
		description: 'server must return at least one mcp_tool_result block'.
	content := resultBlocks first content.
	self
		assert: (content isString
			or: [ content isCollection
				and: [ content isNotEmpty
					and: [ content allSatisfy: [ :each | each isTextBlock ] ] ] ])
		description: 'content slot must be a String OR a non-empty collection where every element isTextBlock; got '
			, content class name , ' with value ' , content printString
]
