"
I demonstrate Claude's web search server tool — when enabled, Claude can issue web search queries during a conversation turn and incorporate the result snippets into its answer.

**When to use this tool**

Reach for `ClaudeWebSearchTool` when the URL Claude needs is unknown and Claude must discover it first — answering current-events questions, finding documentation pages, looking up entities. When you already know the URL Claude should read, use `ClaudeWebFetchTool` (see `ClaudeMessagingWebFetchExample`) instead. The two tools compose: a typical research turn first searches to find candidate URLs, then fetches the most promising one for full content.

**What comes back**

A successful turn produces one or more `ClaudeWebSearchResultBlock` entries (URL + title + snippet for each result), followed by a `ClaudeTextBlock` with Claude's synthesis. Select for the result blocks when you need the raw search hits with citations; read `textContent` for the synthesized answer.

**Runnable example**

  ClaudeWebSearchExample buildRequest tools first class name
  >>> #ClaudeWebSearchTool

  ClaudeWebSearchExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testWebSearchReturnsResultsSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeWebSearchExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeWebSearchExample class >> buildRequest [
	"Build a message request with ClaudeWebSearchTool configured."
	| params |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addServerTool: ClaudeWebSearchTool new.
	params addUserMessage: 'What is the current population of Tokyo?'.
	^ params
]

{ #category : 'private' }
ClaudeWebSearchExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeWebSearchExample class >> run [
	"Send a web search request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeWebSearchExample class >> runOn: aClient [
	"Send a web search request using the given client. Returns the response."
	| params |
	params := self buildRequest.
	^ aClient sendMessage: params
]
