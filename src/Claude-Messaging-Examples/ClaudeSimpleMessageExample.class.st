"
The simplest possible use of the Messaging SDK: build a ``ClaudeMessageRequest``, send it, read the text back. Start here when you are reading the examples for the first time.

### When you use it

As a reference, more than as production code. The ``run`` selector wires in ``ClaudeSDKExampleSupport resolveClient`` for you so you can ``ClaudeSimpleMessageExample run`` in a Playground and see text come back immediately. The ``runOn:`` variant takes an explicit client so tests can stage one with a specific API key.

The pattern is the same four lines you repeat in every other example: make a ``ClaudeMessageRequest``, set ``model``, set ``maxTokens``, ``addUserMessage:``, then ``client sendMessage:`` and read ``textContent`` off the response.

### Sibling examples

- ``ClaudeSimpleMessageExample`` -- this class; one-shot sendMessage
- ``ClaudeMultiTurnExample`` -- two-turn conversation, showing how to pass the previous response back in
- ``ClaudeStreamingExample`` -- same request shape, but via ``streamMessage:do:`` so tokens arrive incrementally
- ``ClaudeTokenCountExample`` -- the same request shape, but via ``countTokens:`` to get a pre-call estimate

### Example

```
ClaudeSimpleMessageExample exampleCode lines first
>>> 'runOn: aClient'
```

```
(ClaudeSimpleMessageExample exampleCode includesSubstring: 'sendMessage:')
>>> true
```

### See also

``ClaudeClient >> sendMessage:`` -- the API entry demonstrated here. ``ClaudeSDKExampleSupport >> resolveClient`` -- the key resolver used by ``run``.

"
Class {
	#name : 'ClaudeSimpleMessageExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'accessing' }
ClaudeSimpleMessageExample class >> exampleCode [
	"Return the source code of this example as a string for documentation."
	^ (self class >> #runOn:) sourceCode
]

{ #category : 'examples' }
ClaudeSimpleMessageExample class >> run [
	"Send a single message and return the text response."
	^ self runOn: ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeSimpleMessageExample class >> runOn: aClient [
	"Send a single message using the given client. Returns the text content."
	| params response |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addUserMessage: 'What is the capital of France?'.
	response := aClient sendMessage: params.
	^ response textContent
]
