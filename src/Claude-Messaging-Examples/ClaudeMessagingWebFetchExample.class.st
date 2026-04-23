"
I demonstrate Claude's web fetch server tool — when enabled, Claude can retrieve a specific URL during a conversation turn and incorporate the page contents into its answer.

**When to use this tool**

Reach for `ClaudeWebFetchTool` when the user (or your prompt) names the URL Claude should read — fetching a docs page, an article, an HTML report. When the URL is unknown and you need Claude to discover it first, use `ClaudeWebSearchTool` (see `ClaudeWebSearchExample`) instead. The two tools compose: a search-then-fetch turn typically runs both.

**What comes back**

A successful turn produces a `ClaudeWebFetchResultBlock` in the response content, followed by a `ClaudeTextBlock` with Claude's summary. Select for the result block when you need the raw fetched content; read `textContent` for the summary.

**Runnable example**

  ClaudeMessagingWebFetchExample buildRequest tools first class name
  >>> #ClaudeWebFetchTool

  ClaudeMessagingWebFetchExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testWebFetchRetrievesPageSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeMessagingWebFetchExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingWebFetchExample class >> buildRequest [
	"Build a message request with ClaudeWebFetchTool configured.
	 Targets the same fixture URL the integration test fetches so the
	 example does not introduce a new external dependency."
	| params |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addServerTool: ClaudeWebFetchTool new.
	params addUserMessage: 'Fetch https://httpbin.org/html and tell me what kind of page it is.'.
	^ params
]

{ #category : 'private' }
ClaudeMessagingWebFetchExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport for keyring + env-based key resolution."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingWebFetchExample class >> run [
	"Send a web fetch request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingWebFetchExample class >> runOn: aClient [
	"Send a web fetch request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]
