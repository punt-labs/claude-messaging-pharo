"
Raw TLS socket for incremental Server-Sent Events streaming from the Claude API. Opens a TCP connection, wraps it in TLS via ZdcSecureSocketStream with SNI, sends an HTTP/1.1 POST, and provides line-by-line reading via nextLine and atEnd — the same protocol ClaudeSSEDecoder expects. Unlike ZnClient (which buffers the full response), this delivers events as they arrive from the network.

### Examples

```
ClaudeStreamingSocket host: 'api.anthropic.com'
>>> a ClaudeStreamingSocket
```

"
Class {
	#name : 'ClaudeStreamingSocket',
	#superclass : 'Object',
	#instVars : [
		'socket',
		'stream',
		'host',
		'port',
		'timeout',
		'chunked',
		'chunkBuffer',
		'done',
		'requestId'
	],
	#category : 'Claude-Messaging-Streaming',
	#package : 'Claude-Messaging-Streaming'
}

{ #category : 'instance creation' }
ClaudeStreamingSocket class >> host: aString [
	"Create a streaming socket for the given hostname."
	^ self new host: aString; yourself
]

{ #category : 'stream protocol' }
ClaudeStreamingSocket >> atEnd [
	"True when no more data can be read."
	stream ifNil: [ ^ true ].
	chunked ifTrue: [ ^ done and: [ chunkBuffer atEnd ] ].
	^ stream atEnd
]

{ #category : 'connection' }
ClaudeStreamingSocket >> close [
	"Close the TLS stream and underlying socket."
	stream ifNotNil: [
		stream isConnected ifTrue: [ stream close ] ].
	socket ifNotNil: [
		socket isConnected ifTrue: [ socket close ] ]
]

{ #category : 'connection' }
ClaudeStreamingSocket >> connect [
	"Open TCP connection and establish TLS with SNI."
	socket := Socket newTCP.
	socket connectTo: (NetNameResolver addressForName: host) port: port.
	stream := ZdcSecureSocketStream on: socket.
	stream sslSession serverName: host.
	stream timeout: timeout.
	stream connect
]

{ #category : 'private' }
ClaudeStreamingSocket >> enableChunked [
	"Enable chunked transfer decoding."
	chunked := true.
	chunkBuffer := '' readStream
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> host [
	^ host
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> host: aString [
	host := aString
]

{ #category : 'initialization' }
ClaudeStreamingSocket >> initialize [
	port := 443.
	timeout := 300.
	chunked := false.
	done := false
]

{ #category : 'testing' }
ClaudeStreamingSocket >> isClaudeStreamingSocket [
	^ true
]

{ #category : 'testing' }
ClaudeStreamingSocket >> isConnected [
	"True when the TLS stream is connected."
	stream ifNil: [ ^ false ].
	^ stream isConnected
]

{ #category : 'stream protocol' }
ClaudeStreamingSocket >> nextLine [
	"Read the next line. Compatible with ClaudeSSEDecoder stream protocol."
	^ self readLine
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> port [
	^ port
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> port: anInteger [
	port := anInteger
]

{ #category : 'printing' }
ClaudeStreamingSocket >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeStreamingSocket(';
		nextPutAll: (host ifNil: [ '?' ]);
		nextPut: $:;
		print: port;
		nextPut: $)
]

{ #category : 'response' }
ClaudeStreamingSocket >> readHeaders [
	"Read HTTP headers until the blank line. Return a Dictionary. Enables chunked decoding if transfer-encoding is chunked."
	| headers line colonIndex |
	headers := Dictionary new.
	[ (line := self readRawLine) isEmpty ] whileFalse: [
		colonIndex := line indexOf: $:.
		colonIndex > 0 ifTrue: [
			headers
				at: (line copyFrom: 1 to: colonIndex - 1) trimBoth asLowercase
				put: (line copyFrom: colonIndex + 1 to: line size) trimBoth ] ].
	(headers at: 'transfer-encoding' ifAbsent: [ '' ]) asLowercase = 'chunked'
		ifTrue: [ self enableChunked ].
	^ headers
]

{ #category : 'private' }
ClaudeStreamingSocket >> readLine [
	"Read one line. Handles chunked transfer encoding transparently."
	| line |
	chunked ifFalse: [ ^ self readRawLine ].
	done ifTrue: [ ^ '' ].
	"Refill chunk buffer if needed"
	[ chunkBuffer atEnd and: [ done not ] ] whileTrue: [ self readNextChunk ].
	done ifTrue: [ ^ '' ].
	line := chunkBuffer upTo: Character lf.
	(line notEmpty and: [ line last = Character cr ])
		ifTrue: [ line := line allButLast ].
	^ line
]

{ #category : 'private' }
ClaudeStreamingSocket >> readNextChunk [
	"Read one chunk: hex-size line, data bytes, trailing CRLF. Update chunkBuffer. Set done on zero-length chunk."
	| sizeLine size data |
	sizeLine := self readRawLine.
	size := Integer readFrom: sizeLine trimBoth readStream base: 16.
	size = 0 ifTrue: [ done := true. ^ self ].
	data := (stream next: size) utf8Decoded.
	stream next: 2.  "consume trailing CRLF"
	chunkBuffer := (chunkBuffer upToEnd, data) readStream
]

{ #category : 'private' }
ClaudeStreamingSocket >> readRawLine [
	"Read one raw line from the TLS stream, up to LF. Strip trailing CR. Decode as UTF-8."
	| bytes line |
	bytes := stream upTo: 10.
	line := bytes utf8Decoded.
	(line notEmpty and: [ line last = Character cr ])
		ifTrue: [ line := line allButLast ].
	^ line
]

{ #category : 'response' }
ClaudeStreamingSocket >> readStatusLine [
	"Read and parse the HTTP status line. Return the status code as Integer."
	| line parts |
	line := self readRawLine.
	parts := line substrings.
	^ parts second asInteger
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> requestId [
	^ requestId
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> requestId: aString [
	requestId := aString
]

{ #category : 'request' }
ClaudeStreamingSocket >> sendPost: path headers: headerDict body: bodyString [
	"Send an HTTP/1.1 POST request over the TLS stream."
	| cr bodyBytes |
	cr := String crlf.
	bodyBytes := bodyString utf8Encoded.
	stream nextPutAll: ('POST ', path, ' HTTP/1.1', cr) asByteArray.
	stream nextPutAll: ('Host: ', host, cr) asByteArray.
	headerDict keysAndValuesDo: [ :k :v |
		stream nextPutAll: (k, ': ', v, cr) asByteArray ].
	stream nextPutAll: ('Content-Length: ', bodyBytes size printString, cr) asByteArray.
	stream nextPutAll: cr asByteArray.
	stream nextPutAll: bodyBytes.
	stream flush
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> timeout [
	^ timeout
]

{ #category : 'accessing' }
ClaudeStreamingSocket >> timeout: anInteger [
	timeout := anInteger
]
