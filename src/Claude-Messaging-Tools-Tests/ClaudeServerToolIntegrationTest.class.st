"
Integration tests for server-side tool support. Requires a live API key in PharoKeyring. Excluded from make test by naming convention (IntegrationTest).

Tests are parameterized across models (opus46, sonnet46) for multi-model coverage. Each server tool has one test per model, with shared helper methods for the common assertion logic.

Run manually when validating server tool end-to-end behavior:

  ClaudeServerToolIntegrationTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeServerToolIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'client'
	],
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'configuration' }
ClaudeServerToolIntegrationTest class >> testModels [
  "Models to test for multi-model coverage."
  ^ { ClaudeModel opus46. ClaudeModel sonnet46 }
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertBashWorksOn: aModel [
  | params response hasToolUse |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeBashTool new.
  params addUserMessage: 'Run the command: echo hello world. You must use the bash tool.'.
  response := client sendMessage: params.
  hasToolUse := response content anySatisfy: [ :block |
    block isKindOf: ClaudeToolUseBlock ].
  self assert: hasToolUse description: 'Expected a tool_use block for bash server tool'
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertCodeExecutionWorksOn: aModel [
  | params response hasCodeResult |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeCodeExecutionTool new.
  params addUserMessage: 'Write a Python script that prints hello world and run it. You must use the code_execution tool.'.
  response := client sendMessage: params.
  hasCodeResult := response content anySatisfy: [ :block |
    (block isKindOf: ClaudeBashResultBlock) or: [ block isKindOf: ClaudeTextEditorResultBlock ] ].
  self assert: hasCodeResult description: 'Expected at least one ClaudeBashResultBlock or ClaudeTextEditorResultBlock'.
  self assert: response textContent isNotEmpty
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertMemoryWorksOn: aModel [
  | params response |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeMemoryTool new.
  params addUserMessage: 'Remember that my favorite color is blue. You must use the memory tool.'.
  response := client sendMessage: params.
  self assert: response content isNotEmpty description: 'Expected a non-empty response'
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertTextEditorWorksOn: aModel [
  | params response |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeTextEditorTool new.
  params addUserMessage: 'Create a file called /tmp/test.txt containing hello world. You must use the str_replace_based_edit_tool.'.
  response := client sendMessage: params.
  self assert: response content isNotEmpty description: 'Expected a non-empty response'
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertToolSearchBm25WorksOn: aModel [
  | params response |
  params := self toolSearchParamsFor: aModel withServerTool: ClaudeToolSearchBm25Tool new.
  response := client sendMessage: params.
  self assert: response content isNotEmpty description: 'Expected a non-empty response'
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertToolSearchRegexWorksOn: aModel [
  | params response |
  params := self toolSearchParamsFor: aModel withServerTool: ClaudeToolSearchRegexTool new.
  response := client sendMessage: params.
  self assert: response content isNotEmpty description: 'Expected a non-empty response'
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertWebFetchWorksOn: aModel [
  | params response hasFetchResult |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeWebFetchTool new.
  params addUserMessage: 'Fetch the content at https://httpbin.org/html and summarize it. You must use the web_fetch tool.'.
  response := client sendMessage: params.
  hasFetchResult := response content anySatisfy: [ :block |
    block isKindOf: ClaudeWebFetchResultBlock ].
  self assert: hasFetchResult description: 'Expected at least one ClaudeWebFetchResultBlock'.
  self assert: response textContent isNotEmpty
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> assertWebSearchWorksOn: aModel [
  | params response hasSearchResult |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  params addServerTool: ClaudeWebSearchTool new.
  params addUserMessage: 'Search the web for the latest Pharo Smalltalk release news. You must use the web_search tool.'.
  response := client sendMessage: params.
  hasSearchResult := response content anySatisfy: [ :block |
    block isKindOf: ClaudeWebSearchResultBlock ].
  self assert: hasSearchResult description: 'Expected at least one ClaudeWebSearchResultBlock'.
  self assert: response textContent isNotEmpty
]

{ #category : 'running' }
ClaudeServerToolIntegrationTest >> defaultTimeLimit [
  "Integration tests make real API calls. Allow 2 minutes per test."
  ^ 2 minutes
]

{ #category : 'running' }
ClaudeServerToolIntegrationTest >> setUp [
  | key |
  super setUp.
  key := [ PharoKeyring default lookup: 'anthropic-api' account: 'default' ]
    on: Error do: [ :e | nil ].
  self assert: key isNotNil description: 'No API key -- set anthropic-api-key in PharoKeyring'.
  client := ClaudeClient apiKey: key
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testBashExecutesCommandOpus [
  <timeout: 60>
  self assertBashWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testBashExecutesCommandSonnet [
  <timeout: 60>
  self assertBashWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testCodeExecutionReturnsOutputOpus [
  <timeout: 120>
  self assertCodeExecutionWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testCodeExecutionReturnsOutputSonnet [
  <timeout: 120>
  self assertCodeExecutionWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testMemoryStoresInformationOpus [
  <timeout: 60>
  self assertMemoryWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testMemoryStoresInformationSonnet [
  <timeout: 60>
  self assertMemoryWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testTextEditorEditsFileOpus [
  <timeout: 60>
  self assertTextEditorWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testTextEditorEditsFileSonnet [
  <timeout: 60>
  self assertTextEditorWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testToolSearchBm25FindsToolsOpus [
  <timeout: 60>
  self assertToolSearchBm25WorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testToolSearchBm25FindsToolsSonnet [
  <timeout: 60>
  self assertToolSearchBm25WorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testToolSearchRegexFindsToolsOpus [
  <timeout: 60>
  self assertToolSearchRegexWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testToolSearchRegexFindsToolsSonnet [
  <timeout: 60>
  self assertToolSearchRegexWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testWebFetchRetrievesPageOpus [
  <timeout: 120>
  self assertWebFetchWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testWebFetchRetrievesPageSonnet [
  <timeout: 120>
  self assertWebFetchWorksOn: ClaudeModel sonnet46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testWebSearchReturnsResultsOpus [
  <timeout: 120>
  self assertWebSearchWorksOn: ClaudeModel opus46
]

{ #category : 'tests-integration' }
ClaudeServerToolIntegrationTest >> testWebSearchReturnsResultsSonnet [
  <timeout: 120>
  self assertWebSearchWorksOn: ClaudeModel sonnet46
]

{ #category : 'helpers' }
ClaudeServerToolIntegrationTest >> toolSearchParamsFor: aModel withServerTool: aServerTool [
  "Build a request with weather+calc tools and a tool search server tool."
  | params weatherTool calcTool |
  params := ClaudeMessageRequest new.
  params model: aModel.
  params maxTokens: 1024.
  weatherTool := ClaudeTool new.
  weatherTool name: 'get_weather'.
  weatherTool description: 'Get the current weather for a location'.
  weatherTool inputSchema: (ClaudeToolInputSchema new
    properties: { 'location' -> { 'type' -> 'string' } asDictionary } asDictionary;
    required: #('location')).
  calcTool := ClaudeTool new.
  calcTool name: 'calculate'.
  calcTool description: 'Evaluate a math expression'.
  calcTool inputSchema: (ClaudeToolInputSchema new
    properties: { 'expression' -> { 'type' -> 'string' } asDictionary } asDictionary;
    required: #('expression')).
  params tools: (OrderedCollection withAll: { weatherTool. calcTool }).
  params addServerTool: aServerTool.
  params addUserMessage: 'What is the weather in Paris?'.
  ^ params
]
