"
Tests for ClaudeMessage — the API response object. Covers JSON parsing, serialization, round-trip fidelity, text extraction, tool-use filtering, and parameter conversion.
"
Class {
	#name : 'ClaudeMessageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageTest >> testAccumulateContentBlockDeltaWithNilData [
	"Test the specific crash scenario: content_block_delta with nil data"
	| msg eventDict result |
	msg := ClaudeMessage new.
	eventDict := Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: nil;
		yourself.
	
	"This should not crash - should return self and complete normally"
	result := msg accumulate: eventDict.
	self assert: result equals: msg
]

{ #category : 'tests' }
ClaudeMessageTest >> testAccumulateWithNilData [
	"Test that accumulate: handles nil data gracefully for all event types"
	| msg eventDict |
	msg := ClaudeMessage new.
	
	"Test each event type with nil data - should not crash"
	{ 'message_start'. 'content_block_start'. 'content_block_delta'. 'content_block_stop'. 'message_delta'. 'error' } do: [ :eventType |
		eventDict := Dictionary new
			at: 'event' put: eventType;
			at: 'data' put: nil;
			yourself.
		self shouldnt: [ msg accumulate: eventDict ] raise: Error description: ('accumulate: should handle nil data for event type: {1}' format: { eventType }) ]
]

{ #category : 'tests' }
ClaudeMessageTest >> testAsJson [
	| msg json |
	msg := ClaudeMessage new.
	msg id: 'msg_123'.
	msg type: 'message'.
	msg role: #assistant.
	msg content: (OrderedCollection with: (ClaudeTextBlock text: 'Hi')).
	msg model: 'claude-sonnet-4-20250514'.
	msg stopReason: #end_turn.
	msg usage: (ClaudeUsage new inputTokens: 5; outputTokens: 10; yourself).
	json := msg asJson.
	self assert: (json at: 'id') equals: 'msg_123'.
	self assert: (json at: 'type') equals: 'message'.
	self assert: (json at: 'role') equals: 'assistant'.
	self assert: (json at: 'content') size equals: 1.
	self assert: ((json at: 'content') first at: 'type') equals: 'text'.
	self assert: (json at: 'model') equals: 'claude-sonnet-4-20250514'.
	self assert: (json at: 'stop_reason') equals: 'end_turn'.
	self deny: (json includesKey: 'stop_sequence').
	self assert: ((json at: 'usage') at: 'input_tokens') equals: 5
]

{ #category : 'tests' }
ClaudeMessageTest >> testAsJsonWithExecutionContainer [
	| msg json container |
	msg := ClaudeMessage new.
	msg id: 'msg_123'.
	msg type: 'message'.
	msg role: #assistant.
	container := ClaudeExecutionContainer new.
	container containerId: 'ctr_456'.
	container expiresAt: '2026-04-18T12:00:00Z'.
	msg executionContainer: container.
	json := msg asJson.
	self assert: (json at: 'id') equals: 'msg_123'.
	self assert: (json includesKey: 'container').
	self assert: ((json at: 'container') at: 'id') equals: 'ctr_456'.
	self assert: ((json at: 'container') at: 'expires_at') equals: '2026-04-18T12:00:00Z'
]

{ #category : 'tests' }
ClaudeMessageTest >> testAsParam [
	| msg param |
	msg := ClaudeMessage new.
	msg role: #assistant.
	msg content: (OrderedCollection with: (ClaudeTextBlock text: 'Hi')).
	param := msg asParam.
	self assert: (param at: 'role') equals: 'assistant'.
	self assert: (param at: 'content') size equals: 1.
	self assert: ((param at: 'content') first at: 'type') equals: 'text'.
	self assert: ((param at: 'content') first at: 'text') equals: 'Hi'.
	self deny: (param includesKey: 'id').
	self deny: (param includesKey: 'model')
]

{ #category : 'tests' }
ClaudeMessageTest >> testEmptyContent [
	| msg |
	msg := ClaudeMessage new.
	msg content: OrderedCollection new.
	self assert: msg textContent equals: ''
]

{ #category : 'tests' }
ClaudeMessageTest >> testEnsureTurnLazyInit [
	"Setting role on a new message lazily creates the turn."
	| msg |
	msg := ClaudeMessage new.
	self assert: msg turn isNil.
	msg role: 'user'.
	self assert: msg turn class equals: ClaudeTurn.
	self assert: msg role equals: 'user'
]

{ #category : 'tests' }
ClaudeMessageTest >> testExecutionContainerAccessor [
	"executionContainer slot can be set and read."
	| msg ec |
	msg := ClaudeMessage new.
	ec := ClaudeExecutionContainer new containerId: 'ctr_1'.
	msg executionContainer: ec.
	self assert: msg executionContainer identicalTo: ec.
	self assert: msg executionContainer containerId equals: 'ctr_1'
]

{ #category : 'tests' }
ClaudeMessageTest >> testFactoryCreatesClaudeTurn [
	"Factory methods create ClaudeTurn internally, not bare slots."
	| msg |
	msg := ClaudeMessage userMessage: 'test'.
	self assert: msg turn class equals: ClaudeTurn.
	self assert: msg role equals: 'user'.
	self assert: msg textContent equals: 'test'.
	
	msg := ClaudeMessage assistantMessage: 'response'.
	self assert: msg turn class equals: ClaudeTurn.
	self assert: msg role equals: 'assistant'.
	self assert: msg textContent equals: 'response'
]

{ #category : 'tests' }
ClaudeMessageTest >> testFromJson [
	| json msg |
	json := Dictionary new.
	json at: 'id' put: 'msg_01XFDUDYJgAACzvnptvVoYEL'.
	json at: 'type' put: 'message'.
	json at: 'role' put: 'assistant'.
	json at: 'content' put: {
		Dictionary new
			at: 'type' put: 'text';
			at: 'text' put: 'Hello!';
			yourself
	}.
	json at: 'model' put: 'claude-sonnet-4-20250514'.
	json at: 'stop_reason' put: 'end_turn'.
	json at: 'stop_sequence' put: nil.
	json at: 'usage' put: (Dictionary new
		at: 'input_tokens' put: 10;
		at: 'output_tokens' put: 25;
		yourself).
	msg := ClaudeMessage fromJson: json.
	self assert: msg id equals: 'msg_01XFDUDYJgAACzvnptvVoYEL'.
	self assert: msg type equals: 'message'.
	self assert: msg role equals: #assistant.
	self assert: msg content size equals: 1.
	self assert: msg content first class equals: ClaudeTextBlock.
	self assert: msg content first text equals: 'Hello!'.
	self assert: msg model equals: 'claude-sonnet-4-20250514'.
	self assert: msg stopReason equals: #end_turn.
	self assert: msg stopSequence isNil.
	self assert: msg usage inputTokens equals: 10.
	self assert: msg usage outputTokens equals: 25
]

{ #category : 'tests' }
ClaudeMessageTest >> testFromJsonDistributesToSubObjects [
	"fromJson: distributes flat API keys into turn, stopDetails, etc."
	| json msg |
	json := Dictionary new.
	json at: 'id' put: 'msg_dist'.
	json at: 'type' put: 'message'.
	json at: 'role' put: 'assistant'.
	json at: 'content' put: { Dictionary new at: 'type' put: 'text'; at: 'text' put: 'hi'; yourself }.
	json at: 'model' put: 'claude-sonnet-4-20250514'.
	json at: 'stop_reason' put: 'end_turn'.
	json at: 'stop_sequence' put: nil.
	json at: 'usage' put: (Dictionary new at: 'input_tokens' put: 5; at: 'output_tokens' put: 10; yourself).
	msg := ClaudeMessage fromJson: json.
	self assert: msg turn class equals: ClaudeTurn.
	self assert: msg turn role equals: 'assistant'.
	self assert: msg turn model equals: 'claude-sonnet-4-20250514'.
	self assert: msg stopDetails class equals: ClaudeStopDetails.
	self assert: msg stopDetails stopReason equals: 'end_turn'
]

{ #category : 'tests' }
ClaudeMessageTest >> testHandleMessageDeltaStopSequence [
	| msg data delta |
	msg := ClaudeMessage new.
	msg turn: (ClaudeTurn new role: #assistant; content: OrderedCollection new; yourself).
	delta := Dictionary new.
	delta at: 'stop_reason' put: 'stop_sequence'.
	delta at: 'stop_sequence' put: 'ENDTOKEN'.
	data := Dictionary new.
	data at: 'delta' put: delta.
	msg handleMessageDelta: data.
	self assert: msg stopReason equals: #stop_sequence.
	self assert: msg stopSequence equals: 'ENDTOKEN'
]

{ #category : 'tests' }
ClaudeMessageTest >> testJsonRoundTrip [
	| original restored |
	original := ClaudeMessage new.
	original id: 'msg_roundtrip'.
	original type: 'message'.
	original role: #assistant.
	original content: (OrderedCollection with: (ClaudeTextBlock text: 'round trip')).
	original model: 'claude-sonnet-4-20250514'.
	original stopReason: #end_turn.
	original stopSequence: nil.
	original usage: (ClaudeUsage new inputTokens: 8; outputTokens: 12; yourself).
	restored := ClaudeMessage fromJson: original asJson.
	self assert: restored id equals: original id.
	self assert: restored type equals: original type.
	self assert: restored role equals: original role.
	self assert: restored content size equals: original content size.
	self assert: restored content first text equals: original content first text.
	self assert: restored model equals: original model.
	self assert: restored stopReason equals: original stopReason.
	self assert: restored stopSequence equals: original stopSequence.
	self assert: restored usage inputTokens equals: original usage inputTokens.
	self assert: restored usage outputTokens equals: original usage outputTokens
]

{ #category : 'tests' }
ClaudeMessageTest >> testOutputFormatAccessor [
	"outputFormat slot can be set and read."
	| msg sentinel |
	msg := ClaudeMessage new.
	sentinel := Object new.
	msg outputFormat: sentinel.
	self assert: msg outputFormat identicalTo: sentinel
]

{ #category : 'tests' }
ClaudeMessageTest >> testOutputFormatDefaultNil [
	"outputFormat defaults to nil on a new ClaudeMessage."
	self assert: ClaudeMessage new outputFormat isNil
]

{ #category : 'tests' }
ClaudeMessageTest >> testOutputFormatNotInAsJson [
	"outputFormat is metadata, not an API field -- must not appear in asJson."
	| msg json |
	msg := ClaudeMessage new.
	msg id: 'msg_fmt'.
	msg role: #assistant.
	msg content: { ClaudeTextBlock text: 'hi' } asOrderedCollection.
	msg outputFormat: Object new.
	json := msg asJson.
	self deny: (json includesKey: 'outputFormat').
	self deny: (json includesKey: 'output_format')
]

{ #category : 'tests' }
ClaudeMessageTest >> testOutputFormatNotInFromJson [
	"fromJson: must not populate outputFormat -- it is not an API field."
	| json msg |
	json := Dictionary new.
	json at: 'id' put: 'msg_fmt2'.
	json at: 'role' put: 'assistant'.
	json at: 'content' put: { Dictionary new at: 'type' put: 'text'; at: 'text' put: 'hi'; yourself }.
	msg := ClaudeMessage fromJson: json.
	self assert: msg outputFormat isNil
]

{ #category : 'tests' }
ClaudeMessageTest >> testRateLimitsAccessor [
  "rateLimits convenience accessor returns the full metadata holder."
  | msg meta |
  msg := ClaudeMessage new.
  self assert: msg rateLimits isNil.
  meta := ClaudeResponseMetadata new.
  msg responseMetadata: meta.
  self assert: msg rateLimits identicalTo: meta
]

{ #category : 'tests' }
ClaudeMessageTest >> testRequestIdAccessor [
	"requestId can be set and read."
	| msg |
	msg := ClaudeMessage new.
	msg requestId: 'req_abc123'.
	self assert: msg requestId equals: 'req_abc123'
]

{ #category : 'tests' }
ClaudeMessageTest >> testRequestIdDefaultNil [
	"requestId defaults to nil on a new ClaudeMessage."
	self assert: ClaudeMessage new requestId isNil
]

{ #category : 'tests' }
ClaudeMessageTest >> testRequestIdNilWhenNoMetadata [
  "requestId reads as nil when no responseMetadata has been attached."
  | msg |
  msg := ClaudeMessage new.
  self assert: msg responseMetadata isNil.
  self assert: msg requestId isNil
]

{ #category : 'tests' }
ClaudeMessageTest >> testRequestIdReadsFromResponseMetadata [
  "requestId storage migrated to ClaudeResponseMetadata in Phase 2
   (mission yvyt+pch2). Setting requestId: lazily creates the metadata
   holder and the surface API stays unchanged for callers."
  | msg |
  msg := ClaudeMessage new.
  msg requestId: 'req_abc123'.
  self assert: msg responseMetadata class equals: ClaudeResponseMetadata.
  self assert: msg responseMetadata requestId equals: 'req_abc123'.
  self assert: msg requestId equals: 'req_abc123'
]

{ #category : 'tests' }
ClaudeMessageTest >> testRequestOutputFormatDelegatesToOutputConfig [
	"ClaudeMessageRequest>>outputFormat delegates to outputConfig format."
	| req sentinel |
	req := ClaudeMessageRequest new.
	self assert: req outputFormat isNil.
	sentinel := Object new.
	req outputConfig format: sentinel.
	self assert: req outputFormat identicalTo: sentinel
]

{ #category : 'tests' }
ClaudeMessageTest >> testStonMigratesLegacyRequestId [
  "Backward-compat regression test (PR #136 round-5).

   Pre-yvyt+pch2 STON snapshots stored requestId inside requestContext.
   After the migration ClaudeRequestContext no longer has a requestId
   slot, so a naive fromSton: silently dropped the legacy value and
   restored messages lost their requestId. ClaudeMessage>>fromSton:
   now rescues a legacy requestContext.requestId into
   responseMetadata.requestId, preserving the surface API across the
   migration. The transient migratedRequestId is cleared after rescue
   so a subsequent re-serialization writes only the new shape."

  | legacyStonString restored |
  legacyStonString := 'ClaudeMessage{#id:''msg_legacy'',#type:''message'',#requestContext:ClaudeRequestContext{#requestId:''req_legacy_abc'',#outputFormat:ClaudeTextOutputFormat{#type:''text''}}}'.
  restored := STON fromString: legacyStonString.
  self assert: restored id equals: 'msg_legacy'.
  self assert: restored requestId equals: 'req_legacy_abc'.
  self assert: restored responseMetadata class equals: ClaudeResponseMetadata.
  self assert: restored responseMetadata requestId equals: 'req_legacy_abc'.
  self assert: restored requestContext outputFormat class equals: ClaudeTextOutputFormat.
  self assert: restored requestContext migratedRequestId isNil
]

{ #category : 'tests' }
ClaudeMessageTest >> testStonRoundTrip [
	"STON round-trip with new 7-slot format."
	| original restored ston |
	original := ClaudeMessage new.
	original id: 'msg_ston'.
	original type: 'message'.
	original turn: (ClaudeTurn role: 'assistant' content: { ClaudeTextBlock text: 'hi' }).
	original stopDetails: (ClaudeStopDetails new stopReason: 'end_turn'; yourself).
	original usage: (ClaudeUsage new inputTokens: 5; outputTokens: 10; yourself).
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored id equals: 'msg_ston'.
	self assert: restored role equals: 'assistant'.
	self assert: restored textContent equals: 'hi'.
	self assert: restored stopReason equals: 'end_turn'.
	self assert: restored usage inputTokens equals: 5
]

{ #category : 'tests' }
ClaudeMessageTest >> testStopDetailsAccessor [
	"stopDetails slot holds a ClaudeStopDetails."
	| msg |
	msg := ClaudeMessage new.
	msg stopReason: #end_turn.
	self assert: msg stopDetails class equals: ClaudeStopDetails.
	self assert: msg stopDetails stopReason equals: #end_turn
]

{ #category : 'tests' }
ClaudeMessageTest >> testTextContent [
	| msg |
	msg := ClaudeMessage new.
	msg content: (OrderedCollection
		with: (ClaudeTextBlock text: 'Hello ')
		with: (ClaudeTextBlock text: 'world')).
	self assert: msg textContent equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeMessageTest >> testTextContentOnNilContent [
	"Regression for bead 8x5. A ClaudeMessage with nil content returns
	an empty string from textContent instead of crashing with DNU on
	nil do:. This happens when an error-only SSE response never
	populated the content slot."

	| msg |
	msg := ClaudeMessage new.
	self assert: msg textContent equals: ''
]

{ #category : 'tests' }
ClaudeMessageTest >> testTextContentWithMixedBlocks [
	| msg |
	msg := ClaudeMessage new.
	msg content: {
		ClaudeTextBlock text: 'Hello '.
		ClaudeToolUseBlock id: 'tu_1' name: 'GetWeather' input: Dictionary new.
		ClaudeTextBlock text: 'world'
	} asOrderedCollection.
	self assert: msg textContent equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeMessageTest >> testToolUseBlocks [
	| msg toolBlocks |
	msg := ClaudeMessage new.
	msg content: (OrderedCollection
		with: (ClaudeTextBlock text: 'Let me check')
		with: (ClaudeToolUseBlock id: 'tu_1' name: 'GetWeather' input: (Dictionary new at: 'city' put: 'London'; yourself))
		with: (ClaudeToolUseBlock id: 'tu_2' name: 'get_time' input: (Dictionary new at: 'tz' put: 'UTC'; yourself))).
	toolBlocks := msg toolUseBlocks.
	self assert: toolBlocks size equals: 2.
	self assert: toolBlocks first name equals: 'GetWeather'.
	self assert: toolBlocks second name equals: 'get_time'
]

{ #category : 'tests' }
ClaudeMessageTest >> testToolUseBlocksOnNilContent [
	"Regression for bead 8x5 — same class of bug as
	testTextContentOnNilContent. A ClaudeMessage with nil content
	returns an empty collection from toolUseBlocks instead of
	crashing with DNU on nil select:."

	| msg |
	msg := ClaudeMessage new.
	self assert: msg toolUseBlocks isEmpty
]

{ #category : 'tests' }
ClaudeMessageTest >> testTurnAccessor [
	"turn slot holds a ClaudeTurn."
	| msg |
	msg := ClaudeMessage userMessage: 'hello'.
	self assert: msg turn class equals: ClaudeTurn.
	self assert: msg turn role equals: 'user'.
	self assert: msg turn content size equals: 1
]
