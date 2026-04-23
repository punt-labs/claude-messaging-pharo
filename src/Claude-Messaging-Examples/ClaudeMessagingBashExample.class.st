"
I demonstrate Claude's bash server tool — when enabled, Claude can execute shell commands on Anthropic's sandboxed infrastructure during a conversation turn and incorporate the output into its answer.

**When to use this tool**

Reach for `ClaudeBashTool` when you want Claude to run a shell command on Anthropic's side — listing files, running a one-shot script, invoking a CLI utility. The container is short-lived and isolated; it is not your local shell. When you need a Python container with persistent files and matplotlib (notebook-style work), use `ClaudeCodeExecutionTool` instead. For shell commands run on YOUR machine via the in-image agent, use the local `BashCommand` in `Claude-Agent-Commands`, which is policy-gated and audit-logged.

**What comes back**

A successful turn produces a `ClaudeBashResultBlock` (stdout/stderr/return code) in the response content, followed by a `ClaudeTextBlock` with Claude's summary. Select for the result block when you need the raw command output.

**Runnable example**

  ClaudeMessagingBashExample buildRequest tools first class name
  >>> #ClaudeBashTool

  ClaudeMessagingBashExample buildRequest model
  >>> 'claude-sonnet-4-6'

See `ClaudeServerToolIntegrationTest>>testBashExecutesCommandSonnet` for end-to-end live coverage.
"
Class {
	#name : 'ClaudeMessagingBashExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingBashExample class >> buildRequest [
	"Build a message request with ClaudeBashTool configured.
	 Mirrors the integration test scenario."
	| params |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addServerTool: ClaudeBashTool new.
	params addUserMessage: 'Run `echo hello world` and tell me what it printed.'.
	^ params
]

{ #category : 'private' }
ClaudeMessagingBashExample class >> resolveClient [
	"Delegate to ClaudeSDKExampleSupport for keyring + env-based key resolution."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingBashExample class >> run [
	"Send a bash request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingBashExample class >> runOn: aClient [
	"Send a bash request using the given client. Returns the response."
	^ aClient sendMessage: self buildRequest
]
