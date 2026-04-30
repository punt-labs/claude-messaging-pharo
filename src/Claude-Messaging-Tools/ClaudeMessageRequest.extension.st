Extension { #name : 'ClaudeMessageRequest' }

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addBash [
  "Enable bash tool with default settings."
  self addServerTool: ClaudeBashTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addCodeExecution [
  "Enable code execution with default settings."
  self addServerTool: ClaudeCodeExecutionTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addMemory [
  "Enable memory tool with default settings."
  self addServerTool: ClaudeMemoryTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addServerTool: aClaudeServerTool [
	"Add a server tool to the tools list, creating the list if needed.
	 Promotes a fixed-size Array (from JSON/STON restore) to a mutable
	 OrderedCollection so #add: can succeed.
	 Uses accessor (not direct ivar) since this is an extension method from Claude-Messaging-Tools."
	| tools |
	tools := self toolParams tools.
	tools ifNil: [ tools := OrderedCollection new. self toolParams tools: tools ].
	tools isArray ifTrue: [
		tools := OrderedCollection withAll: tools.
		self toolParams tools: tools ].
	tools add: aClaudeServerTool
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addTextEditor [
  "Enable text editor tool with default settings."
  self addServerTool: ClaudeTextEditorTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addToolSearchBm25 [
  "Enable BM25 tool search with default settings."
  self addServerTool: ClaudeToolSearchBm25Tool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addToolSearchRegex [
  "Enable regex tool search with default settings."
  self addServerTool: ClaudeToolSearchRegexTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addWebFetch [
  "Enable web fetch with default settings."
  self addServerTool: ClaudeWebFetchTool new
]

{ #category : '*Claude-Messaging-Tools' }
ClaudeMessageRequest >> addWebSearch [
  "Enable web search with default settings."
  self addServerTool: ClaudeWebSearchTool new
]
