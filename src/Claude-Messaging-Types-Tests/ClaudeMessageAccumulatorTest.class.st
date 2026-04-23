"
Tests for ClaudeMessage>>accumulate: — the streaming event accumulator that builds a complete message from a sequence of SSE events.
"
Class {
	#name : 'ClaudeMessageAccumulatorTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateFullSequence [
	| msg |
	msg := ClaudeMessage new.

	"message_start"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_start';
		at: 'data' put: (Dictionary new
			at: 'message' put: (Dictionary new
				at: 'id' put: 'msg_acc01';
				at: 'type' put: 'message';
				at: 'role' put: 'assistant';
				at: 'model' put: 'claude-sonnet-4-20250514';
				at: 'content' put: #();
				at: 'usage' put: (Dictionary new at: 'input_tokens' put: 42; yourself);
				yourself);
			yourself);
		yourself).

	"content_block_start"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary new
				at: 'type' put: 'text';
				at: 'text' put: '';
				yourself);
			yourself);
		yourself).

	"3 text deltas"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'text_delta'; at: 'text' put: 'Hel'; yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'text_delta'; at: 'text' put: 'lo '; yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'text_delta'; at: 'text' put: 'world'; yourself);
			yourself);
		yourself).

	"content_block_stop"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).

	"message_delta"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_delta';
		at: 'data' put: (Dictionary new
			at: 'delta' put: (Dictionary new at: 'stop_reason' put: 'end_turn'; yourself);
			at: 'usage' put: (Dictionary new at: 'output_tokens' put: 15; yourself);
			yourself);
		yourself).

	"message_stop"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_stop';
		at: 'data' put: Dictionary new;
		yourself).

	self assert: msg textContent equals: 'Hello world'.
	self assert: msg stopReason equals: #end_turn.
	self assert: msg usage outputTokens equals: 15.
	self assert: msg id equals: 'msg_acc01'.
	self assert: msg role equals: #assistant.
	self assert: msg content size equals: 1
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateIgnoresPing [
	| msg |
	msg := ClaudeMessage new.

	"message_start"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_start';
		at: 'data' put: (Dictionary new
			at: 'message' put: (Dictionary new
				at: 'id' put: 'msg_ping';
				at: 'type' put: 'message';
				at: 'role' put: 'assistant';
				at: 'model' put: 'claude-sonnet-4-20250514';
				at: 'content' put: #();
				at: 'usage' put: (Dictionary new at: 'input_tokens' put: 5; yourself);
				yourself);
			yourself);
		yourself).

	"content_block_start"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary new at: 'type' put: 'text'; at: 'text' put: ''; yourself);
			yourself);
		yourself).

	"ping in the middle"
	msg accumulate: (Dictionary new
		at: 'event' put: 'ping';
		at: 'data' put: Dictionary new;
		yourself).

	"text delta after ping"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'text_delta'; at: 'text' put: 'works'; yourself);
			yourself);
		yourself).

	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).

	self assert: msg textContent equals: 'works'.
	self assert: msg content size equals: 1
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateMultipleBlocks [
	| msg |
	msg := ClaudeMessage new.

	msg accumulate: (Dictionary new
		at: 'event' put: 'message_start';
		at: 'data' put: (Dictionary new
			at: 'message' put: (Dictionary new
				at: 'id' put: 'msg_multi';
				at: 'type' put: 'message';
				at: 'role' put: 'assistant';
				at: 'model' put: 'claude-sonnet-4-20250514';
				at: 'content' put: #();
				at: 'usage' put: (Dictionary new at: 'input_tokens' put: 10; yourself);
				yourself);
			yourself);
		yourself).

	"First block: text"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary new at: 'type' put: 'text'; at: 'text' put: 'Hello'; yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).

	"Second block: tool_use"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 1;
			at: 'content_block' put: (Dictionary new
				at: 'type' put: 'tool_use';
				at: 'id' put: 'tu_01';
				at: 'name' put: 'GetWeather';
				at: 'input' put: Dictionary new;
				yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 1; yourself);
		yourself).

	self assert: msg content size equals: 2.
	self assert: msg content first class equals: ClaudeTextBlock.
	self assert: msg content second class equals: ClaudeToolUseBlock.
	self assert: msg content second name equals: 'GetWeather'
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulatePreservesUsage [
	| msg |
	msg := ClaudeMessage new.

	"message_start with input_tokens"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_start';
		at: 'data' put: (Dictionary new
			at: 'message' put: (Dictionary new
				at: 'id' put: 'msg_usage';
				at: 'type' put: 'message';
				at: 'role' put: 'assistant';
				at: 'model' put: 'claude-sonnet-4-20250514';
				at: 'content' put: #();
				at: 'usage' put: (Dictionary new at: 'input_tokens' put: 100; yourself);
				yourself);
			yourself);
		yourself).

	"message_delta with output_tokens"
	msg accumulate: (Dictionary new
		at: 'event' put: 'message_delta';
		at: 'data' put: (Dictionary new
			at: 'delta' put: (Dictionary new at: 'stop_reason' put: 'end_turn'; yourself);
			at: 'usage' put: (Dictionary new at: 'output_tokens' put: 50; yourself);
			yourself);
		yourself).

	self assert: msg usage inputTokens equals: 100.
	self assert: msg usage outputTokens equals: 50
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateRaisesBaseErrorOnUnknownErrorType [
	"When the SSE error.type is not in the registry (future Anthropic
	error type, or malformed payload), fall back to ClaudeApiError so
	the caller still gets an exception instead of a silent nil content
	crash. Bead 8x5."

	| msg event raised |
	msg := ClaudeMessage new.
	event := Dictionary new
		at: 'event' put: 'error';
		at: 'data' put: (Dictionary new
			at: 'type' put: 'error';
			at: 'error' put: (Dictionary new
				at: 'type' put: 'brand_new_error_we_do_not_know_about';
				at: 'message' put: 'mystery';
				yourself);
			yourself);
		yourself.
	raised := false.
	[ msg accumulate: event ]
		on: ClaudeApiError
		do: [ :e |
			raised := true.
			"Exactly ClaudeApiError, not a subclass"
			self assert: e class equals: ClaudeApiError.
			self assert: e message equals: 'mystery' ].
	self assert: raised
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateRaisesOnErrorEvent [
	"Regression for bead 8x5. When the Claude API streams an error SSE
	event (rate limit, overload), accumulate: must raise the matching
	ClaudeApiError subclass instead of silently leaving content nil.
	Pre-fix: the error event fell through accumulate:, content stayed
	nil, textContent crashed with DNU on nil do:."

	| msg event |
	msg := ClaudeMessage new.
	event := Dictionary new
		at: 'event' put: 'error';
		at: 'data' put: (Dictionary new
			at: 'type' put: 'error';
			at: 'error' put: (Dictionary new
				at: 'type' put: 'overloaded_error';
				at: 'message' put: 'Overloaded';
				yourself);
			yourself);
		yourself.
	self
		should: [ msg accumulate: event ]
		raise: ClaudeOverloadedError
		withExceptionDo: [ :e |
			self assert: e message equals: 'Overloaded' ]
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateRaisesRateLimitOnErrorEvent [
	"Complements testAccumulateRaisesOnErrorEvent. Verifies the registry
	routes 'rate_limit_error' to ClaudeRateLimitError, not just the
	overloaded path. Bead 8x5."

	| msg event |
	msg := ClaudeMessage new.
	event := Dictionary new
		at: 'event' put: 'error';
		at: 'data' put: (Dictionary new
			at: 'type' put: 'error';
			at: 'error' put: (Dictionary new
				at: 'type' put: 'rate_limit_error';
				at: 'message' put: 'Rate limited';
				yourself);
			yourself);
		yourself.
	self
		should: [ msg accumulate: event ]
		raise: ClaudeRateLimitError
		withExceptionDo: [ :e |
			self assert: e message equals: 'Rate limited' ]
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateThinkingBlock [
	| msg block |
	msg := ClaudeMessage new.
	msg content: OrderedCollection new.

	"content_block_start for thinking"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary new
				at: 'type' put: 'thinking';
				at: 'thinking' put: '';
				yourself);
			yourself);
		yourself).

	"thinking_delta"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'thinking_delta'; at: 'thinking' put: 'Let me reason step by step.'; yourself);
			yourself);
		yourself).

	"signature_delta"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'signature_delta'; at: 'signature' put: 'ErQC...'; yourself);
			yourself);
		yourself).

	"content_block_stop"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).

	block := msg content first.
	self assert: block class equals: ClaudeThinkingBlock.
	self assert: block thinking equals: 'Let me reason step by step.'.
	self assert: block signature equals: 'ErQC...'
]

