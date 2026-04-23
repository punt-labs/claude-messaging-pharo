"
Tests for ClaudeSSEDecoder. Covers buffered parsing of SSE text into typed event dictionaries: basic events, multiple events, ping, comments, multiline data, empty data, missing event field, and realistic Claude API events (message_start, content_block_delta).
"
Class {
	#name : 'ClaudeSSEDecoderTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Streaming-Tests',
	#package : 'Claude-Messaging-Streaming-Tests'
}

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseBasicEvent [
	| events |
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: 'event: message_start
data: {"type":"message_start"}

'
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'message_start'.
	self assert: (events first value at: 'type') equals: 'message_start'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseCommentLines [
	| events |
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: ': this is a comment
event: message_start
: another comment
data: {"type":"message_start"}

'
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'message_start'.
	self assert: (events first value at: 'type') equals: 'message_start'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseContentBlockDelta [
	| events body delta |
	body := 'event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

'.
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: body
		do: [ :eventType :d | events add: (Association key: eventType value: d) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'content_block_delta'.
	delta := events first value at: 'delta'.
	self assert: (delta at: 'type') equals: 'text_delta'.
	self assert: (delta at: 'text') equals: 'Hello'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseEmptyData [
	| events |
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: 'event: ping
data:

'
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'ping'.
	self assert: events first value isNil
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseMessageStartEvent [
	| events body data msg |
	body := 'event: message_start
data: {"type":"message_start","message":{"id":"msg_01","type":"message","role":"assistant","content":[],"model":"claude-sonnet-4-5","stop_reason":null,"usage":{"input_tokens":10,"output_tokens":0}}}

'.
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: body
		do: [ :eventType :d | events add: (Association key: eventType value: d) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'message_start'.
	data := events first value.
	msg := data at: 'message'.
	self assert: (msg at: 'id') equals: 'msg_01'.
	self assert: (msg at: 'model') equals: 'claude-sonnet-4-5'.
	self assert: (msg at: 'role') equals: 'assistant'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseMissingEventField [
	| events |
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: 'data: {"type":"message_stop"}

'
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: ''.
	self assert: (events first value at: 'type') equals: 'message_stop'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseMultilineData [
	| events body |
	body := 'event: message_start
data: {"part":
data: "one"}

'.
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: body
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'message_start'.
	self assert: (events first value at: 'part') equals: 'one'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParseMultipleEvents [
	| events body |
	body := 'event: message_start
data: {"type":"message_start"}

event: content_block_start
data: {"type":"content_block_start","index":0}

event: message_stop
data: {"type":"message_stop"}

'.
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: body
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 3.
	self assert: events first key equals: 'message_start'.
	self assert: events second key equals: 'content_block_start'.
	self assert: events third key equals: 'message_stop'
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testParsePingEvent [
	| events |
	events := OrderedCollection new.
	ClaudeSSEDecoder new
		parse: 'event: ping
data: {}

'
		do: [ :eventType :data | events add: (Association key: eventType value: data) ].
	self assert: events size equals: 1.
	self assert: events first key equals: 'ping'.
	self assert: events first value isEmpty
]

{ #category : 'tests' }
ClaudeSSEDecoderTest >> testStreamingMode [
	| body decoder events |
	body := 'event: message_start
data: {"type":"message_start"}

event: message_stop
data: {"type":"message_stop"}

'.
	decoder := ClaudeSSEDecoder onStream: body readStream.
	events := OrderedCollection new.
	[ decoder hasNext ] whileTrue: [
		events add: decoder nextEvent ].
	self assert: events size equals: 2.
	self assert: (events first at: 'event') equals: 'message_start'.
	self assert: (events second at: 'event') equals: 'message_stop'
]
