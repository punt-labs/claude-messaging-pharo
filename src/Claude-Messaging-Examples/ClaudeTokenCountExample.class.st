"
Count tokens for a message before sending it. Uses countTokens: to get the input token count without making a full API call.

Examples to learn from:

  ClaudeTokenCountExample exampleCode lines first
  >>> 'runOn: aClient'

  (ClaudeTokenCountExample exampleCode includesSubstring: 'countTokens:')
  >>> true

"
Class {
	#name : 'ClaudeTokenCountExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'accessing' }
ClaudeTokenCountExample class >> exampleCode [
	"Return the source code of this example as a string for documentation."
	^ (self class >> #runOn:) sourceCode
]

{ #category : 'examples' }
ClaudeTokenCountExample class >> run [
	"Count tokens for a message and return the input token count."
	^ self runOn: ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeTokenCountExample class >> runOn: aClient [
	"Count tokens using the given client. Returns the input token count as an integer."
	| params tokenCount |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addUserMessage: 'What is the meaning of life?'.
	tokenCount := aClient countTokens: params.
	^ tokenCount inputTokens
]
