"
A server-side memory tool for the Claude Messages API. Enables Claude to persist and retrieve information across conversations.

No tool-specific config params beyond the inherited base (deferLoading, strict, allowedCallers, inputExamples, cacheControl).

  ClaudeMemoryTool new asJson at: 'type'
  >>> 'memory_20250818'

  ClaudeMemoryTool new asJson at: 'name'
  >>> 'memory'

  ClaudeMemoryTool new asJson size
  >>> 2

"
Class {
	#name : 'ClaudeMemoryTool',
	#superclass : 'ClaudeServerTool',
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeMemoryTool class >> defaultName [
  ^ 'memory'
]

{ #category : 'class initialization' }
ClaudeMemoryTool class >> defaultType [
  ^ 'memory_20250818'
]

{ #category : 'class initialization' }
ClaudeMemoryTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'memory' forClass: self
]
