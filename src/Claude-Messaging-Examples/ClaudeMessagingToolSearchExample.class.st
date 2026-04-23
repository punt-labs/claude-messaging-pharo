"
I demonstrate Claude's tool search server tools — when enabled, Claude searches a large catalog of client tools and ranks the best candidates for the current turn instead of pasting the full schema for every tool into the system prompt. I cover both ranking variants: BM25 (default `buildRequest`) and regex (`buildRegexRequest`).

**When to use this tool**

Reach for tool search when your application exposes more than a handful of client tools to Claude — a tool catalog of ~10 or more, where listing all schemas in the system prompt is wasteful or exceeds the model's effective working set. Choose `ClaudeToolSearchBm25Tool` when you want lexical relevance ranking on the user's message; choose `ClaudeToolSearchRegexTool` when you want pattern-based filtering instead. Both honour `maxResults:` to cap how many tools come back per search. For small tool sets (one or two tools), pass them inline via `tools:` and skip search entirely. The example fixture (`fixtureClientTools`) contributes a tiny weather + calculator catalog so the search has something to find.

**What comes back**

Tool search produces a `ClaudeToolSearchResultBlock` listing the matched tools, then Claude follows up with a `ClaudeToolUseBlock` invoking the chosen one. Read the search result block to see what the ranker selected; read the tool_use block to see the actual call.

**Runnable example**

  ClaudeMessagingToolSearchExample buildRequest tools last class name
  >>> #ClaudeToolSearchBm25Tool

  ClaudeMessagingToolSearchExample buildRegexRequest tools last class name
  >>> #ClaudeToolSearchRegexTool

  ClaudeMessagingToolSearchExample buildRequest tools size
  >>> 3

  ClaudeMessagingToolSearchExample buildRequest tools last maxResults
  >>> 5

  ClaudeMessagingToolSearchExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testToolSearchBm25FindsToolsSonnet` and `>>testToolSearchRegexFindsToolsSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeMessagingToolSearchExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingToolSearchExample class >> buildRegexRequest [
	"Build a message request that uses the regex tool search variant.
	 Same fixture client tools as buildRequest, but Claude searches them
	 by regex pattern instead of BM25 ranking."
	| params searchTool |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params tools: self fixtureClientTools.
	searchTool := ClaudeToolSearchRegexTool new.
	searchTool maxResults: 5.
	params addServerTool: searchTool.
	params addUserMessage: 'What is the weather in Paris?'.
	^ params
]

{ #category : 'building' }
ClaudeMessagingToolSearchExample class >> buildRequest [
	"Build a message request that uses the BM25 tool search variant.
	 Adds two client tools (weather, calculator) so the server-side
	 BM25 search has candidates to rank."
	| params searchTool |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params tools: self fixtureClientTools.
	searchTool := ClaudeToolSearchBm25Tool new.
	searchTool maxResults: 5.
	params addServerTool: searchTool.
	params addUserMessage: 'What is the weather in Paris?'.
	^ params
]

{ #category : 'fixtures' }
ClaudeMessagingToolSearchExample class >> fixtureClientTools [
	"Build a small fixture set of client tools (weather + calculator) so the
	 server-side tool search has something to find. Mirrors the helper in
	 ClaudeServerToolIntegrationTest>>toolSearchParamsFor:withServerTool: but
	 lifted into the example so a developer can copy the shape."
	| weather calc |
	weather := ClaudeTool new.
	weather name: 'get_weather'.
	weather description: 'Get the current weather for a location'.
	weather inputSchema: (ClaudeToolInputSchema new
		properties: { 'location' -> { 'type' -> 'string' } asDictionary } asDictionary;
		required: #('location')).
	calc := ClaudeTool new.
	calc name: 'calculate'.
	calc description: 'Evaluate a math expression'.
	calc inputSchema: (ClaudeToolInputSchema new
		properties: { 'expression' -> { 'type' -> 'string' } asDictionary } asDictionary;
		required: #('expression')).
	^ OrderedCollection new add: weather; add: calc; yourself
]

{ #category : 'private' }
ClaudeMessagingToolSearchExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport for keyring + env-based key resolution."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingToolSearchExample class >> run [
	"Send a BM25 tool search request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingToolSearchExample class >> runOn: aClient [
	"Send a BM25 tool search request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]

{ #category : 'examples' }
ClaudeMessagingToolSearchExample class >> runRegex [
	"Send a regex tool search request and return the response."
	^ self runRegexOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingToolSearchExample class >> runRegexOn: aClient [
	"Send a regex tool search request using the given client. Returns the response."
	^ aClient sendMessage: self buildRegexRequest
]
