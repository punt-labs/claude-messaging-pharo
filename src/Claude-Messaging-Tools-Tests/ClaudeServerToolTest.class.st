"
Tests for ClaudeServerTool abstract base class and infrastructure.

	ClaudeServerToolTest buildSuite run
	>>> a TestResult (0 failures, 0 errors)
"
Class {
	#name : 'ClaudeServerToolTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Tools-Tests',
	#package : 'Claude-Messaging-Tools-Tests'
}

{ #category : 'tests' }
ClaudeServerToolTest >> testAddServerToolToRequest [
	"addServerTool: adds a server tool to the request tools list via toolParams accessor."
	| request tool json toolsJson |
	request := ClaudeMessageRequest new.
	request model: 'claude-sonnet-4-20250514'.
	request maxTokens: 1024.
	request addUserMessage: 'Hello'.
	tool := ClaudeServerTool new.
	tool toolType: 'web_search_20250305'.
	tool toolName: 'web_search'.
	request addServerTool: tool.
	json := request asJson.
	toolsJson := json at: 'tools'.
	self assert: toolsJson size equals: 1.
	self assert: (toolsJson first at: 'type') equals: 'web_search_20250305'.
	self assert: (toolsJson first at: 'name') equals: 'web_search'
]

{ #category : 'tests' }
ClaudeServerToolTest >> testAsJsonMinimal [
	"Minimal server tool produces type and name keys only, no config."
	| tool json |
	tool := ClaudeServerTool new.
	tool toolType: 'web_search_20250305'.
	tool toolName: 'web_search'.
	json := tool asJson.
	self assert: (json at: 'type') equals: 'web_search_20250305'.
	self assert: (json at: 'name') equals: 'web_search'.
	self assert: json size equals: 2
]

{ #category : 'tests' }
ClaudeServerToolTest >> testBaseParamsAbsentWhenNil [
	"Base params are not serialized when nil."
	| tool json |
	tool := ClaudeServerTool new.
	tool toolType: 'bash_20250124'.
	tool toolName: 'bash'.
	json := tool asJson.
	self deny: (json includesKey: 'defer_loading').
	self deny: (json includesKey: 'strict').
	self deny: (json includesKey: 'allowed_callers').
	self deny: (json includesKey: 'input_examples').
	self deny: (json includesKey: 'cache_control')
]

{ #category : 'tests' }
ClaudeServerToolTest >> testBaseParamsSerializeWhenSet [
	"Base params appear in JSON when set to non-nil values."
	| tool json |
	tool := ClaudeServerTool new.
	tool toolType: 'bash_20250124'.
	tool toolName: 'bash'.
	tool deferLoading: true.
	tool strict: false.
	tool allowedCallers: #('user' 'tool').
	tool cacheControl: ClaudeCacheControl ephemeral.
	json := tool asJson.
	self assert: (json at: 'defer_loading') equals: true.
	self assert: (json at: 'strict') equals: false.
	self assert: (json at: 'allowed_callers') equals: #('user' 'tool').
	self assert: ((json at: 'cache_control') at: 'type') equals: 'ephemeral'
]

{ #category : 'tests' }
ClaudeServerToolTest >> testDefaultTypeAndName [
	"Abstract class returns empty strings for defaultType and defaultName."
	self assert: ClaudeServerTool defaultType equals: ''.
	self assert: ClaudeServerTool defaultName equals: ''
]

{ #category : 'tests' }
ClaudeServerToolTest >> testFromJsonRoundTrip [
	"Register a mock entry, round-trip through asJson/fromJson:."
	| tool json restored saved |
	"Save and temporarily override the web_search registration for round-trip testing"
	saved := ClaudeServerTool typeRegistry at: 'web_search' ifAbsent: [ nil ].
	ClaudeServerTool registerType: 'web_search' forClass: ClaudeServerTool.
	[ tool := ClaudeServerTool new.
	  tool toolType: 'web_search_20250305'.
	  tool toolName: 'web_search'.
	  tool deferLoading: true.
	  tool strict: false.
	  json := tool asJson.
	  restored := ClaudeServerTool fromJson: json.
	  self assert: restored toolType equals: 'web_search_20250305'.
	  self assert: restored toolName equals: 'web_search'.
	  self assert: restored deferLoading equals: true.
	  self assert: restored strict equals: false
	] ensure: [
	  saved
	    ifNil: [ ClaudeServerTool typeRegistry removeKey: 'web_search' ifAbsent: [] ]
	    ifNotNil: [ ClaudeServerTool registerType: 'web_search' forClass: saved ] ]
]

{ #category : 'tests' }
ClaudeServerToolTest >> testInitializeSetsDefaults [
	"initialize pulls from class-side defaultType/defaultName."
	| tool |
	tool := ClaudeServerTool new.
	self assert: tool toolType equals: ''.
	self assert: tool toolName equals: ''
]

{ #category : 'tests' }
ClaudeServerToolTest >> testInputExamplesRoundTrip [
	"inputExamples survives asJson/fromJson: round-trip. Bugbot: populateFromJson: stores raw Dictionaries, so asJson must not call asJson on elements."
	| tool json restored saved examples |
	saved := ClaudeServerTool typeRegistry at: 'web_search' ifAbsent: [ nil ].
	ClaudeServerTool registerType: 'web_search' forClass: ClaudeServerTool.
	[
	  examples := {
	    Dictionary new at: 'input' put: (Dictionary new at: 'query' put: 'weather'; yourself); yourself.
	    Dictionary new at: 'input' put: (Dictionary new at: 'query' put: 'stocks'; yourself); yourself
	  }.
	  tool := ClaudeServerTool new.
	  tool toolType: 'web_search_20250305'.
	  tool toolName: 'web_search'.
	  tool inputExamples: examples.
	  json := tool asJson.
	  "First trip: asJson should include input_examples"
	  self assert: (json at: 'input_examples') size equals: 2.
	  "Round trip: fromJson: then asJson again should not crash"
	  restored := ClaudeServerTool fromJson: json.
	  self assert: restored inputExamples size equals: 2.
	  self assert: ((restored inputExamples first at: 'input') at: 'query') equals: 'weather'.
	  "Second trip: re-serialize the restored tool"
	  self assert: (restored asJson at: 'input_examples') size equals: 2
	] ensure: [
	  saved
	    ifNil: [ ClaudeServerTool typeRegistry removeKey: 'web_search' ifAbsent: [] ]
	    ifNotNil: [ ClaudeServerTool registerType: 'web_search' forClass: saved ] ]
]

{ #category : 'tests' }
ClaudeServerToolTest >> testMixedUserAndServerTools [
	"User tools (ClaudeTool) and server tools coexist in the same tools[] array."
	| request userTool serverTool json toolsJson |
	request := ClaudeMessageRequest new.
	request model: 'claude-sonnet-4-20250514'.
	request maxTokens: 1024.
	request addUserMessage: 'Hello'.
	userTool := ClaudeTool
		name: 'getWeather'
		description: 'Get weather'
		inputSchema: ClaudeToolInputSchema new.
	serverTool := ClaudeServerTool new.
	serverTool toolType: 'web_search_20250305'.
	serverTool toolName: 'web_search'.
	request tools: (OrderedCollection with: userTool with: serverTool).
	json := request asJson.
	toolsJson := json at: 'tools'.
	self assert: toolsJson size equals: 2.
	"User tool has name + description + input_schema"
	self assert: (toolsJson first at: 'name') equals: 'getWeather'.
	self assert: (toolsJson first includesKey: 'description').
	"Server tool has type + name, no description"
	self assert: (toolsJson second at: 'type') equals: 'web_search_20250305'.
	self assert: (toolsJson second at: 'name') equals: 'web_search'.
	self deny: (toolsJson second includesKey: 'description')
]

{ #category : 'tests' }
ClaudeServerToolTest >> testPopulateFromJsonRestoresCacheControl [
	"populateFromJson: restores cache_control from nested dict."
	| dict tool |
	dict := Dictionary new.
	dict at: 'type' put: 'memory_20250818'.
	dict at: 'name' put: 'memory'.
	dict at: 'cache_control' put: (Dictionary new at: 'type' put: 'ephemeral'; yourself).
	tool := ClaudeServerTool new.
	tool populateFromJson: dict.
	self assert: tool cacheControl type equals: 'ephemeral'
]

{ #category : 'tests' }
ClaudeServerToolTest >> testPrintOn [
	"printOn: shows the tool name."
	| tool |
	tool := ClaudeServerTool new.
	tool toolName: 'web_search'.
	self assert: tool printString equals: 'a ClaudeServerTool(web_search)'
]

{ #category : 'tests' }
ClaudeServerToolTest >> testTypeRegistryIsDictionary [
	"The type registry is a Dictionary. Concrete subclasses register in subsequent beads."
	self assert: ClaudeServerTool typeRegistry class equals: Dictionary.
	"Registry may have entries from testFromJsonRoundTrip cleanup, so just check it is a Dictionary"
]

{ #category : 'tests' }
ClaudeServerToolTest >> testUnknownNameReturnsNil [
	"fromJson: returns nil for unknown tool names (forward compatibility)."
	| result |
	result := ClaudeServerTool fromJson: (Dictionary new at: 'name' put: 'nonexistent_tool_99'; yourself).
	self assert: result isNil
]
