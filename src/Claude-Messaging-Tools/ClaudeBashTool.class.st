"
A server-side bash tool for the Claude Messages API. Enables Claude to execute bash commands on Anthropic servers during a conversation turn.

No tool-specific config params beyond the inherited base (deferLoading, strict, allowedCallers, inputExamples, cacheControl).

  ClaudeBashTool new asJson at: 'type'
  >>> 'bash_20250124'

  ClaudeBashTool new asJson at: 'name'
  >>> 'bash'

  ClaudeBashTool new asJson size
  >>> 2

"
Class {
	#name : 'ClaudeBashTool',
	#superclass : 'ClaudeServerTool',
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeBashTool class >> defaultName [
  ^ 'bash'
]

{ #category : 'class initialization' }
ClaudeBashTool class >> defaultType [
  ^ 'bash_20250124'
]

{ #category : 'class initialization' }
ClaudeBashTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'bash' forClass: self
]
