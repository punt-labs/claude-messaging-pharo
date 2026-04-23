"
Buffered streaming via ``ClaudeClient >> streamMessage:do:``: the block is called once per Server-Sent Event, the method returns the fully accumulated ``ClaudeMessage`` after the stream closes. Contrast with ``ClaudeMessagingRawStreamingExample`` which opens a raw TLS socket for event-by-event control.

### When you use it

``streamMessage:do:`` is the right choice for almost every streaming use case: you get one event at a time (``message_start``, ``content_block_delta``, ``content_block_stop``, ``message_stop``, ...), the socket lifecycle is handled for you, and the return value is the same kind of ``ClaudeMessage`` a non-streaming call would give back. Use ``ClaudeMessagingRawStreamingExample`` when you need to interleave reads with other work, cancel mid-stream, or inspect lower-level framing. Use this example when you just want text to appear as Claude emits it.

### Sibling examples

- ``ClaudeSimpleMessageExample`` -- non-streaming: one request, one ``ClaudeMessage`` back
- ``ClaudeStreamingExample`` -- this class; buffered streaming via ``streamMessage:do:``
- ``ClaudeMessagingRawStreamingExample`` -- raw TLS socket + ``ClaudeSSEDecoder`` for event-by-event control

### Example

```
ClaudeStreamingExample exampleCode lines first
>>> 'runOn: aClient'
```

```
(ClaudeStreamingExample exampleCode includesSubstring: 'streamMessage:')
>>> true
```

### See also

``ClaudeClient >> streamMessage:do:`` -- the API entry demonstrated here. ``ClaudeMessagingRawStreamingExample`` -- the lower-level companion. ``ClaudeRawStreamingIntegrationTest`` -- live regression guard for ``runOn:`` of the raw sibling.

"
Class {
	#name : 'ClaudeStreamingExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'accessing' }
ClaudeStreamingExample class >> exampleCode [
	"Return the source code of this example as a string for documentation."
	^ (self class >> #runOn:) sourceCode
]

{ #category : 'examples' }
ClaudeStreamingExample class >> run [
	"Stream a response, collecting text deltas into a string. Returns the accumulated text."
	^ self runOn: ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeStreamingExample class >> runOn: aClient [
	"Stream a response using the given client. Returns the accumulated ClaudeMessage."
	| params events message |
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet46.
	params maxTokens: 1024.
	params addUserMessage: 'Write a haiku about Smalltalk.'.
	events := OrderedCollection new.
	message := aClient streamMessage: params do: [ :event |
		events add: event ].
	^ message
]
