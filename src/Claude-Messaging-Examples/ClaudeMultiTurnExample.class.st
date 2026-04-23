"
Demonstrate multi-turn conversation. Send a message, add the assistant response back, then send a follow-up question.

Examples to learn from:

  ClaudeMultiTurnExample exampleCode lines first
  >>> 'runOn: aClient'

  (ClaudeMultiTurnExample exampleCode includesSubstring: 'addAssistantResponse:')
  >>> true

"
Class {
	#name : 'ClaudeMultiTurnExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'accessing' }
ClaudeMultiTurnExample class >> exampleCode [
	"Return the source code of this example as a string for documentation."
	^ (self class >> #runOn:) sourceCode
]

{ #category : 'examples' }
ClaudeMultiTurnExample class >> run [
	"Run a multi-turn conversation and return the final response text."
	^ self runOn: ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMultiTurnExample class >> runOn: aClient [
	"Run a multi-turn conversation using the given client. Returns the final response text."
	| params firstResponse secondResponse |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addUserMessage: 'What is the capital of France?'.
	firstResponse := aClient sendMessage: params.
	params addAssistantResponse: firstResponse.
	params addUserMessage: 'And what is its population?'.
	secondResponse := aClient sendMessage: params.
	^ secondResponse textContent
]