{ #category : 'tests' }
ClaudeMessageAccumulatorTest >> testAccumulateToolUseInput [
	| msg block |
	msg := ClaudeMessage new.
	msg content: OrderedCollection new.

	"content_block_start for tool_use"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_start';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'content_block' put: (Dictionary new
				at: 'type' put: 'tool_use';
				at: 'id' put: 'tu_json';
				at: 'name' put: 'GetWeather';
				at: 'input' put: Dictionary new;
				yourself);
			yourself);
		yourself).

	"3 input_json_delta events"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'input_json_delta'; at: 'partial_json' put: '{"ci'; yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'input_json_delta'; at: 'partial_json' put: 'ty":"Pa'; yourself);
			yourself);
		yourself).
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_delta';
		at: 'data' put: (Dictionary new
			at: 'index' put: 0;
			at: 'delta' put: (Dictionary new at: 'type' put: 'input_json_delta'; at: 'partial_json' put: 'ris"}'; yourself);
			yourself);
		yourself).

	"content_block_stop finalizes JSON parsing"
	msg accumulate: (Dictionary new
		at: 'event' put: 'content_block_stop';
		at: 'data' put: (Dictionary new at: 'index' put: 0; yourself);
		yourself).

	block := msg content first.
	self assert: block class equals: ClaudeToolUseBlock.
	self assert: block input isDictionary.
	self assert: (block input at: 'city') equals: 'Paris'
]
