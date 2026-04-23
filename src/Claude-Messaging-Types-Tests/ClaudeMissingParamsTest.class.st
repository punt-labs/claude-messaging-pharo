"
Tests for new API parameters: inferenceGeo, container, speed on ClaudeRequestOptions, strict on ClaudeTool, and inferenceGeo on ClaudeUsage.

  ClaudeMissingParamsTest buildSuite run
  >>> 7 ran, 7 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected

"
Class {
	#name : 'ClaudeMissingParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMissingParamsTest >> testContainerSerializes [
	| req json |
	req := ClaudeMessageRequest new model: 'test'; maxTokens: 100.
	req container: 'ctr_abc123'.
	json := req asJson.
	self assert: (json at: 'container') equals: 'ctr_abc123'
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testInferenceGeoInUsage [
	| json usage |
	json := Dictionary new.
	json at: 'input_tokens' put: 100.
	json at: 'output_tokens' put: 50.
	json at: 'inference_geo' put: 'eu'.
	usage := ClaudeUsage fromJson: json.
	self assert: usage inferenceGeo equals: 'eu'
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testInferenceGeoSerializes [
	| req json |
	req := ClaudeMessageRequest new model: 'test'; maxTokens: 100.
	req inferenceGeo: 'us'.
	json := req asJson.
	self assert: (json at: 'inference_geo') equals: 'us'
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testNilParamsOmitted [
	| req json tool toolJson |
	req := ClaudeMessageRequest new model: 'test'; maxTokens: 100; addUserMessage: 'hi'.
	json := req asJson.
	self deny: (json includesKey: 'inference_geo').
	self deny: (json includesKey: 'container').
	self deny: (json includesKey: 'speed').
	tool := ClaudeTool name: 't' description: 'd' inputSchema: ClaudeToolInputSchema new.
	toolJson := tool asJson.
	self deny: (toolJson includesKey: 'strict')
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testSpeedSerializes [
	| req json |
	req := ClaudeMessageRequest new model: 'test'; maxTokens: 100.
	req speed: 'fast'.
	json := req asJson.
	self assert: (json at: 'speed') equals: 'fast'
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testStrictOnToolRoundTrip [
	| original restored |
	original := ClaudeTool name: 'test' description: 'A test' inputSchema: ClaudeToolInputSchema new.
	original strict: true.
	restored := ClaudeTool fromJson: original asJson.
	self assert: restored strict equals: true
]

{ #category : 'tests' }
ClaudeMissingParamsTest >> testStrictOnToolSerializes [
	| tool json |
	tool := ClaudeTool name: 'test' description: 'A test' inputSchema: ClaudeToolInputSchema new.
	tool strict: true.
	json := tool asJson.
	self assert: (json at: 'strict') equals: true
]
