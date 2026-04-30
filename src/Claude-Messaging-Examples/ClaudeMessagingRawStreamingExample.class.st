"
Demonstrate raw TLS-socket streaming via ``ClaudeStreamingSocket`` and ``ClaudeSSEDecoder onStream:``. Opens the streaming socket, reads SSE events incrementally, and accumulates them into a single ``ClaudeMessage`` — the low-level API that ``ClaudeClient streamMessage:do:`` wraps.

Use this when you need event-by-event control over streaming — for example, to push tokens to a UI as they arrive, to cancel mid-stream, or to inspect raw SSE events (``message_start``, ``content_block_delta``, ``message_stop``) without the ``streamMessage:do:`` callback abstraction. For the common case (collect all events into one message, get the final text), prefer ``ClaudeClient streamMessage:do:`` — it handles the socket lifecycle for you.

What comes back is a ``ClaudeMessage`` built by replaying the accumulated SSE events — ``textContent``, ``stopReason``, and ``usage`` are populated as if the call had been non-streaming. The final message also carries the streaming socket's ``requestId`` (the Anthropic ``request-id`` response header), copied after the ensure block closes the socket — matching ``ClaudeClient streamMessage:do:`` so callers get the same support correlation key whether they use the high-level or raw API.

  ClaudeMessagingRawStreamingExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingRawStreamingExample buildRequest maxTokens
  >>> 50

  ClaudeMessagingRawStreamingExample buildRequest stream
  >>> true

  ClaudeMessagingRawStreamingExample buildRequest messages size
  >>> 1

Live end-to-end coverage lives in ``ClaudeIntegrationTest >> testRealStreamingEvents``, which exercises the same socket + decoder pattern against api.anthropic.com. That test is the regression guard for the requestId propagation contract: it drives real traffic through ``runOn:``'s code path, so any regression that dropped the ``message requestId: sock requestId`` line would be caught by extending the live assertion set. A dedicated unit test was considered but would require a wider test double for ``ClaudeClient openStreamingSocket:`` than this package currently has; the live test is the canonical guard.
"
Class {
	#name : 'ClaudeMessagingRawStreamingExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingRawStreamingExample class >> buildRequest [
	"Build a streaming request (stream: true) suitable for raw
	 TLS-socket consumption via ClaudeSSEDecoder. maxTokens kept
	 small — this example is about the streaming machinery, not the
	 content."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 50.
	req addUserMessage: 'Say hi in 3 words'.
	req stream: true.
	^ req
]

{ #category : 'private' }
ClaudeMessagingRawStreamingExample class >> resolveClient [
	"Resolve a live ClaudeClient via shared example support."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingRawStreamingExample class >> run [
	"Send the example streaming request using a resolved client and
	 return the accumulated final ClaudeMessage."
	^ self runOn: self resolveClient
]

{ #category : 'running' }
ClaudeMessagingRawStreamingExample class >> runOn: aClient [
	"Raw TLS-socket streaming end-to-end. Opens a streaming socket
	 via the client (which applies the configured timeout and
	 headers), wraps the socket with ClaudeSSEDecoder, drains the
	 SSE events and accumulates them into a single ClaudeMessage.
	 Copies the socket's requestId onto the final message (guarded
	 by isClaudeStreamingSocket polymorphic predicate so buffered
	 non-streaming sockets used in tests are a no-op) — mirrors
	 ClaudeClient>>streamMessage:do:, so callers get the same
	 Anthropic support correlation key whether they use the
	 high-level or raw API. Returns that final message. See also
	 ClaudeIntegrationTest>>testRealStreamingEvents for the live
	 end-to-end contract."
	| sock decoder message |
	sock := aClient openStreamingSocket: self buildRequest.
	message := ClaudeMessage new.
	[
		decoder := ClaudeSSEDecoder onStream: sock.
		[ decoder hasNext ] whileTrue: [ message accumulate: decoder nextEvent ] ]
		ensure: [ sock close ].
	sock isClaudeStreamingSocket
		ifTrue: [ message requestId: sock requestId ].
	^ message
]
