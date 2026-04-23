"
Unit tests for ClaudeStreamingSocket — factory, defaults, HTTP request formatting, status line parsing, and header parsing.
"
Class {
	#name : 'ClaudeStreamingSocketTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Streaming-Tests',
	#package : 'Claude-Messaging-Streaming-Tests'
}

{ #category : 'fixtures' }
ClaudeStreamingSocketTest >> socketWithBytes: aString [
	"Create a ClaudeStreamingSocket with a fake stream for testing parse methods."
	| sock fakeStream |
	sock := ClaudeStreamingSocket host: 'test'.
	fakeStream := aString asByteArray readStream.
	sock instVarNamed: 'stream' put: fakeStream.
	sock instVarNamed: 'socket' put: nil.
	^ sock
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testCustomPort [
	| sock |
	sock := ClaudeStreamingSocket host: 'localhost'.
	sock port: 8080.
	self assert: sock port equals: 8080
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testFactoryCreation [
	| sock |
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	self assert: sock host equals: 'api.anthropic.com'.
	self assert: sock port equals: 443.
	self assert: sock timeout equals: 300
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testNextLineProtocol [
	"nextLine delegates to readLine — compatible with ClaudeSSEDecoder."
	| sock |
	sock := self socketWithBytes: 'event: ping', String crlf.
	self assert: sock nextLine equals: 'event: ping'
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testNotConnectedBeforeConnect [
	| sock |
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	self deny: sock isConnected.
	self assert: sock atEnd
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testReadHeaders [
	| sock headers |
	sock := self socketWithBytes: 'Content-Type: text/event-stream', String crlf, 'X-Request-Id: abc123', String crlf, String crlf.
	headers := sock readHeaders.
	self assert: (headers at: 'content-type') equals: 'text/event-stream'.
	self assert: (headers at: 'x-request-id') equals: 'abc123'
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testReadLine [
	| sock |
	sock := self socketWithBytes: 'hello world', String crlf, 'second line', String crlf.
	self assert: sock readLine equals: 'hello world'.
	self assert: sock readLine equals: 'second line'
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testReadStatusLine [
	| sock |
	sock := self socketWithBytes: 'HTTP/1.1 200 OK', String crlf.
	self assert: sock readStatusLine equals: 200
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testReadStatusLineError [
	| sock |
	sock := self socketWithBytes: 'HTTP/1.1 401 Unauthorized', String crlf.
	self assert: sock readStatusLine equals: 401
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testSSEDecoderCompatibility [
	"Verify ClaudeSSEDecoder can read events from a ClaudeStreamingSocket."
	| sock decoder events |
	sock := self socketWithBytes: 'event: message_start', String crlf, 'data: {"type":"message_start"}', String crlf, String crlf, 'event: message_stop', String crlf, 'data: {"type":"message_stop"}', String crlf, String crlf.
	decoder := ClaudeSSEDecoder onStream: sock.
	events := OrderedCollection new.
	[ decoder hasNext ] whileTrue: [
		events add: decoder nextEvent ].
	self assert: events size equals: 2.
	self assert: (events first at: 'event') equals: 'message_start'.
	self assert: (events second at: 'event') equals: 'message_stop'
]

{ #category : 'tests' }
ClaudeStreamingSocketTest >> testSendPostFormat [
	"Verify the HTTP request is correctly formatted."
	| sock output |
	output := ByteArray new writeStream.
	sock := ClaudeStreamingSocket host: 'api.anthropic.com'.
	sock instVarNamed: 'stream' put: output.
	sock sendPost: '/v1/messages'
		headers: (OrderedDictionary newFromPairs: { 'x-api-key'. 'sk-test'. 'content-type'. 'application/json' })
		body: '{"model":"claude-sonnet-4-5"}'.
	output := output contents asString.
	self assert: (output includesSubstring: 'POST /v1/messages HTTP/1.1').
	self assert: (output includesSubstring: 'Host: api.anthropic.com').
	self assert: (output includesSubstring: 'x-api-key: sk-test').
	self assert: (output includesSubstring: 'Content-Length: 29').
	self assert: (output includesSubstring: '{"model":"claude-sonnet-4-5"}')
]
