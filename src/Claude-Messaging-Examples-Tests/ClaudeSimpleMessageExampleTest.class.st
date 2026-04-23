"
Tests for ClaudeSimpleMessageExample. Verifies that the example sends a single message and returns the text response.

  ClaudeSimpleMessageExampleTest buildSuite run
  >>> 4 run, 4 passed, 0 failed, 0 errors

"
Class {
	#name : 'ClaudeSimpleMessageExampleTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'running' }
ClaudeSimpleMessageExampleTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient
		apiKey: 'test-key'
		baseUrl: 'http://localhost:', mockServer port printString
		timeout: 5
]

{ #category : 'fixtures' }
ClaudeSimpleMessageExampleTest >> simpleResponseJson [
	^ '{"id":"msg_01","type":"message","role":"assistant","content":[{"type":"text","text":"The capital of France is Paris."}],"model":"claude-sonnet-4-5","stop_reason":"end_turn","usage":{"input_tokens":15,"output_tokens":10}}'
]

{ #category : 'running' }
ClaudeSimpleMessageExampleTest >> tearDown [
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeSimpleMessageExampleTest >> testClassExists [
	self assert: (Smalltalk hasClassNamed: #ClaudeSimpleMessageExample)
]

{ #category : 'tests' }
ClaudeSimpleMessageExampleTest >> testRespondsToExampleCode [
	self assert: (ClaudeSimpleMessageExample respondsTo: #exampleCode)
]

{ #category : 'tests' }
ClaudeSimpleMessageExampleTest >> testRespondsToRunOn [
	self assert: (ClaudeSimpleMessageExample respondsTo: #runOn:)
]

{ #category : 'tests' }
ClaudeSimpleMessageExampleTest >> testSimpleMessage [
	| result |
	mockServer
		respondTo: '/v1/messages'
		with: self simpleResponseJson.
	result := ClaudeSimpleMessageExample runOn: client.
	self assert: result equals: 'The capital of France is Paris.'
]
