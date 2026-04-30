Extension { #name : 'Object' }

{ #category : '*Claude-Messaging-Types' }
Object >> isClaudeContainerParams [
	"Polymorphic predicate. Subclasses that ARE ClaudeContainerParams override
	 to answer true. Used by ClaudeRequestOptions>>container: to validate
	 input without sending #isKindOf:."
	^ false
]
