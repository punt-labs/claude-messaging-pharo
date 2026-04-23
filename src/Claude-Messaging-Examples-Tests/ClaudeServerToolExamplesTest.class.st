"
Structural tests for the server-tool example classes (web search, web fetch, code execution, bash, text editor, memory, tool search BM25 + regex) plus the MCP and Skills examples. Each test verifies request construction without making API calls — the live wire behaviour lives in `ClaudeServerToolIntegrationTest` (out of scope for `make test`).

Two tests per server-tool example class assert (a) the right tool class is configured and (b) the request uses the canonical `ClaudeModel sonnet46`. The tool-search example carries a third assertion verifying its regex-variant entry point.

  ClaudeServerToolExamplesTest buildSuite tests size
  >>> 20

"
Class {
	#name : 'ClaudeServerToolExamplesTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testBashExampleConfiguresTool [
	| request tools |
	request := ClaudeMessagingBashExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeBashTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testBashExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingBashExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testCodeExecutionExampleConfiguresTool [
	| request tools |
	request := ClaudeCodeExecutionExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeCodeExecutionTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testCodeExecutionExampleUsesCorrectModel [
	| request |
	request := ClaudeCodeExecutionExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testMCPExampleConfiguresServer [
	| request servers |
	request := ClaudeMessagingMCPExample buildRequest.
	servers := request mcpServers.
	self assert: servers size equals: 1.
	self assert: (servers first isKindOf: ClaudeMCPServerDefinition).
	self assert: servers first name equals: 'deepwiki'.
	self assert: servers first toolConfiguration enabled equals: true
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testMCPExampleSetsBetaHeader [
	| request |
	request := ClaudeMessagingMCPExample buildRequest.
	self assert: request requestOptions betaHeader equals: 'mcp-client-2025-04-04'
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testMCPExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingMCPExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testMemoryExampleConfiguresTool [
	| request tools |
	request := ClaudeMessagingMemoryExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeMemoryTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testMemoryExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingMemoryExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testSkillsExampleBuildContainerHasOneCustomSkill [
	| params |
	params := ClaudeMessagingSkillsExample buildContainerWithSkills.
	self assert: params skills size equals: 1.
	self assert: params skills first skillId equals: 'sk_example'.
	self assert: params skills first type equals: 'custom'
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testSkillsExampleExists [
	"Mirror the MCP example structural test pattern: verify the four class-side
	 selectors exist on ClaudeMessagingSkillsExample. These are doctest-safe
	 (no network) and confirm the example class has the expected shape.
	 Note: send respondsTo: to the class itself, NOT to 'class' (the meta-metaclass)."
	self assert: (ClaudeMessagingSkillsExample respondsTo: #buildContainerWithSkills).
	self assert: (ClaudeMessagingSkillsExample respondsTo: #buildSkillUploadDirectory).
	self assert: (ClaudeMessagingSkillsExample respondsTo: #uploadOn:).
	self assert: (ClaudeMessagingSkillsExample respondsTo: #listOn:)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testTextEditorExampleConfiguresTool [
	| request tools |
	request := ClaudeMessagingTextEditorExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeTextEditorTool).
	self assert: tools first maxCharacters equals: 50000
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testTextEditorExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingTextEditorExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testToolSearchExampleConfiguresTool [
	"BM25 default request: two client tools (weather, calculator) + one
	 server-side tool search BM25 tool. Server tool is the LAST entry."
	| request tools |
	request := ClaudeMessagingToolSearchExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 3.
	self assert: (tools last isKindOf: ClaudeToolSearchBm25Tool).
	self assert: tools last maxResults equals: 5
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testToolSearchExampleProvidesRegexVariant [
	"The example offers both BM25 and regex variants. Verify the regex
	 entry point exists AND wires the regex tool class through."
	| request tools |
	self assert: (ClaudeMessagingToolSearchExample respondsTo: #buildRegexRequest).
	request := ClaudeMessagingToolSearchExample buildRegexRequest.
	tools := request tools.
	self assert: tools size equals: 3.
	self assert: (tools last isKindOf: ClaudeToolSearchRegexTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testToolSearchExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingToolSearchExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testWebFetchExampleConfiguresTool [
	| request tools |
	request := ClaudeMessagingWebFetchExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeWebFetchTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testWebFetchExampleUsesCorrectModel [
	| request |
	request := ClaudeMessagingWebFetchExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testWebSearchExampleConfiguresTool [
	| request tools |
	request := ClaudeWebSearchExample buildRequest.
	tools := request tools.
	self assert: tools size equals: 1.
	self assert: (tools first isKindOf: ClaudeWebSearchTool)
]

{ #category : 'tests' }
ClaudeServerToolExamplesTest >> testWebSearchExampleUsesCorrectModel [
	| request |
	request := ClaudeWebSearchExample buildRequest.
	self assert: request model equals: ClaudeModel sonnet46
]
