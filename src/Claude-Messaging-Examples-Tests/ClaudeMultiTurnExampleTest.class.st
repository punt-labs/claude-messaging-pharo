"
Tests for ClaudeMultiTurnExample. Verifies that the example runs a multi-turn conversation and returns the final response.

  ClaudeMultiTurnExampleTest buildSuite run
  >>> 4 run, 4 passed, 0 failed, 0 errors

"
Class {
	#name : 'ClaudeMultiTurnExampleTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'fixtures' }
ClaudeMultiTurnExampleTest >> firstResponseJson [
	^ '{"id":"msg_01","type":"message","role":"assistant","content":[{"type":"text","text":"The capital of France is Paris."}],"model":"claude-sonnet-4-5","stop_reason":"end_turn","usage":{"input_tokens":15,"output_tokens":10}}'
]

{ #category : 'fixtures' }
ClaudeMultiTurnExampleTest >> secondResponseJson [
	^ '{"id":"msg_02","type":"message","role":"assistant","content":[{"type":"text","text":"Paris has a population of about 2.1 million."}],"model":"claude-sonnet-4-5","stop_reason":"end_turn","usage":{"input_tokens":30,"output_tokens":15}}'
]

{ #category : 'running' }
ClaudeMultiTurnExampleTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient
		apiKey: 'test-key'
		baseUrl: 'http://localhost:', mockServer port printString
		timeout: 5
]

{ #category : 'running' }
ClaudeMultiTurnExampleTest >> tearDown [
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeMultiTurnExampleTest >> testClassExists [
	self assert: (Smalltalk hasClassNamed: #ClaudeMultiTurnExample)
]

{ #category : 'tests' }
ClaudeMultiTurnExampleTest >> testMultiTurn [
	| result |
	mockServer
		respondTo: '/v1/messages'
		withSequence: {
			mockServer successResponse: self firstResponseJson.
			mockServer successResponse: self secondResponseJson }.
	result := ClaudeMultiTurnExample runOn: client.
	self assert: result equals: 'Paris has a population of about 2.1 million.'
]

{ #category : 'tests' }
ClaudeMultiTurnExampleTest >> testRespondsToExampleCode [
	self assert: (ClaudeMultiTurnExample respondsTo: #exampleCode)
]

{ #category : 'tests' }
ClaudeMultiTurnExampleTest >> testRespondsToRunOn [
	self assert: (ClaudeMultiTurnExample respondsTo: #runOn:)
]
