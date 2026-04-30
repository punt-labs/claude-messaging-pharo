"
API response message from Claude. Contains a ClaudeTurn (conversation content), ClaudeStopDetails (why the model stopped), ClaudeUsage (token consumption), and optional ClaudeExecutionContainer and ClaudeRequestContext. Forwarding methods preserve the original accessor interface — role, content, model, stopReason, textContent, toolUseBlocks all delegate to sub-objects transparently.

### Examples

```
| msg |
msg := ClaudeMessage userMessage: 'hello'.
msg textContent
>>> 'hello'

ClaudeMessage new role
>>> nil

| msg |
msg := ClaudeMessage new.
msg stopReason: #end_turn.
msg stopReason
>>> #end_turn
```

"
Class {
	#name : 'ClaudeMessage',
	#superclass : 'Object',
	#instVars : [
		'id',
		'type',
		'turn',
		'usage',
		'stopDetails',
		'executionContainer',
		'requestContext',
		'responseMetadata'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeMessage class >> assistantMessage: aString [
	"Create an assistant message with text content."
	^ self new
		turn: (ClaudeTurn role: 'assistant' content: { ClaudeTextBlock text: aString });
		yourself
]

{ #category : 'json' }
ClaudeMessage class >> fromJson: aDictionary [
	^ self new
		populateFromJson: aDictionary;
		yourself
]

{ #category : 'instance creation' }
ClaudeMessage class >> fromSton: stonReader [
	"Restore from STON. Bridges legacy snapshots written before mission
	 yvyt+pch2: when the embedded ClaudeRequestContext carries a
	 migratedRequestId, promote it onto responseMetadata so the surface
	 API still answers requestId on restore. See
	 #promoteMigratedRequestIdFrom:onto: for the migration detail."
	| dict ctx restoredMeta |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	ctx := dict at: #requestContext ifAbsent: [ nil ].
	restoredMeta := self
		promoteMigratedRequestIdFrom: ctx
		onto: (dict at: #responseMetadata ifAbsent: [ nil ]).
	^ self new
		id: (dict at: #id ifAbsent: [ nil ]);
		type: (dict at: #type ifAbsent: [ nil ]);
		turn: (dict at: #turn ifAbsent: [ nil ]);
		usage: (dict at: #usage ifAbsent: [ nil ]);
		stopDetails: (dict at: #stopDetails ifAbsent: [ nil ]);
		executionContainer: (dict at: #executionContainer ifAbsent: [ nil ]);
		requestContext: ctx;
		responseMetadata: restoredMeta;
		yourself
]

{ #category : 'private' }
ClaudeMessage class >> promoteMigratedRequestIdFrom: ctx onto: restoredMeta [
	"Mission yvyt+pch2 migration: legacy snapshots stored requestId on the
	 embedded request context; new shape stores it on responseMetadata.
	 If the context carries a migratedRequestId rescued by
	 ClaudeRequestContext>>fromSton:, copy it onto restoredMeta (creating
	 a fresh metadata if absent) so the surface API still answers requestId
	 on restore. Clear the transient slot so it cannot leak into a later
	 re-serialization. Returns the (possibly newly created) restoredMeta."
	| meta |
	(ctx isNil or: [ ctx migratedRequestId isNil ]) ifTrue: [ ^ restoredMeta ].
	meta := restoredMeta ifNil: [ ClaudeResponseMetadata new ].
	meta requestId ifNil: [ meta requestId: ctx migratedRequestId ].
	ctx migratedRequestId: nil.
	^ meta
]

{ #category : 'instance creation' }
ClaudeMessage class >> toolResult: toolUseId content: aString [
	"Create a user message containing a tool result."
	^ self new
		turn: (ClaudeTurn role: 'user' content: { ClaudeToolResultBlock toolUseId: toolUseId content: aString });
		yourself
]

{ #category : 'instance creation' }
ClaudeMessage class >> toolResult: toolUseId content: aString isError: aBoolean [
	"Create a user message containing a tool result with error flag."
	^ self new
		turn: (ClaudeTurn role: 'user' content: { ClaudeToolResultBlock toolUseId: toolUseId content: aString isError: aBoolean });
		yourself
]

{ #category : 'instance creation' }
ClaudeMessage class >> userContent: contentBlocks [
	"Create a user message with multiple content blocks."
	^ self new
		turn: (ClaudeTurn role: 'user' content: contentBlocks asArray);
		yourself
]

{ #category : 'instance creation' }
ClaudeMessage class >> userMessage: aString [
	"Create a user message with text content."
	^ self new
		turn: (ClaudeTurn role: 'user' content: { ClaudeTextBlock text: aString });
		yourself
]

{ #category : 'streaming' }
ClaudeMessage >> accumulate: anEventDict [
	"Process one streaming event. anEventDict has 'event' (String) and 'data' (Dictionary).
	An 'error' event (rate limit, overload, auth failure after stream start)
	raises the matching ClaudeApiError subclass via ClaudeApiError
	class>>#fromSseErrorData:. See bead 8x5."
	| eventType data |
	eventType := anEventDict at: 'event'.
	data := anEventDict at: 'data'.
	data ifNil: [ ^ self ].  "Guard against nil data - ignore the event"
	eventType = 'message_start' ifTrue: [ ^ self handleMessageStart: data ].
	eventType = 'content_block_start' ifTrue: [ ^ self handleContentBlockStart: data ].
	eventType = 'content_block_delta' ifTrue: [ ^ self handleContentBlockDelta: data ].
	eventType = 'content_block_stop' ifTrue: [ ^ self handleContentBlockStop: data ].
	eventType = 'message_delta' ifTrue: [ ^ self handleMessageDelta: data ].
	eventType = 'error' ifTrue: [ ^ self handleErrorEvent: data ]
]

{ #category : 'json' }
ClaudeMessage >> asJson [
	| dict |
	dict := OrderedDictionary new.
	id ifNotNil: [ dict at: 'id' put: id ].
	type ifNotNil: [ dict at: 'type' put: type ].
	turn ifNotNil: [
		| turnJson |
		turnJson := turn asJson.
		turnJson keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	stopDetails ifNotNil: [
		| sdJson |
		sdJson := stopDetails asJson.
		sdJson keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	usage ifNotNil: [ dict at: 'usage' put: usage asJson ].
	executionContainer ifNotNil: [ dict at: 'container' put: executionContainer asJson ].
	^ dict
]

{ #category : 'converting' }
ClaudeMessage >> asParam [
	^ turn asParam
]

{ #category : 'accessing' }
ClaudeMessage >> content [
	^ turn ifNotNil: [ :t | t content ]
]

{ #category : 'accessing' }
ClaudeMessage >> content: anOrderedCollection [
	self ensureTurn content: anOrderedCollection
]

{ #category : 'private' }
ClaudeMessage >> ensureRequestContext [
	"Lazily create requestContext if nil."
	^ requestContext ifNil: [ requestContext := ClaudeRequestContext new ]
]

{ #category : 'private' }
ClaudeMessage >> ensureResponseMetadata [
  "Lazily create responseMetadata if nil. Mirrors ensureRequestContext
   so requestId: and any future single-field setters can write through
   without callers needing to construct the holder first."
  ^ responseMetadata ifNil: [ responseMetadata := ClaudeResponseMetadata new ]
]

{ #category : 'private' }
ClaudeMessage >> ensureStopDetails [
	"Lazily create stopDetails if nil."
	^ stopDetails ifNil: [ stopDetails := ClaudeStopDetails new ]
]

{ #category : 'private' }
ClaudeMessage >> ensureTurn [
	"Lazily create turn if nil."
	^ turn ifNil: [ turn := ClaudeTurn new ]
]

{ #category : 'accessing' }
ClaudeMessage >> executionContainer [
	^ executionContainer
]

{ #category : 'accessing' }
ClaudeMessage >> executionContainer: aClaudeExecutionContainer [
	executionContainer := aClaudeExecutionContainer
]

{ #category : 'streaming' }
ClaudeMessage >> handleContentBlockDelta: data [
	| delta block |
	delta := data at: 'delta'.
	block := self content last.
	block applyDelta: delta
]

{ #category : 'streaming' }
ClaudeMessage >> handleContentBlockStart: data [
	| blockData block |
	blockData := data at: 'content_block'.
	block := ClaudeContentBlock fromJson: blockData.
	self content add: block
]

{ #category : 'streaming - accumulation' }
ClaudeMessage >> handleContentBlockStop: data [
	"Finalize a content block. Delegates to the block's polymorphic
	finalizeAfterStreaming so each block type can apply its own end-of-stream
	transformation (e.g., parse accumulated input_json_delta string into a
	Dictionary for tool_use and mcp_tool_use blocks)."
	self content last finalizeAfterStreaming 
]

{ #category : 'streaming' }
ClaudeMessage >> handleErrorEvent: data [
	"Raise the matching ClaudeApiError subclass for an SSE error event.
	The data payload has shape
	{ 'type': 'error', 'error': { 'type': 'overloaded_error', 'message': '...' } }.
	We never return to the caller from this method — it always signals.
	See bead 8x5."

	(ClaudeApiError fromSseErrorData: data) signal
]

{ #category : 'streaming' }
ClaudeMessage >> handleMessageDelta: data [
	| delta |
	delta := data at: 'delta'.
	(delta at: 'stop_reason' ifAbsent: [ nil ]) ifNotNil: [ :sr |
		self ensureStopDetails stopReason: sr asSymbol ].
	(delta at: 'stop_sequence' ifAbsent: [ nil ]) ifNotNil: [ :ss |
		self ensureStopDetails stopSequence: ss ].
	(data at: 'usage' ifAbsent: [ nil ]) ifNotNil: [ :u |
		usage ifNil: [ usage := ClaudeUsage new ].
		usage outputTokens: (u at: 'output_tokens' ifAbsent: [ nil ]) ]
]

{ #category : 'streaming' }
ClaudeMessage >> handleMessageStart: data [
	| msg |
	msg := data at: 'message'.
	id := msg at: 'id' ifAbsent: [ nil ].
	type := msg at: 'type' ifAbsent: [ nil ].
	turn := ClaudeTurn new.
	turn role: ((msg at: 'role' ifAbsent: [ nil ]) ifNotNil: [ :v | v asSymbol ]).
	turn model: (msg at: 'model' ifAbsent: [ nil ]).
	turn content: OrderedCollection new.
	(msg at: 'usage' ifAbsent: [ nil ]) ifNotNil: [ :u |
		usage := ClaudeUsage fromJson: u ]
]

{ #category : 'accessing' }
ClaudeMessage >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeMessage >> id: aString [
	id := aString
]

{ #category : 'accessing' }
ClaudeMessage >> model [
	^ turn ifNotNil: [ :t | t model ]
]

{ #category : 'accessing' }
ClaudeMessage >> model: aString [
	self ensureTurn model: aString
]

{ #category : 'accessing' }
ClaudeMessage >> outputFormat [
	^ requestContext ifNotNil: [ :c | c outputFormat ]
]

{ #category : 'accessing' }
ClaudeMessage >> outputFormat: anObject [
	self ensureRequestContext outputFormat: anObject
]

{ #category : 'json' }
ClaudeMessage >> populateFromJson: aDictionary [
	id := aDictionary at: 'id' ifAbsent: [ nil ].
	type := aDictionary at: 'type' ifAbsent: [ nil ].
	turn := ClaudeTurn fromJson: aDictionary.
	stopDetails := ClaudeStopDetails fromJson: aDictionary.
	executionContainer := ClaudeExecutionContainer fromJson: aDictionary.
	(aDictionary at: 'usage' ifAbsent: [ nil ])
		ifNotNil: [ :u | usage := ClaudeUsage fromJson: u ]
]

{ #category : 'printing' }
ClaudeMessage >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeMessage(';
		nextPutAll: (self role ifNil: [ '?' ]) asString;
		nextPutAll: ' ';
		nextPutAll: (self stopReason ifNil: [ '?' ]) asString;
		nextPutAll: ' blocks: ';
		print: (self content ifNil: [ #() ]) size;
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeMessage >> rateLimits [
  "Convenience reader returning the full ClaudeResponseMetadata for
   callers that want rate-limit telemetry without two-step drill-down.
   Returns the attached ClaudeResponseMetadata if any (lazily created
   when requestId: is set, populated by ClaudeClient on live responses,
   or restored intact via STON), or nil when no metadata has been
   attached at all."
  ^ responseMetadata
]

{ #category : 'accessing' }
ClaudeMessage >> requestContext [
	^ requestContext
]

{ #category : 'accessing' }
ClaudeMessage >> requestContext: aClaudeRequestContext [
	requestContext := aClaudeRequestContext
]

{ #category : 'accessing' }
ClaudeMessage >> requestId [
  "Answer the request-id echoed by the API for this response, or nil
   when no metadata has been attached. Storage migrated from
   requestContext to responseMetadata in Phase 2 (mission yvyt+pch2);
   the surface API is unchanged."
  ^ responseMetadata ifNotNil: [ :m | m requestId ]
]

{ #category : 'accessing' }
ClaudeMessage >> requestId: aString [
  "Set the request-id echoed by the API. Storage migrated to
   ClaudeResponseMetadata in Phase 2; setting via this accessor lazily
   creates the metadata holder so existing callers see no API change."
  self ensureResponseMetadata requestId: aString
]

{ #category : 'accessing' }
ClaudeMessage >> responseMetadata [
  ^ responseMetadata
]

{ #category : 'accessing' }
ClaudeMessage >> responseMetadata: aClaudeResponseMetadata [
  responseMetadata := aClaudeResponseMetadata
]

{ #category : 'accessing' }
ClaudeMessage >> role [
	^ turn ifNotNil: [ :t | t role ]
]

{ #category : 'accessing' }
ClaudeMessage >> role: aSymbol [
	self ensureTurn role: aSymbol
]

{ #category : 'persistence' }
ClaudeMessage >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    id ifNotNil: [ map at: #id put: id ].
    type ifNotNil: [ map at: #type put: type ].
    turn ifNotNil: [ map at: #turn put: turn ].
    usage ifNotNil: [ map at: #usage put: usage ].
    stopDetails ifNotNil: [ map at: #stopDetails put: stopDetails ].
    executionContainer ifNotNil: [ map at: #executionContainer put: executionContainer ].
    requestContext ifNotNil: [ map at: #requestContext put: requestContext ].
    responseMetadata ifNotNil: [ map at: #responseMetadata put: responseMetadata ] ]
]

{ #category : 'accessing' }
ClaudeMessage >> stopDetails [
	^ stopDetails
]

{ #category : 'accessing' }
ClaudeMessage >> stopDetails: aClaudeStopDetails [
	stopDetails := aClaudeStopDetails
]

{ #category : 'accessing' }
ClaudeMessage >> stopReason [
	^ stopDetails ifNotNil: [ :d | d stopReason ]
]

{ #category : 'accessing' }
ClaudeMessage >> stopReason: aSymbol [
	self ensureStopDetails stopReason: aSymbol
]

{ #category : 'accessing' }
ClaudeMessage >> stopSequence [
	^ stopDetails ifNotNil: [ :d | d stopSequence ]
]

{ #category : 'accessing' }
ClaudeMessage >> stopSequence: aString [
	self ensureStopDetails stopSequence: aString
]

{ #category : 'accessing' }
ClaudeMessage >> textContent [
	"Return the concatenated text of all text blocks in this message''s content.
	Returns an empty string when turn is nil (e.g., an error-only SSE response)."
	turn ifNil: [ ^ '' ].
	^ turn textContent
]

{ #category : 'accessing' }
ClaudeMessage >> toolUseBlocks [
	"Return tool-use blocks. Returns empty collection when turn is nil."
	turn ifNil: [ ^ OrderedCollection new ].
	^ turn toolUseBlocks
]

{ #category : 'accessing' }
ClaudeMessage >> turn [
	^ turn
]

{ #category : 'accessing' }
ClaudeMessage >> turn: aClaudeTurn [
	turn := aClaudeTurn
]

{ #category : 'accessing' }
ClaudeMessage >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeMessage >> type: aString [
	type := aString
]

{ #category : 'accessing' }
ClaudeMessage >> usage [
	^ usage
]

{ #category : 'accessing' }
ClaudeMessage >> usage: aClaudeUsage [
	usage := aClaudeUsage
]
