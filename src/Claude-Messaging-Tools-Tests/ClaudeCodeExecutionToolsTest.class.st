"
Tests for ClaudeCodeExecutionTool, ClaudeBashTool, and ClaudeTextEditorTool server-side tools.

  ClaudeCodeExecutionToolsTest buildSuite run
  >>> a TestResult (0 failures, 0 errors)

"
Class {
	#name : 'ClaudeCodeExecutionToolsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testBashDefaultJson [
  "Default bash tool produces type and name keys only."
  | tool json |
  tool := ClaudeBashTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'bash_20250124'.
  self assert: (json at: 'name') equals: 'bash'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testBashFromJsonRoundTrip [
  "asJson then fromJson: reconstructs bash tool with base params."
  | tool json restored |
  tool := ClaudeBashTool new.
  tool strict: true.
  tool allowedCallers: #('user').
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeBashTool.
  self assert: restored toolType equals: 'bash_20250124'.
  self assert: restored toolName equals: 'bash'.
  self assert: restored strict equals: true.
  self assert: restored allowedCallers equals: #('user')
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testCodeExecutionDefaultJson [
  "Default code execution tool produces type and name keys only."
  | tool json |
  tool := ClaudeCodeExecutionTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'code_execution_20250825'.
  self assert: (json at: 'name') equals: 'code_execution'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testCodeExecutionWithBaseParams [
  "Base params (deferLoading, strict) serialize on code execution when set."
  | tool json |
  tool := ClaudeCodeExecutionTool new.
  tool deferLoading: true.
  tool strict: false.
  json := tool asJson.
  self assert: (json at: 'defer_loading') equals: true.
  self assert: (json at: 'strict') equals: false.
  self assert: (json at: 'type') equals: 'code_execution_20250825'.
  self assert: json size equals: 4
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testConvenienceMethods [
  "addCodeExecution, addBash, addTextEditor add tools to the request."
  | request json toolsJson |
  request := ClaudeMessageRequest new.
  request model: 'claude-sonnet-4-20250514'.
  request maxTokens: 1024.
  request addUserMessage: 'Hello'.
  request addCodeExecution.
  request addBash.
  request addTextEditor.
  json := request asJson.
  toolsJson := json at: 'tools'.
  self assert: toolsJson size equals: 3.
  self assert: (toolsJson first at: 'type') equals: 'code_execution_20250825'.
  self assert: (toolsJson first at: 'name') equals: 'code_execution'.
  self assert: (toolsJson second at: 'type') equals: 'bash_20250124'.
  self assert: (toolsJson second at: 'name') equals: 'bash'.
  self assert: (toolsJson third at: 'type') equals: 'text_editor_20250728'.
  self assert: (toolsJson third at: 'name') equals: 'str_replace_based_edit_tool'
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testTextEditorDefaultJson [
  "Default text editor tool produces type and name keys only."
  | tool json |
  tool := ClaudeTextEditorTool new.
  json := tool asJson.
  self assert: (json at: 'type') equals: 'text_editor_20250728'.
  self assert: (json at: 'name') equals: 'str_replace_based_edit_tool'.
  self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testTextEditorFromJsonRoundTrip [
  "asJson then fromJson: reconstructs maxCharacters on text editor."
  | tool json restored |
  tool := ClaudeTextEditorTool new.
  tool maxCharacters: 75000.
  tool deferLoading: true.
  json := tool asJson.
  restored := ClaudeServerTool fromJson: json.
  self assert: restored class equals: ClaudeTextEditorTool.
  self assert: restored toolType equals: 'text_editor_20250728'.
  self assert: restored toolName equals: 'str_replace_based_edit_tool'.
  self assert: restored maxCharacters equals: 75000.
  self assert: restored deferLoading equals: true
]

{ #category : 'tests' }
ClaudeCodeExecutionToolsTest >> testTextEditorWithMaxCharacters [
  "maxCharacters serializes when set."
  | tool json |
  tool := ClaudeTextEditorTool new.
  tool maxCharacters: 50000.
  json := tool asJson.
  self assert: (json at: 'max_characters') equals: 50000.
  self assert: (json at: 'type') equals: 'text_editor_20250728'.
  self assert: json size equals: 3
]
