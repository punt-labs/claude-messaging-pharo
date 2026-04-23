"
Parses Server-Sent Events (SSE) text into typed event dictionaries. Supports two modes: buffered (parse a complete response body string via parse:do:) and incremental (read from a SocketStream via hasNext/nextEvent). Each parsed event is a Dictionary with keys event (String type) and data (parsed JSON Dictionary). SSE rules per spec 4.1: event: sets type, data: appends to buffer, blank line dispatches, colon-prefixed lines are comments.

### Examples

```
| events |
events := OrderedCollection new.
ClaudeSSEDecoder new parse: 'event: ping
data: {}

' do: [:type :data | events add: type].
events first
>>> 'ping'
```

"
Class {
	#name : 'ClaudeSSEDecoder',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'currentEventType',
		'dataBuffer',
		'pendingEvent'
	],
	#category : 'Claude-Messaging-Streaming',
	#package : 'Claude-Messaging-Streaming'
}

{ #category : 'instance creation' }
ClaudeSSEDecoder class >> onStream: aStream [
	"Create a decoder for incremental reading from a SocketStream."
	^ self new stream: aStream; yourself
]

{ #category : 'streaming' }
ClaudeSSEDecoder >> close [
	"Close the underlying stream."
	stream ifNotNil: [ stream close. stream := nil ]
]

{ #category : 'private' }
ClaudeSSEDecoder >> dispatchEventDo: aBlock [
	"Dispatch the accumulated event if any data: line was seen."
	dataBuffer ifNil: [ ^ self ].
	aBlock value: currentEventType value: (self parseData: dataBuffer).
	currentEventType := ''.
	dataBuffer := nil
]

{ #category : 'streaming' }
ClaudeSSEDecoder >> hasNext [
	"Read lines from the stream until a complete event is assembled (blank line encountered) or end of stream. Returns true if an event is ready."
	| line |
	[ stream atEnd ] whileFalse: [
		line := stream nextLine.
		(line isNil or: [ line isEmpty ])
			ifTrue: [
				dataBuffer ifNotNil: [
					pendingEvent := Dictionary new
						at: 'event' put: currentEventType;
						at: 'data' put: (self parseData: dataBuffer);
						yourself.
					currentEventType := ''.
					dataBuffer := nil.
					^ true ] ]
			ifFalse: [ self processLine: line ] ].
	"End of stream - dispatch any remaining event"
	dataBuffer ifNil: [ ^ false ].
	pendingEvent := Dictionary new
		at: 'event' put: currentEventType;
		at: 'data' put: (self parseData: dataBuffer);
		yourself.
	currentEventType := ''.
	dataBuffer := nil.
	^ true
]

{ #category : 'initialization' }
ClaudeSSEDecoder >> initialize [
	currentEventType := ''
]

{ #category : 'streaming' }
ClaudeSSEDecoder >> nextEvent [
	"Return the last assembled event. Call only after hasNext returns true."
	| event |
	event := pendingEvent.
	pendingEvent := nil.
	^ event
]

{ #category : 'parsing' }
ClaudeSSEDecoder >> parse: aString do: aBlock [
	"Buffered mode: parse a complete SSE response body. Calls aBlock with (eventType, dataDictionary) for each event."
	| lines |
	lines := aString lines.
	currentEventType := ''.
	dataBuffer := nil.
	lines do: [ :line |
		(line isEmpty or: [ line allSatisfy: [ :c | c isSeparator ] ])
			ifTrue: [ self dispatchEventDo: aBlock ]
			ifFalse: [ self processLine: line ] ]
]

{ #category : 'private' }
ClaudeSSEDecoder >> parseData: aString [
	"Parse JSON data string. Returns Dictionary or nil for empty or unparseable data."
	(aString isNil or: [ aString trimBoth isEmpty ]) ifTrue: [ ^ nil ].
	^ [ STONJSON fromString: aString ]
		on: STONReaderError
		do: [ :e | nil ]
]

{ #category : 'private' }
ClaudeSSEDecoder >> processLine: aLine [
	"Parse a single SSE line: event:, data:, or comment (:)."
	(aLine beginsWith: 'event:')
		ifTrue: [ currentEventType := (aLine allButFirst: 6) trimLeft. ^ self ].
	(aLine beginsWith: 'data:')
		ifTrue: [
			| value |
			value := (aLine allButFirst: 5) trimLeft.
			dataBuffer := dataBuffer
				ifNil: [ value ]
				ifNotNil: [ dataBuffer, String cr, value ].
			^ self ].
	(aLine beginsWith: ':')
		ifTrue: [ ^ self ]
]

{ #category : 'accessing' }
ClaudeSSEDecoder >> stream [
	^ stream
]

{ #category : 'accessing' }
ClaudeSSEDecoder >> stream: aStream [
	stream := aStream
]
