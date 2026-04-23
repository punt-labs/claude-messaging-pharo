"
Tests for ClaudeToolParams — tools, toolChoice, disableParallelToolUse serialization.
"
Class {
	#name : 'ClaudeToolParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeToolParamsTest >> testToolParamsAddFieldsTo [
	| tp dict schema tool |
	schema := ClaudeToolInputSchema new
		addProperty: 'x' type: 'string' description: 'test';
		yourself.
	tool := ClaudeTool name: 'test' description: 'test' inputSchema: schema.
	tp := ClaudeToolParams new.
	tp tools: (OrderedCollection with: tool).
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	self assert: (dict at: 'tools') size equals: 1.
	self deny: (dict includesKey: 'tool_choice')
]

{ #category : 'tests' }
ClaudeToolParamsTest >> testToolParamsDisableParallelToolUse [
	"Test that disableParallelToolUse is properly serialized to JSON"
	| tp dict |
	tp := ClaudeToolParams new.
	tp disableParallelToolUse: true.
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	self assert: (dict at: 'disable_parallel_tool_use') equals: true.
	
	tp := ClaudeToolParams new.
	tp disableParallelToolUse: false.
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	self assert: (dict at: 'disable_parallel_tool_use') equals: false.
	
	"Test that nil disableParallelToolUse doesn't add field"
	tp := ClaudeToolParams new.
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	self deny: (dict includesKey: 'disable_parallel_tool_use')
]

{ #category : 'tests' }
ClaudeToolParamsTest >> testToolParamsJsonKeyMap [
	| map |
	map := ClaudeToolParams jsonKeyMap.
	self assert: (map at: #toolChoice) equals: 'tool_choice'.
	self assert: (map at: #disableParallelToolUse) equals: 'disable_parallel_tool_use'.
	self assert: map size equals: 2
]

{ #category : 'tests' }
ClaudeToolParamsTest >> testToolsAsJson [
	| params schema tool json toolsJson |
	schema := ClaudeToolInputSchema new
		addProperty: 'city' type: 'string' description: 'City name';
		require: 'city';
		yourself.
	tool := ClaudeTool name: 'GetWeather' description: 'Get weather' inputSchema: schema.
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Weather?'.
	params tools: (OrderedCollection with: tool).
	json := params asJson.
	toolsJson := json at: 'tools'.
	self assert: toolsJson size equals: 1.
	self assert: (toolsJson first at: 'name') equals: 'GetWeather'.
	self assert: (toolsJson first at: 'description') equals: 'Get weather'.
	self assert: ((toolsJson first at: 'input_schema') at: 'type') equals: 'object'
]
