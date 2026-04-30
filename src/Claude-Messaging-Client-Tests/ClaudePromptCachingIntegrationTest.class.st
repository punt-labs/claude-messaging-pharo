"
Live end-to-end integration test for prompt caching. Issues two
sequential Messages API calls against api.anthropic.com using
`ClaudeMessagingPromptCachingExample runTwiceOn: client` and asserts
the server-computed cache metrics: cold call writes an entry
(`cacheCreationInputTokens > 0`), warm call reads from it
(`cacheReadInputTokens > 0`).

This test exists because cache behaviour cannot be mock-verified.
`cacheCreationInputTokens` and `cacheReadInputTokens` are populated by
Anthropic's infrastructure, not by our client. Only a live round-trip
proves that the `cache_control: ephemeral` field we emit on the system
block actually reaches the server, that the block crosses the minimum
cacheable-size threshold, and that the cache is hit on a second request
with identical body.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present the test skips via
`self skip` -- it does not fail on a key-less image. The default suite
(`ClaudeMessagingTestSuite suite`) excludes this class by protocol;
only `integrationSuite` includes it.

**Threshold dependency.** Caching requires a single block of ~1024+
tokens per Anthropic's docs, but Sonnet 4.6 empirically needs ~2048
tokens before the cache fields populate. `longCachedSystemText` is
sized to ~2500 tokens to leave a safety margin. If the threshold rises
or the tokenizer shifts the block below whatever the current cut-off is,
the server silently skips caching and both assertions fail. That
failure mode is an intentional red flag, not a bug in the code -- the
fix is to extend the prompt, not to weaken the assertion.

**External-infrastructure dependency.** An Anthropic API outage or
cache-subsystem regression can turn this test red without any change
on our side. Triage should distinguish upstream infra from a local
regression.

**No cleanup.** Prompt caching is server-managed: ephemeral entries
expire on their own (~5 minutes) and our client creates no named
resources. Absence of an `ensure:` block is intentional.

  ClaudePromptCachingIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudePromptCachingIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudePromptCachingIntegrationTest >> defaultTimeLimit [
	"Two live round-trips to api.anthropic.com plus model generation time
	 on each. The default 10 s test timeout fires before a healthy
	 round-trip completes. 2 minutes matches ClaudeMCPIntegrationTest and
	 ClaudeServerToolIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudePromptCachingIntegrationTest >> testPromptCachingCacheCreationAndReadCyclesAgainstAnthropic [
	"Drive two sequential sendMessage: calls against api.anthropic.com with
	 the SAME request body (required for cache-key equality). Assert that:
	 (a) call 1 reports a positive cacheCreationInputTokens (server wrote
	     a new cache entry for the ~2500-token cache-controlled block);
	 (b) call 2 reports a positive cacheReadInputTokens (server hit the
	     cache entry from call 1).

	 `runTwiceOn:` embeds a per-test-run UUID salt (one UUID shared across
	 both calls to keep the cache key identical) so the first call is
	 always cold. Without the salt, prior runs (this process, an earlier
	 test invocation, or a parallel integration run) would prime the cache
	 and collapse the creation assertion to zero. Both metrics are server-
	 computed -- the client cannot fabricate them.

	 Skips cleanly when no API key is present. No cleanup: ephemeral cache
	 entries expire on their own and the client creates no named resources."

	| client pair first second |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	pair := ClaudeMessagingPromptCachingExample runTwiceOn: client.
	first := pair first.
	second := pair second.
	"Server-computed: cold call creates a new cache entry for the block."
	self
		assert: (first usage cacheCreationInputTokens isNotNil
			and: [ first usage cacheCreationInputTokens > 0 ])
		description: 'cold call must report cacheCreationInputTokens > 0; got '
			, first usage cacheCreationInputTokens printString.
	"Server-computed: warm call reads from the entry written above."
	self
		assert: (second usage cacheReadInputTokens isNotNil
			and: [ second usage cacheReadInputTokens > 0 ])
		description: 'warm call must report cacheReadInputTokens > 0; got '
			, second usage cacheReadInputTokens printString
]
