"
Demonstrate prompt caching. Builds a ClaudeMessageRequest with a
cache-controlled system prompt (~2500 tokens) and a short user message.
Sending the same request twice exercises the full write-then-read
cycle: the first call populates the server-side cache and reports
`cacheCreationInputTokens > 0`; the second call hits the cache and
reports `cacheReadInputTokens > 0`.

Prompt caching is uniquely well-suited to live integration tests
because the cache metrics are server-computed and visible on the
response `usage` field. The client cannot fake these values.

**Threshold.** Anthropic's published minimum for Claude 3.5 Sonnet is
1024 tokens in the single block carrying `cache_control`. Empirical
checks against Sonnet 4.6 (April 2026) show the effective threshold
sits above 1659 tokens and at-or-below 2202 tokens for that model.
The text produced by `longCachedSystemText` is sized to ~2500 tokens
so the test stays green even if the documented threshold rises again
or tokenizer behaviour shifts by a few percent. The threshold applies
to the SINGLE block carrying the `cache_control` marker, not to the
whole request. A 2 KB system prompt split across ten 200-byte blocks
would cache nothing.

**Cache-key equality.** The server-side cache key is derived from the
exact bytes of the request body. `buildRequest` returns a fresh
instance on every call, but both instances serialize to the same JSON
because `longCachedSystemText` is deterministic. Any variation in
system text, message ordering, or user content invalidates the cache
and resets both metrics to zero.

**Wiring.** The example uses `systemBlocks:` (NOT `system:`). Only a
`ClaudeTextBlock` with `cacheControl:` set is serialized with a
`cache_control` field in JSON; `system:` writes a plain string with no
cache metadata.

  ClaudeMessagingPromptCachingExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingPromptCachingExample buildRequest maxTokens
  >>> 256

  ClaudeMessagingPromptCachingExample buildRequest system first cacheControl type
  >>> 'ephemeral'

  ClaudeMessagingPromptCachingExample buildRequest system size
  >>> 1

"
Class {
	#name : 'ClaudeMessagingPromptCachingExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingPromptCachingExample class >> buildRequest [
	"Build the default example request using a stable 'default' salt for
	 REPL convenience -- NOT suitable for the integration test's cold-cache
	 assertion; use #buildRequestWithSalt: with a fresh UUID for test
	 isolation."
	^ self buildRequestWithSalt: 'default'
]

{ #category : 'building' }
ClaudeMessagingPromptCachingExample class >> buildRequestWithSalt: aString [
	"Build a ClaudeMessageRequest whose cache-controlled system block is
	 prefixed with aString, a per-test-run salt. Two calls sharing the same
	 salt hit the same cache entry; different salts produce distinct keys.

	 The salt is prepended to the single cache-controlled text block so
	 identical bodies share a cache key without adding a second block that
	 would dilute the minimum-token rule. Uses systemBlocks: (NOT system:)
	 because only a ClaudeTextBlock with cacheControl: set is serialized
	 with a cache_control field in JSON."
	| req block text |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 256.
	text := 'Run ID: ' , aString , String lf , String lf , self longCachedSystemText.
	block := ClaudeTextBlock text: text.
	block cacheControl: ClaudeCacheControl ephemeral.
	req systemBlocks: { block }.
	req addUserMessage: 'Summarize your system prompt in one sentence.'.
	^ req
]

{ #category : 'building' }
ClaudeMessagingPromptCachingExample class >> longCachedSystemText [
	"Answer a multi-paragraph system prompt long enough to cross Anthropic's
	 minimum cacheable-block threshold for Claude Sonnet 4.x. The
	 documented minimum is 1024 tokens, but empirical checks against
	 api.anthropic.com (April 2026) show the effective threshold for
	 Sonnet 4.6 sits above 1659 tokens and at-or-below 2202. We target
	 ~2500 tokens to leave a safety margin so future tokenizer drift or
	 a documented threshold bump cannot silently drop the block under
	 the cut-off and invalidate the test.

	 The block marked with cache_control: ephemeral must itself exceed
	 the threshold -- the total request size does not count. Content is
	 deterministic filler followed by an actual instruction; cache-key
	 equality requires byte-for-byte identical content across the two
	 calls, so this method must be pure and return the same string on
	 every invocation."
	| pad lf |
	pad := 'You are a careful software engineer. You explain decisions in terms of trade-offs, not absolutes. When you cannot prove a claim you say so. You prefer small, reversible steps over large irreversible ones. You name variables for what they represent in the domain, not how they are implemented. You read tests before production code because tests document intent. You distinguish between facts (what the code does today), hypotheses (what you think it does), and aspirations (what you wish it did). You never conflate the three. You write methods that do exactly one thing and name them so a reader can guess the body. You prefer composition over inheritance because composition is explicit and inheritance is implicit. You use polymorphism instead of type-tag conditionals when a new case would otherwise require editing the same switch statement twice. You run the smallest test that could possibly fail before writing the smallest code that could possibly pass. You refactor only after the tests are green because refactoring with a red bar is gambling. You keep each commit small enough to describe in one line and atomic enough to revert without collateral damage. You treat warnings as errors because warnings erode attention over time. You document why, not what -- the code already shows what. You leave the campsite cleaner than you found it because every file you touch is a chance to reduce entropy.'.
	lf := String lf.
	^ String streamContents: [ :s |
		1 to: 9 do: [ :i |
			s nextPutAll: pad; nextPutAll: lf; nextPutAll: lf ].
		s nextPutAll: 'Given the principles above, when the user asks a question, answer it with one concise sentence. No preamble. No apology. No hedging. Just the answer.' ]
]

{ #category : 'private' }
ClaudeMessagingPromptCachingExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingPromptCachingExample class >> run [
	"Send the example request using a resolved client and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingPromptCachingExample class >> runOn: aClient [
	"Send the cache-controlled request using the given client and return the
	 response. Call twice with the same request body to exercise write-then-
	 read: the first call populates the cache, the second reads from it."
	^ aClient sendMessage: self buildRequest
]

{ #category : 'examples' }
ClaudeMessagingPromptCachingExample class >> runTwiceOn: aClient [
	"Issue two sequential sendMessage: calls with the SAME request body
	 (a per-run salt keeps the first call cold). Returns an Array of two
	 responses so the caller can assert server-computed cache metrics on
	 each. This is the preferred entry-point for integration tests that
	 need to observe cache creation followed by cache read."
	| req r1 r2 |
	req := self buildRequestWithSalt: UUID new asString36.
	r1 := aClient sendMessage: req.
	r2 := aClient sendMessage: req.
	^ { r1. r2 }
]
