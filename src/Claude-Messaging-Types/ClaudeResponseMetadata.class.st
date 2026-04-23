"
Typed value object for Anthropic API response headers. Carries the request-id echo, the nine anthropic-ratelimit-* monitoring counters that every Messages API response includes, and the optional retry-after seconds-hint that 429 responses set. Every slot is nil-tolerant: headers may be absent on a given response, and the value object is constructed from whatever the wire actually delivered. Reset timestamps stay as the raw ISO-8601 String the server sends; callers parse on demand. Built by ClaudeResponseMetadata class>>fromZnHeaders: from a ZnResponse headers Dictionary.

  ClaudeResponseMetadata new hasRateLimits
  >>> false

  | meta |
  meta := ClaudeResponseMetadata new requestId: 'req_abc123'.
  meta requestId
  >>> 'req_abc123'

  | meta headers |
  headers := ZnHeaders new.
  headers at: 'request-id' put: 'req_abc'.
  headers at: 'anthropic-ratelimit-requests-remaining' put: '42'.
  meta := ClaudeResponseMetadata fromZnHeaders: headers.
  meta rateLimitRequestsRemaining
  >>> 42

"
Class {
	#name : 'ClaudeResponseMetadata',
	#superclass : 'Object',
	#instVars : [
		'requestId',
		'rateLimitRequestsLimit',
		'rateLimitRequestsRemaining',
		'rateLimitRequestsReset',
		'rateLimitInputTokensLimit',
		'rateLimitInputTokensRemaining',
		'rateLimitInputTokensReset',
		'rateLimitOutputTokensLimit',
		'rateLimitOutputTokensRemaining',
		'rateLimitOutputTokensReset',
		'retryAfter'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'persistence' }
