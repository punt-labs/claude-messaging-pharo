"
Tests for ClaudeStreamingExample. Verifies that the example streams a response and accumulates the message.

  ClaudeStreamingExampleTest buildSuite run
  >>> 4 run, 4 passed, 0 failed, 0 errors

"
Class {
	#name : 'ClaudeStreamingExampleTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'running' }
ClaudeStreamingExampleTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient
		apiKey: 'test-key'
		baseUrl: 'http://localhost:', mockServer port printString
		timeout: 5
]

{ #category : 'fixtures' }
ClaudeStreamingExampleTest >> streamingSseBody [
	^ 'event: message_start
data: {"type":"message_start","message":{"id":"msg_01","type":"message","role":"assistant","content":[],"model":"claude-sonnet-4-5","stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":15,"output_tokens":0}}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Messages"}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" passing"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_delta
data: {"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":5}}

event: message_stop
data: {"type":"message_stop"}

'
]

{ #category : 'running' }
ClaudeStreamingExampleTest >> tearDown [
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeStreamingExampleTest >> testClassExists [
	self assert: (Smalltalk hasClassNamed: #ClaudeStreamingExample)
]

{ #category : 'tests' }
ClaudeStreamingExampleTest >> testRespondsToExampleCode [
	self assert: (ClaudeStreamingExample respondsTo: #exampleCode)
]

{ #category : 'tests' }
ClaudeStreamingExampleTest >> testRespondsToRunOn [
	self assert: (ClaudeStreamingExample respondsTo: #runOn:)
]

{ #category : 'tests' }
ClaudeStreamingExampleTest >> testStreaming [
	| message |
	mockServer
		respondTo: '/v1/messages'
		withSSE: self streamingSseBody.
	message := ClaudeStreamingExample runOn: client.
	self assert: message textContent equals: 'Messages passing'.
	self assert: message stopReason equals: #end_turn
]
