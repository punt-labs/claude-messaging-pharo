"
I demonstrate Claude's text editor server tool — when enabled, Claude can view, create, and edit files (via str_replace operations) on Anthropic's sandboxed infrastructure during a conversation turn.

**When to use this tool**

Reach for `ClaudeTextEditorTool` when you want Claude to read, write, or transform a file on Anthropic's side — drafting source, applying patches, restructuring text. The container shares state with `ClaudeBashTool` and `ClaudeCodeExecutionTool` within a turn, so Claude can edit a file then run it. Configure `maxCharacters:` to cap the size of any single file the model views in one operation (this example sets 50000). For local file edits via the in-image agent, use `EditFile` and `CreateFile` in `Claude-Agent-Commands`, which sandbox to the image directory.

**What comes back**

A successful turn produces a `ClaudeTextEditorResultBlock` for each edit operation in the response content, followed by a `ClaudeTextBlock` with Claude's summary. Select for the result block when you need the raw view/replace output.

**Runnable example**

  ClaudeMessagingTextEditorExample buildRequest tools first class name
  >>> #ClaudeTextEditorTool

  ClaudeMessagingTextEditorExample buildRequest tools first maxCharacters
  >>> 50000

  ClaudeMessagingTextEditorExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testTextEditorEditsFileSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeMessagingTextEditorExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingTextEditorExample class >> buildRequest [
	"Build a message request with ClaudeTextEditorTool configured.
	 Demonstrates the optional maxCharacters: config (caps file content size
	 the model can view in a single edit operation) by setting it explicitly."
	| params editor |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	editor := ClaudeTextEditorTool new.
	editor maxCharacters: 50000.
	params addServerTool: editor.
	params addUserMessage: 'Create a one-line file at /tmp/hello.txt containing the text "hi".'.
	^ params
]

{ #category : 'private' }
ClaudeMessagingTextEditorExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport for keyring + env-based key resolution."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingTextEditorExample class >> run [
	"Send a text editor request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingTextEditorExample class >> runOn: aClient [
	"Send a text editor request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]
