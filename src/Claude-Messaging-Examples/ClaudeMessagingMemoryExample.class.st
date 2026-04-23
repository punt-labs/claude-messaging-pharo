"
I demonstrate Claude's memory server tool — when enabled, Claude can persist key facts across conversation turns and recall them later in the same session.

**When to use this tool**

Reach for `ClaudeMemoryTool` when you want Claude to retain information across turns without you re-stating it each time — preferences, partial state, intermediate findings during a long investigation. Memory operates within a session managed by Anthropic; it is not durable storage owned by your application. For application-side persistence (sessions, checkpoints, replayable transcripts), build on top with your own store; the in-image agent uses `Claude-Workbench` ston session files for this.

**What comes back**

The memory tool does not produce a dedicated result block — Claude's acknowledgement and any recalled values surface in the assistant's `ClaudeTextBlock` text response. Read `response textContent` for what the model wrote about the remembered fact.

**Runnable example**

  ClaudeMessagingMemoryExample buildRequest tools first class name
  >>> #ClaudeMemoryTool

  ClaudeMessagingMemoryExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testMemoryStoresInformationSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeMessagingMemoryExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingMemoryExample class >> buildRequest [
	"Build a message request with ClaudeMemoryTool configured.
	 Uses an example memory prompt for this runnable sample."
	| params |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addServerTool: ClaudeMemoryTool new.
	params addUserMessage: 'Remember that my favorite color is blue, then confirm what you remembered.'.
	^ params
]

{ #category : 'private' }
ClaudeMessagingMemoryExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport for keyring + env-based key resolution."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingMemoryExample class >> run [
	"Send a memory request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingMemoryExample class >> runOn: aClient [
	"Send a memory request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]
