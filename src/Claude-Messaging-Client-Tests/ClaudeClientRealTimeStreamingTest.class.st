"
Tests for real-time incremental streaming — SSE decoder on streams, SharedQueue producer/consumer pattern, and stream end detection. From spec Appendix C.3.5, bead kqf.
"
Class {
	#name : 'ClaudeClientRealTimeStreamingTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'tests' }
ClaudeClientRealTimeStreamingTest >> testAccumulateFromStream [
	"Use decoder + accumulate: from a stream, verify final message text and stop reason."
	| sseText decoder message |
	sseText := 'event: message_start
data: {"type":"message_start","message":{"id":"msg_rt01","type":"message","role":"assistant","content":[],"model":"claude-sonnet-4-5","stop_reason":null,"usage":{"input_tokens":10,"output_tokens":0}}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" world"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_delta
data: {"type":"message_delta","delta":{"stop_reason":"end_turn"},"usage":{"output_tokens":5}}

event: message_stop
data: {"type":"message_stop"}

'.
	decoder := ClaudeSSEDecoder onStream: sseText readStream.
	message := ClaudeMessage new.
	[ decoder hasNext ] whileTrue: [
		message accumulate: decoder nextEvent ].
	self assert: message textContent equals: 'Hello world'.
	self assert: message stopReason equals: #end_turn.
	self assert: message id equals: 'msg_rt01'
]

{ #category : 'tests' }
ClaudeClientRealTimeStreamingTest >> testOpenStreamingSocketReturnsStream [
	| mock localClient params stream decoder events |
	mock := ClaudeMockServer startOn: 0.
	[ mock respondTo: '/v1/messages' withSSE: 'event: message_start
data: {"type":"message_start"}

event: message_stop
data: {"type":"message_stop"}

'.
	localClient := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mock port printString timeout: 5.
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	stream := localClient openStreamingSocket: params.
	self assert: stream notNil.
	decoder := ClaudeSSEDecoder onStream: stream.
	events := OrderedCollection new.
	[ decoder hasNext ] whileTrue: [
		events add: decoder nextEvent ].
	self assert: events size equals: 2.
	self assert: (events first at: 'event') equals: 'message_start'.
	self assert: (events second at: 'event') equals: 'message_stop'
	] ensure: [ mock stop ]
]

{ #category : 'tests' }
ClaudeClientRealTimeStreamingTest >> testSSEDecoderOnStreamIncremental [
	"Feed SSE bytes to a ReadStream in chunks, verify events arrive via hasNext/nextEvent."
	| sseText decoder event1 event2 |
	sseText := 'event: message_start
data: {"type":"message_start"}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}

'.
	decoder := ClaudeSSEDecoder onStream: sseText readStream.
	self assert: decoder hasNext.
	event1 := decoder nextEvent.
	self assert: (event1 at: 'event') equals: 'message_start'.
	self assert: ((event1 at: 'data') at: 'type') equals: 'message_start'.
	self assert: decoder hasNext.
	event2 := decoder nextEvent.
	self assert: (event2 at: 'event') equals: 'content_block_delta'.
	self assert: (((event2 at: 'data') at: 'delta') at: 'text') equals: 'Hi'.
	self deny: decoder hasNext
]

{ #category : 'tests' }
ClaudeClientRealTimeStreamingTest >> testSharedQueuePattern [
	| sseText queue process events semaphore event |
	sseText := 'event: message_start
data: {"type":"message_start"}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}

event: message_stop
data: {"type":"message_stop"}

'.
	queue := SharedQueue new.
	semaphore := Semaphore new.
	process := [
		| decoder |
		decoder := ClaudeSSEDecoder onStream: sseText readStream.
		[ decoder hasNext ] whileTrue: [
			queue nextPut: decoder nextEvent ].
		queue nextPut: #end.
		semaphore signal
	] forkAt: Processor userBackgroundPriority named: 'SSE test producer'.
	events := OrderedCollection new.
	event := queue next.
	[ event == #end ] whileFalse: [
		events add: event.
		event := queue next ].
	semaphore wait.
	self assert: events size equals: 3.
	self assert: (events first at: 'event') equals: 'message_start'.
	self assert: (events second at: 'event') equals: 'content_block_delta'.
	self assert: (((events second at: 'data') at: 'delta') at: 'text') equals: 'Hi'.
	self assert: (events third at: 'event') equals: 'message_stop'
]

{ #category : 'tests' }
ClaudeClientRealTimeStreamingTest >> testStreamEndDetection [
	"After all events consumed, hasNext returns false. Multiple calls to hasNext after end remain false."
	| sseText decoder count |
	sseText := 'event: message_start
data: {"type":"message_start"}

event: message_stop
data: {"type":"message_stop"}

'.
	decoder := ClaudeSSEDecoder onStream: sseText readStream.
	count := 0.
	[ decoder hasNext ] whileTrue: [
		decoder nextEvent.
		count := count + 1 ].
	self assert: count equals: 2.
	"Calling hasNext again should still return false"
	self deny: decoder hasNext.
	self deny: decoder hasNext
]
