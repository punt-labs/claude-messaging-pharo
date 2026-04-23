"
Demonstrate extended thinking. Builds a ClaudeMessageRequest that
enables the thinking feature with a 1024-token budget and asks the
model a reasoning-heavy question. The response carries at least one
ClaudeThinkingBlock alongside the assistant's final ClaudeTextBlock.

Extended thinking is uniquely well-suited to live integration tests
because both the thinking content and its cryptographic signature are
server-computed. The client cannot fabricate either value: the
signature is derived from the thinking content plus server-side
secrets and is required to round-trip thinking blocks in subsequent
requests.

**Budget versus maxTokens.** Anthropic's API requires
`max_tokens > budget_tokens`. We set `budgetTokens: 1024` and
`maxTokens: 2048` so the model has 1024 tokens for reasoning and up
to another 1024 for the final answer. Smaller budgets (below ~1024)
often produce no thinking block at all because the model decides the
problem does not warrant deliberation.

**Why Monty Hall.** The prompt is a reasoning-heavy puzzle whose
counter-intuitive answer (2/3, not 1/2) drives the model to produce
visible chain-of-thought. A trivia question would often collapse to
a single text block.

**Wiring.** `ClaudeMessageRequest` has no `thinkingParams:` setter.
Set thinking via `req thinking: aDict`, where the dict is built from
`ClaudeThinkingParams enabled: aBudget asDictionary`. The request
serializer reads back into `thinkingParams` and appends a `thinking`
field to the wire body.

  ClaudeMessagingThinkingExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingThinkingExample buildRequest maxTokens
  >>> 2048

  ClaudeMessagingThinkingExample buildRequest thinkingParams type
  >>> 'enabled'

  ClaudeMessagingThinkingExample buildRequest thinkingParams budgetTokens
  >>> 1024

"
Class {
	#name : 'ClaudeMessagingThinkingExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingThinkingExample class >> buildRequest [
	"Build a ClaudeMessageRequest that enables extended thinking with a
	 1024-token budget and asks a reasoning-heavy question. The response
	 will carry at least one ClaudeThinkingBlock alongside the assistant's
	 final text. maxTokens is set to 2048 so budget (1024) + final answer
	 (up to ~1024) both fit within Anthropic's max_tokens > budget_tokens
	 constraint."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 2048.
	req thinking: (ClaudeThinkingParams enabled: 1024) asDictionary.
	req addUserMessage:
		'What is the Monty Hall problem? Show your reasoning step by step, then give the final answer.'.
	^ req
]

{ #category : 'private' }
ClaudeMessagingThinkingExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingThinkingExample class >> run [
	"Send the example thinking-enabled request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingThinkingExample class >> runOn: aClient [
	"Send the thinking-enabled request using the given client and return the
	 response. The response content includes at least one ClaudeThinkingBlock
	 when the model decides the question warrants deliberation."
	^ aClient sendMessage: self buildRequest
]
