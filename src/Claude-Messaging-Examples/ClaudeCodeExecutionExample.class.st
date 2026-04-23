"
I demonstrate Claude's code execution server tool — when enabled, Claude can write and run Python code in a sandboxed container on Anthropic's infrastructure during a conversation turn.

**When to use this tool**

Reach for `ClaudeCodeExecutionTool` when the work is computational or notebook-shaped: data analysis with pandas, numerical computation, plot generation with matplotlib, multi-step transformations on uploaded files. The container is a Python environment with persistent files within a turn and can be augmented with skills (see `ClaudeMessagingSkillsExample`). When you only need a one-shot shell command, use `ClaudeBashTool` (see `ClaudeMessagingBashExample`) — it shares the same container but the surface area is smaller. For local Python-style work via the in-image agent, build commands on top of `Claude-Agent-Commands`.

**What comes back**

A successful turn produces a mix of `ClaudeBashResultBlock`, `ClaudeTextEditorResultBlock`, and (for plots/files) `ClaudeContainerUploadBlock` entries reflecting each tool call the model made inside the container, followed by a `ClaudeTextBlock` with Claude's explanation. These appear because the model invokes bash and text-editor sub-tools inside the container — they are not a CodeExecution-specific block type. Read `response textContent` for the narrative; select for the result blocks when you need the raw outputs or generated artifacts.

**Runnable example**

  ClaudeCodeExecutionExample buildRequest tools first class name
  >>> #ClaudeCodeExecutionTool

  ClaudeCodeExecutionExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testCodeExecutionReturnsOutputSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeCodeExecutionExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeCodeExecutionExample class >> buildRequest [
	"Build a message request with ClaudeCodeExecutionTool configured."
	| params |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addServerTool: ClaudeCodeExecutionTool new.
	params addUserMessage: 'Calculate the first 10 prime numbers using Python.'.
	^ params
]

{ #category : 'private' }
ClaudeCodeExecutionExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeCodeExecutionExample class >> run [
	"Send a code execution request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeCodeExecutionExample class >> runOn: aClient [
	"Send a code execution request using the given client. Returns the response."
	| params |
	params := self buildRequest.
	^ aClient sendMessage: params
]
