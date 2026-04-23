"
Unit tests for ClaudeThinkingBlock — accessors, type tag, and the isThinkingBlock polymorphic predicate. See bead 1xgi.

  ClaudeThinkingBlockTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeThinkingBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeThinkingBlockTest >> testIsThinkingBlockDefaultFalse [
	"All non-thinking content blocks inherit the false default from
	 ClaudeContentBlock so the polymorphic predicate distinguishes
	 thinking blocks cleanly from every other content type — text,
	 tool-use, and the abstract base itself. Each assertion below
	 represents a different concrete class plus the base default."

	self deny: ClaudeTextBlock new isThinkingBlock.
	self deny: ClaudeToolUseBlock new isThinkingBlock.
	self deny: ClaudeContentBlock new isThinkingBlock
]

{ #category : 'tests' }
ClaudeThinkingBlockTest >> testIsThinkingBlockOnInstance [
	"ClaudeThinkingBlock answers true to the isThinkingBlock predicate.
	 Used by code that filters response content for chain-of-thought blocks
	 without resorting to isKindOf:."

	self assert: ClaudeThinkingBlock new isThinkingBlock.
	self assert: (ClaudeThinkingBlock new thinking: 'reasoning'; signature: 'sig'; yourself) isThinkingBlock
]

{ #category : 'tests' }
ClaudeThinkingBlockTest >> testSignatureRoundTrip [
	"The cryptographic signature on a ClaudeThinkingBlock must round-trip
	 byte-for-byte when the block is replayed in a subsequent assistant
	 turn. Anthropic's servers verify the signature against the thinking
	 content; any mutation breaks multi-turn thinking-aware agents.
	 
	 This exercises the full path: build a ClaudeThinkingBlock, wrap it in
	 a ClaudeMessage as an assistant turn, serialize the request,
	 re-parse the message via ClaudeMessage class>>fromJson:, and assert the
	 signature is preserved character-for-character.

	 ClaudeMessageRequest class>>fromJson: does not exist on HEAD and is out of
	 scope here — we re-parse the messages-array element via
	 ClaudeMessage class>>fromJson:, which dispatches through
	 ClaudeContentBlock class>>fromJson: into ClaudeThinkingBlock class>>fromJson:."
	| block message request json msgArr restored |
	block := ClaudeThinkingBlock new
		thinking: 'Reasoning step.';
		signature: 'abc123signature';
		yourself.
	message := ClaudeMessage new
		turn: (ClaudeTurn role: 'assistant' content: { block });
		yourself.
	request := ClaudeMessageRequest new.
	request model: 'claude-sonnet-4-6'.
	request maxTokens: 100.
	request addUserMessage: 'hi'.
	request addAssistantResponse: message.
	json := request asJson.
	"Wire form has the signature at messages[1].content[0].signature."
	msgArr := json at: 'messages'.
	self assert: (((msgArr second) at: 'content') first at: 'signature')
		equals: 'abc123signature'.
	"Round-trip back through ClaudeMessage fromJson: — verifies the read
	 path also preserves the signature."
	restored := ClaudeMessage fromJson: msgArr second.
	self assert: restored content first signature equals: 'abc123signature'
]

{ #category : 'tests' }
ClaudeThinkingBlockTest >> testStonSignatureRoundTrip [
	"Ensure the STON serialization/deserialization path preserves the
	 thinking text and cryptographic signature exactly.

	 This pins the STON round-trip contract for ClaudeThinkingBlock so
	 a future refactor that changes how these fields are written or read
	 fails loudly before it can corrupt a session-replayed conversation."
	| original ston restored |
	original := ClaudeThinkingBlock new
		thinking: 'reason';
		signature: 'abc123';
		yourself.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored signature equals: 'abc123'.
	self assert: restored thinking equals: 'reason'
]
