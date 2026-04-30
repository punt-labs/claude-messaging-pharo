"
Tests for ClaudeResponseMetadata --- header parsing per Anthropic-Ratelimit-* wire names, nil tolerance, hasRateLimits predicate, retryAfter handling, printOn:, and STON round-trip.
"
Class {
	#name : 'ClaudeResponseMetadataTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'fixtures' }
ClaudeResponseMetadataTest >> fixtureFullHeaders [
  "ZnHeaders populated with one of every documented response header
   plus request-id and Retry-After. Mixed case on the wire — HTTP
   header lookup is case-insensitive and ZnHeaders honors that."
  | h |
  h := ZnHeaders new.
  h at: 'request-id' put: 'req_full'.
  h at: 'Anthropic-Ratelimit-Requests-Limit' put: '100'.
  h at: 'Anthropic-Ratelimit-Requests-Remaining' put: '98'.
  h at: 'Anthropic-Ratelimit-Requests-Reset' put: '2026-04-22T17:30:00Z'.
  h at: 'Anthropic-Ratelimit-Input-Tokens-Limit' put: '50000'.
  h at: 'Anthropic-Ratelimit-Input-Tokens-Remaining' put: '49950'.
  h at: 'Anthropic-Ratelimit-Input-Tokens-Reset' put: '2026-04-22T17:30:01Z'.
  h at: 'Anthropic-Ratelimit-Output-Tokens-Limit' put: '20000'.
  h at: 'Anthropic-Ratelimit-Output-Tokens-Remaining' put: '19900'.
  h at: 'Anthropic-Ratelimit-Output-Tokens-Reset' put: '2026-04-22T17:30:02Z'.
  h at: 'Retry-After' put: '5'.
  ^ h
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testFromZnHeadersAbsentAllSlotsNil [
  "Zero rate-limit headers present: every rate-limit slot reads nil and
   hasRateLimits answers false. requestId still resolves if present."
  | meta h |
  h := ZnHeaders new.
  h at: 'request-id' put: 'req_only'.
  meta := ClaudeResponseMetadata fromZnHeaders: h.
  self assert: meta requestId equals: 'req_only'.
  self assert: meta rateLimitRequestsLimit isNil.
  self assert: meta rateLimitRequestsRemaining isNil.
  self assert: meta rateLimitRequestsReset isNil.
  self assert: meta rateLimitInputTokensLimit isNil.
  self assert: meta rateLimitInputTokensRemaining isNil.
  self assert: meta rateLimitInputTokensReset isNil.
  self assert: meta rateLimitOutputTokensLimit isNil.
  self assert: meta rateLimitOutputTokensRemaining isNil.
  self assert: meta rateLimitOutputTokensReset isNil.
  self assert: meta retryAfter isNil.
  self deny: meta hasRateLimits
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testFromZnHeadersCaseInsensitive [
  "HTTP header lookup is case-insensitive. The parser looks up lowercase
   names; ZnHeaders resolves any spelling. Verify by populating mixed-case."
  | h meta |
  h := ZnHeaders new.
  h at: 'ANTHROPIC-RATELIMIT-REQUESTS-REMAINING' put: '42'.
  h at: 'retry-after' put: '3'.
  meta := ClaudeResponseMetadata fromZnHeaders: h.
  self assert: meta rateLimitRequestsRemaining equals: 42.
  self assert: meta retryAfter equals: 3
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testFromZnHeadersEmptyHeadersAllNil [
  "Completely empty headers: every slot reads nil, no exceptions."
  | meta |
  meta := ClaudeResponseMetadata fromZnHeaders: ZnHeaders new.
  self assert: meta requestId isNil.
  self assert: meta retryAfter isNil.
  self deny: meta hasRateLimits
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testFromZnHeadersFullSet [
  "All nine ratelimit headers + request-id + Retry-After resolve to typed
   integer slots and raw ISO-8601 reset timestamps. hasRateLimits true."
  | meta |
  meta := ClaudeResponseMetadata fromZnHeaders: self fixtureFullHeaders.
  self assert: meta requestId equals: 'req_full'.
  self assert: meta rateLimitRequestsLimit equals: 100.
  self assert: meta rateLimitRequestsRemaining equals: 98.
  self assert: meta rateLimitRequestsReset equals: '2026-04-22T17:30:00Z'.
  self assert: meta rateLimitInputTokensLimit equals: 50000.
  self assert: meta rateLimitInputTokensRemaining equals: 49950.
  self assert: meta rateLimitInputTokensReset equals: '2026-04-22T17:30:01Z'.
  self assert: meta rateLimitOutputTokensLimit equals: 20000.
  self assert: meta rateLimitOutputTokensRemaining equals: 19900.
  self assert: meta rateLimitOutputTokensReset equals: '2026-04-22T17:30:02Z'.
  self assert: meta retryAfter equals: 5.
  self assert: meta hasRateLimits
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testFromZnHeadersMalformedIntegerSlotsNil [
  "Non-numeric values for integer-typed headers (rate-limit counters and
   Retry-After) parse to nil rather than crashing message/error parsing.
   Reset slots stay as the raw String — they are not parsed."
  | h meta |
  h := ZnHeaders new.
  h at: 'request-id' put: 'req_bad'.
  h at: 'anthropic-ratelimit-requests-limit' put: 'NaN'.
  h at: 'anthropic-ratelimit-requests-remaining' put: 'foo'.
  h at: 'anthropic-ratelimit-input-tokens-limit' put: 'bar'.
  h at: 'anthropic-ratelimit-input-tokens-remaining' put: 'baz'.
  h at: 'anthropic-ratelimit-output-tokens-limit' put: 'qux'.
  h at: 'anthropic-ratelimit-output-tokens-remaining' put: 'quux'.
  h at: 'anthropic-ratelimit-requests-reset' put: '2026-04-22T17:30:00Z'.
  h at: 'retry-after' put: 'later'.
  meta := ClaudeResponseMetadata fromZnHeaders: h.
  self assert: meta requestId equals: 'req_bad'.
  self assert: meta rateLimitRequestsLimit isNil.
  self assert: meta rateLimitRequestsRemaining isNil.
  self assert: meta rateLimitInputTokensLimit isNil.
  self assert: meta rateLimitInputTokensRemaining isNil.
  self assert: meta rateLimitOutputTokensLimit isNil.
  self assert: meta rateLimitOutputTokensRemaining isNil.
  self assert: meta retryAfter isNil.
  "Reset slot is not integer-parsed; the raw String survives."
  self assert: meta rateLimitRequestsReset equals: '2026-04-22T17:30:00Z'
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testHasRateLimitsAnyRateLimitSlotTrue [
	"Any single ratelimit slot tips hasRateLimits to true. Verify each."
	| slots |
	slots := #(
		rateLimitRequestsLimit:
		rateLimitRequestsRemaining:
		rateLimitRequestsReset:
		rateLimitInputTokensLimit:
		rateLimitInputTokensRemaining:
		rateLimitInputTokensReset:
		rateLimitOutputTokensLimit:
		rateLimitOutputTokensRemaining:
		rateLimitOutputTokensReset:).
	slots do: [ :sel |
		| meta |
		meta := ClaudeResponseMetadata new.
		meta perform: sel with: 1.
		self
			assert: meta hasRateLimits
			description: (String streamContents: [ :s |
				s nextPutAll: 'hasRateLimits should be true after setting '.
				s nextPutAll: sel ]) ]
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testHasRateLimitsRequestIdAlone [
  "request-id and retry-after never count toward hasRateLimits."
  | meta |
  meta := ClaudeResponseMetadata new
    requestId: 'req_x';
    retryAfter: 5;
    yourself.
  self deny: meta hasRateLimits
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testHeaderNameCatalogMatchesGoSDK [
  "Pin the wire names against the Go SDK's recorded cassette form
   (.tmp/anthropic-sdk-go/toolrunner/testdata/cassettes/
   tool_runner_custom_handling.yaml). HTTP/1.1 header lookup is
   case-insensitive (RFC 7230 §3.2) so the lowercase canonical form
   here resolves the cassette's mixed-case spellings on the wire."
  | wireNames expected |
  wireNames := (ClaudeResponseMetadata rateLimitHeaderNames
    collect: [ :pair | pair second ]) asArray.
  expected := #(
    'anthropic-ratelimit-requests-limit'
    'anthropic-ratelimit-requests-remaining'
    'anthropic-ratelimit-requests-reset'
    'anthropic-ratelimit-input-tokens-limit'
    'anthropic-ratelimit-input-tokens-remaining'
    'anthropic-ratelimit-input-tokens-reset'
    'anthropic-ratelimit-output-tokens-limit'
    'anthropic-ratelimit-output-tokens-remaining'
    'anthropic-ratelimit-output-tokens-reset').
  self assert: wireNames equals: expected
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testPrintOnEmpty [
  "Empty metadata prints with ?-marked request-id, no rate-limit section."
  self assert: ClaudeResponseMetadata new printString equals: 'ClaudeResponseMetadata(req-id=?)'
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testPrintOnFull [
  "Full metadata prints with rate-limit fractions + retry-after."
  | meta |
  meta := ClaudeResponseMetadata fromZnHeaders: self fixtureFullHeaders.
  self assert: meta printString equals:
    'ClaudeResponseMetadata(req-id=req_full req 98/100 input 49950/50000 output 19900/20000 retry-after=5)'
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testPrintOnPartialRateLimits [
  "When a rate-limit axis has Limit but not Remaining (or vice versa),
   the axis is skipped instead of rendering literal 'nil' fractions.
   Only fully-populated axes appear; retry-after is independent."
  | metaInputOnly metaPartialReq metaWithRetry |
  "Only the input axis is fully populated; req and output get skipped."
  metaInputOnly := ClaudeResponseMetadata new
    requestId: 'req_partial';
    rateLimitInputTokensLimit: 50000;
    rateLimitInputTokensRemaining: 49000;
    yourself.
  self assert: metaInputOnly printString equals:
    'ClaudeResponseMetadata(req-id=req_partial input 49000/50000)'.

  "Req axis has Limit but not Remaining --- the whole axis is skipped."
  metaPartialReq := ClaudeResponseMetadata new
    requestId: 'req_p';
    rateLimitRequestsLimit: 100;
    yourself.
  self assert: metaPartialReq printString equals: 'ClaudeResponseMetadata(req-id=req_p)'.

  "retry-after still prints even when no axis is fully populated."
  metaWithRetry := ClaudeResponseMetadata new
    rateLimitOutputTokensRemaining: 5;
    retryAfter: 7;
    yourself.
  self assert: metaWithRetry printString equals:
    'ClaudeResponseMetadata(req-id=? retry-after=7)'
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testRetryAfterParsing [
  "Retry-After parses to seconds Integer per RFC 7231 §7.1.3."
  | h meta |
  h := ZnHeaders new.
  h at: 'Retry-After' put: '10'.
  meta := ClaudeResponseMetadata fromZnHeaders: h.
  self assert: meta retryAfter equals: 10
]

{ #category : 'tests' }
ClaudeResponseMetadataTest >> testStonRoundTrip [
  | original ston restored |
  original := ClaudeResponseMetadata fromZnHeaders: self fixtureFullHeaders.
  ston := STON toString: original.
  restored := STON fromString: ston.
  self assert: restored requestId equals: 'req_full'.
  self assert: restored rateLimitRequestsRemaining equals: 98.
  self assert: restored rateLimitInputTokensReset equals: '2026-04-22T17:30:01Z'.
  self assert: restored retryAfter equals: 5.
  self assert: restored hasRateLimits
]