ClaudeResponseMetadata class >> fromSton: stonReader [
  "Restore a ClaudeResponseMetadata from STON. Every slot is nil-tolerant."
  | dict meta |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  meta := self new.
  meta requestId: (dict at: #requestId ifAbsent: [ nil ]).
  meta rateLimitRequestsLimit: (dict at: #rateLimitRequestsLimit ifAbsent: [ nil ]).
  meta rateLimitRequestsRemaining: (dict at: #rateLimitRequestsRemaining ifAbsent: [ nil ]).
  meta rateLimitRequestsReset: (dict at: #rateLimitRequestsReset ifAbsent: [ nil ]).
  meta rateLimitInputTokensLimit: (dict at: #rateLimitInputTokensLimit ifAbsent: [ nil ]).
  meta rateLimitInputTokensRemaining: (dict at: #rateLimitInputTokensRemaining ifAbsent: [ nil ]).
  meta rateLimitInputTokensReset: (dict at: #rateLimitInputTokensReset ifAbsent: [ nil ]).
  meta rateLimitOutputTokensLimit: (dict at: #rateLimitOutputTokensLimit ifAbsent: [ nil ]).
  meta rateLimitOutputTokensRemaining: (dict at: #rateLimitOutputTokensRemaining ifAbsent: [ nil ]).
  meta rateLimitOutputTokensReset: (dict at: #rateLimitOutputTokensReset ifAbsent: [ nil ]).
  meta retryAfter: (dict at: #retryAfter ifAbsent: [ nil ]).
  ^ meta
]

{ #category : 'instance creation' }
ClaudeResponseMetadata class >> fromZnHeaders: aZnHeaders [
  "Parse a ZnHeaders (or any Dictionary-shaped header collection that
   responds to at:ifAbsent:) into a ClaudeResponseMetadata. Every slot
   is nil when the corresponding header is absent OR when its value is
   non-numeric (the *-limit, *-remaining, and retry-after counters all
   parse via integerFromHeaderValue: which catches parse errors and
   returns nil). Reset timestamps stay as the raw String the server sent.
   Retry-After parses to an Integer (seconds) per RFC 7231 §7.1.3.

   Header lookups: the nine anthropic-ratelimit-* headers are documented
   by Anthropic as lowercase wire names, and ZnHeaders does
   case-insensitive lookup, so a single lowercase probe resolves them
   regardless of how the server cased them. Retry-After is the only
   header that gets a title-case fallback: RFC 7231 §7.1.3 canonicalizes
   it as Title-Case while older code paths (and ClaudeStreamingSocket>>
   readHeaders, which lowercases on insertion) may store either casing.
   The dual probe keeps a plain Dictionary that was built mixed-case
   from breaking the parser."
  | meta integers |
  meta := self new.
  meta requestId: (aZnHeaders at: 'request-id' ifAbsent: [ nil ]).
  integers := self integerRateLimitSlots.
  self rateLimitHeaderNames do: [ :pair |
    | slot wire raw value |
    slot := pair first.
    wire := pair second.
    raw := aZnHeaders at: wire ifAbsent: [ nil ].
    raw ifNotNil: [
      value := (integers includes: slot)
        ifTrue: [ self integerFromHeaderValue: raw ]
        ifFalse: [ raw ].
      meta perform: (slot, ':') asSymbol with: value ] ].
  (aZnHeaders
    at: 'retry-after'
    ifAbsent: [ aZnHeaders at: 'Retry-After' ifAbsent: [ nil ] ])
      ifNotNil: [ :raw | meta retryAfter: (self integerFromHeaderValue: raw) ].
  ^ meta
]

{ #category : 'wire headers' }
ClaudeResponseMetadata class >> integerFromHeaderValue: aString [
  "Parse aString as an Integer, answering nil if the input is missing or
   malformed. Used to harden header-value parsing against non-numeric content
   from the wire (Anthropic-Ratelimit-* counters and Retry-After). The
   ``asInteger`` selector's nil-on-non-numeric behaviour is not a documented
   guarantee across all Pharo paths and receiver types — implementations on
   String, Symbol, and ByteArray differ, and a future kernel change could
   shift any of them to signal. The Error handler insulates response/error
   parsing from that uncertainty AND from the case where a header value is
   not a String at all (e.g. a malformed ZnHeaders value); either way, an
   unparseable input becomes nil instead of propagating into an exception
   path the response builder is not prepared to handle."
  aString ifNil: [ ^ nil ].
  ^ [ aString asInteger ] on: Error do: [ nil ]
]

{ #category : 'wire headers' }
ClaudeResponseMetadata class >> integerRateLimitSlots [
  "Slots whose wire value is an integer (the *-limit and *-remaining
   counters). Reset slots stay as the raw ISO-8601 timestamp String
   so callers can parse on demand without losing precision."
  ^ #(
    #rateLimitRequestsLimit
    #rateLimitRequestsRemaining
    #rateLimitInputTokensLimit
    #rateLimitInputTokensRemaining
    #rateLimitOutputTokensLimit
    #rateLimitOutputTokensRemaining)
]

{ #category : 'wire headers' }
ClaudeResponseMetadata class >> rateLimitHeaderNames [
  "Answer an Array of {slot. wireHeaderName} pairs for the nine
   anthropic-ratelimit-* headers. The wire names match the Go SDK's
   recorded cassettes (e.g. .tmp/anthropic-sdk-go/toolrunner/testdata/
   cassettes/tool_runner_custom_handling.yaml). HTTP/1.1 header lookup
   is case-insensitive (RFC 7230 §3.2) and ZnHeaders honors that, so
   the lowercase form here resolves the cassette's mixed-case
   spellings (Anthropic-Ratelimit-Requests-Limit, etc.) without
   duplicating each name."
  ^ #(
    (#rateLimitRequestsLimit 'anthropic-ratelimit-requests-limit')
    (#rateLimitRequestsRemaining 'anthropic-ratelimit-requests-remaining')
    (#rateLimitRequestsReset 'anthropic-ratelimit-requests-reset')
    (#rateLimitInputTokensLimit 'anthropic-ratelimit-input-tokens-limit')
    (#rateLimitInputTokensRemaining 'anthropic-ratelimit-input-tokens-remaining')
    (#rateLimitInputTokensReset 'anthropic-ratelimit-input-tokens-reset')
    (#rateLimitOutputTokensLimit 'anthropic-ratelimit-output-tokens-limit')
    (#rateLimitOutputTokensRemaining 'anthropic-ratelimit-output-tokens-remaining')
    (#rateLimitOutputTokensReset 'anthropic-ratelimit-output-tokens-reset'))
]

{ #category : 'testing' }
ClaudeResponseMetadata >> hasRateLimits [
  "Answer true when any of the nine anthropic-ratelimit-* slots is
   populated. The request-id and retry-after slots do not count;
   request-id ships on every response and retry-after only on 429s."
  ^ rateLimitRequestsLimit notNil
    or: [ rateLimitRequestsRemaining notNil
    or: [ rateLimitRequestsReset notNil
    or: [ rateLimitInputTokensLimit notNil
    or: [ rateLimitInputTokensRemaining notNil
    or: [ rateLimitInputTokensReset notNil
    or: [ rateLimitOutputTokensLimit notNil
    or: [ rateLimitOutputTokensRemaining notNil
    or: [ rateLimitOutputTokensReset notNil ] ] ] ] ] ] ] ]
]

{ #category : 'printing' }
ClaudeResponseMetadata >> printOn: aStream [
  "Compact one-line render summarising the metadata. Always names the
   request-id (or ? when nil). Each rate-limit axis (req, input, output)
   prints only when BOTH its Limit and Remaining slots are non-nil, so
   a partially populated test fixture renders only the complete axes
   instead of literal nil/nil fractions. Retry-after prints only when set."
  aStream nextPutAll: 'ClaudeResponseMetadata(req-id='.
  aStream nextPutAll: (requestId ifNil: [ '?' ]).
  (rateLimitRequestsLimit notNil and: [ rateLimitRequestsRemaining notNil ]) ifTrue: [
    aStream nextPutAll: ' req '.
    aStream print: rateLimitRequestsRemaining.
    aStream nextPut: $/.
    aStream print: rateLimitRequestsLimit ].
  (rateLimitInputTokensLimit notNil and: [ rateLimitInputTokensRemaining notNil ]) ifTrue: [
    aStream nextPutAll: ' input '.
    aStream print: rateLimitInputTokensRemaining.
    aStream nextPut: $/.
    aStream print: rateLimitInputTokensLimit ].
  (rateLimitOutputTokensLimit notNil and: [ rateLimitOutputTokensRemaining notNil ]) ifTrue: [
    aStream nextPutAll: ' output '.
    aStream print: rateLimitOutputTokensRemaining.
    aStream nextPut: $/.
    aStream print: rateLimitOutputTokensLimit ].
  retryAfter ifNotNil: [
    aStream nextPutAll: ' retry-after='.
    aStream print: retryAfter ].
  aStream nextPut: $)
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensLimit [
	^ rateLimitInputTokensLimit
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensLimit: aValue [
	rateLimitInputTokensLimit := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensRemaining [
	^ rateLimitInputTokensRemaining
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensRemaining: aValue [
	rateLimitInputTokensRemaining := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensReset [
	^ rateLimitInputTokensReset
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitInputTokensReset: aValue [
	rateLimitInputTokensReset := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensLimit [
	^ rateLimitOutputTokensLimit
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensLimit: aValue [
	rateLimitOutputTokensLimit := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensRemaining [
	^ rateLimitOutputTokensRemaining
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensRemaining: aValue [
	rateLimitOutputTokensRemaining := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensReset [
	^ rateLimitOutputTokensReset
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitOutputTokensReset: aValue [
	rateLimitOutputTokensReset := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsLimit [
	^ rateLimitRequestsLimit
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsLimit: aValue [
	rateLimitRequestsLimit := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsRemaining [
	^ rateLimitRequestsRemaining
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsRemaining: aValue [
	rateLimitRequestsRemaining := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsReset [
	^ rateLimitRequestsReset
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> rateLimitRequestsReset: aValue [
	rateLimitRequestsReset := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> requestId [
	^ requestId
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> requestId: aValue [
	requestId := aValue
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> retryAfter [
	^ retryAfter
]

{ #category : 'accessing' }
ClaudeResponseMetadata >> retryAfter: aValue [
	retryAfter := aValue
]

{ #category : 'persistence' }
ClaudeResponseMetadata >> stonOn: aStonWriter [
  "Persist non-nil slots so absent headers stay absent after round-trip."
  aStonWriter writeObject: self streamMap: [ :map |
    requestId ifNotNil: [ map at: #requestId put: requestId ].
    rateLimitRequestsLimit ifNotNil: [ map at: #rateLimitRequestsLimit put: rateLimitRequestsLimit ].
    rateLimitRequestsRemaining ifNotNil: [ map at: #rateLimitRequestsRemaining put: rateLimitRequestsRemaining ].
    rateLimitRequestsReset ifNotNil: [ map at: #rateLimitRequestsReset put: rateLimitRequestsReset ].
    rateLimitInputTokensLimit ifNotNil: [ map at: #rateLimitInputTokensLimit put: rateLimitInputTokensLimit ].
    rateLimitInputTokensRemaining ifNotNil: [ map at: #rateLimitInputTokensRemaining put: rateLimitInputTokensRemaining ].
    rateLimitInputTokensReset ifNotNil: [ map at: #rateLimitInputTokensReset put: rateLimitInputTokensReset ].
    rateLimitOutputTokensLimit ifNotNil: [ map at: #rateLimitOutputTokensLimit put: rateLimitOutputTokensLimit ].
    rateLimitOutputTokensRemaining ifNotNil: [ map at: #rateLimitOutputTokensRemaining put: rateLimitOutputTokensRemaining ].
    rateLimitOutputTokensReset ifNotNil: [ map at: #rateLimitOutputTokensReset put: rateLimitOutputTokensReset ].
    retryAfter ifNotNil: [ map at: #retryAfter put: retryAfter ] ]
]
