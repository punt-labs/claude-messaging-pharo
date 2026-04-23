"
Tests for ClaudeTokenCountExample. Verifies that the example counts tokens and returns the input token count.

  ClaudeTokenCountExampleTest buildSuite run
  >>> 4 run, 4 passed, 0 failed, 0 errors

"
Class {
	#name : 'ClaudeTokenCountExampleTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'running' }
ClaudeTokenCountExampleTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient
		apiKey: 'test-key'
		baseUrl: 'http://localhost:', mockServer port printString
		timeout: 5
]

{ #category : 'running' }
ClaudeTokenCountExampleTest >> tearDown [
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeTokenCountExampleTest >> testClassExists [
	self assert: (Smalltalk hasClassNamed: #ClaudeTokenCountExample)
]

{ #category : 'tests' }
ClaudeTokenCountExampleTest >> testRespondsToExampleCode [
	self assert: (ClaudeTokenCountExample respondsTo: #exampleCode)
]

{ #category : 'tests' }
ClaudeTokenCountExampleTest >> testRespondsToRunOn [
	self assert: (ClaudeTokenCountExample respondsTo: #runOn:)
]

{ #category : 'tests' }
ClaudeTokenCountExampleTest >> testTokenCount [
	| result |
	mockServer
		respondTo: '/v1/messages/count_tokens'
		with: self tokenCountResponseJson.
	result := ClaudeTokenCountExample runOn: client.
	self assert: result equals: 42
]

{ #category : 'fixtures' }
ClaudeTokenCountExampleTest >> tokenCountResponseJson [
	^ '{"input_tokens":42}'
]
