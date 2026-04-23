"
Abstract base for content blocks in Claude API messages. Each subclass represents a different block type (text, tool_use, tool_result, thinking, image, etc.). The class-side fromJson: dispatches on the type field to create the correct subclass. Unknown types produce an instance of this class with the raw JSON stored for forward compatibility.

### Examples

```
ClaudeContentBlock fromJson: (Dictionary newFromPairs: #('type' 'text' 'text' 'hello'))
>>> a ClaudeTextBlock
```

"
Class {
	#name : 'ClaudeContentBlock',
	#superclass : 'Object',
	#instVars : [
		'type',
		'rawJson'
	],
	#classVars : [
		'TypeRegistry'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeContentBlock class >> fromJson: aDictionary [
	| typeName subclass |
	typeName := aDictionary at: 'type' ifAbsent: [ nil ].
	subclass := self typeRegistry at: typeName ifAbsent: [ nil ].
	subclass ifNotNil: [ ^ subclass fromJson: aDictionary ].
	^ self rawFromJson: aDictionary
]

{ #category : 'class initialization' }
ClaudeContentBlock class >> initialize [
  TypeRegistry := {
    'text' -> ClaudeTextBlock.
    'tool_use' -> ClaudeToolUseBlock.
    'tool_result' -> ClaudeToolResultBlock.
    'thinking' -> ClaudeThinkingBlock.
    'redacted_thinking' -> ClaudeRedactedThinkingBlock.
    'image' -> ClaudeImageBlock.
    'document' -> ClaudeDocumentBlock.
    'server_tool_use' -> ClaudeServerToolUseBlock.
    'web_search_tool_result' -> ClaudeWebSearchResultBlock.
    'web_fetch_tool_result' -> ClaudeWebFetchResultBlock.
    'code_execution_tool_result' -> ClaudeCodeExecutionResultBlock.
    'bash_code_execution_tool_result' -> ClaudeBashResultBlock.
    'text_editor_code_execution_tool_result' -> ClaudeTextEditorResultBlock.
    'tool_search_tool_result' -> ClaudeToolSearchResultBlock.
    'container_upload' -> ClaudeContainerUploadBlock.
    'compaction' -> ClaudeCompactionBlock.
    'mcp_tool_use' -> ClaudeMCPToolUseBlock.
    'mcp_tool_result' -> ClaudeMCPToolResultBlock
  } asDictionary
]

{ #category : 'json' }
ClaudeContentBlock class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'instance creation' }
ClaudeContentBlock class >> rawFromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ nil ]);
		rawJson: aDictionary copy;
		yourself
]

{ #category : 'json' }
ClaudeContentBlock class >> typeRegistry [
	^ TypeRegistry ifNil: [ self initialize. TypeRegistry ]
]

{ #category : 'streaming' }
ClaudeContentBlock >> applyDelta: aDeltaDict [
	"Default: ignore unknown deltas."
]

{ #category : 'json' }
ClaudeContentBlock >> asJson [
	"For unknown/raw blocks, return the stored raw JSON"
	^ rawJson ifNil: [
		OrderedDictionary new
			at: 'type' put: type;
			yourself ]
]

{ #category : 'converting' }
ClaudeContentBlock >> asParam [
	^ self asJson
]

{ #category : 'streaming' }
ClaudeContentBlock >> finalizeAfterStreaming [
	"Default: no finalization needed. Subclasses that accumulate streaming
	data into a transient form (e.g., partial JSON strings via applyDelta:)
	override to finalize that form into the wire shape (e.g., parsed Dictionary).
	Called by ClaudeMessage>>handleContentBlockStop: when the content_block_stop
	SSE event arrives." 
]

{ #category : 'testing' }
ClaudeContentBlock >> isDocumentBlock [
	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isMCPToolResultBlock [
	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isMCPToolUseBlock [
	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isTextBlock [
	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isThinkingBlock [
	"Polymorphic predicate. Default false. Overridden in ClaudeThinkingBlock.
	 Completes the isTextBlock / isToolUseBlock / isToolResultBlock /
	 isMCPToolUseBlock / isMCPToolResultBlock / isDocumentBlock family."

	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isToolResultBlock [
	^ false
]

{ #category : 'testing' }
ClaudeContentBlock >> isToolUseBlock [
	^ false
]

{ #category : 'accessing' }
ClaudeContentBlock >> rawJson [
	^ rawJson
]

{ #category : 'accessing' }
ClaudeContentBlock >> rawJson: aDictionary [
	rawJson := aDictionary
]

{ #category : 'accessing' }
ClaudeContentBlock >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeContentBlock >> type: aString [
	type := aString
]
