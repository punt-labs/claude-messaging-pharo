"
A server-side code execution tool for the Claude Messages API. Enables Claude to execute code in a sandboxed environment during a conversation turn.

No tool-specific config params beyond the inherited base (deferLoading, strict, allowedCallers, inputExamples, cacheControl).

  ClaudeCodeExecutionTool new asJson at: 'type'
  >>> 'code_execution_20250825'

  ClaudeCodeExecutionTool new asJson at: 'name'
  >>> 'code_execution'

  ClaudeCodeExecutionTool new asJson size
  >>> 2

"
Class {
	#name : 'ClaudeCodeExecutionTool',
	#superclass : 'ClaudeServerTool',
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeCodeExecutionTool class >> defaultName [
  ^ 'code_execution'
]

{ #category : 'class initialization' }
ClaudeCodeExecutionTool class >> defaultType [
  ^ 'code_execution_20250825'
]

{ #category : 'class initialization' }
ClaudeCodeExecutionTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'code_execution' forClass: self
]
