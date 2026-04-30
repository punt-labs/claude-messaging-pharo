Extension { #name : 'Object' }

{ #category : '*Claude-Messaging-Streaming' }
Object >> isClaudeStreamingSocket [
	"Polymorphic predicate. ClaudeStreamingSocket overrides to true.
	 Used by ClaudeClient>>streamMessage:do: and the raw-streaming example
	 to decide whether the socket has a tracked requestId without sending
	 #isKindOf:. Buffered ZnClient streams used in tests answer false."
	^ false
]
