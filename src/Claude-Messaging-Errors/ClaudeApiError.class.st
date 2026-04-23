"
Base class for Claude Messages API errors. Signaled (not returned) when the API responds with a non-2xx status code — idiomatic Smalltalk: let exceptions propagate and catch the class you care about with `on:do:`.

### Why a hierarchy instead of a status field

Anthropic's Messages API returns distinct error conditions behind
distinct HTTP status codes: 401 is an auth problem, 429 is a rate
limit, 529 is overload. A single `ClaudeApiError` with a `statusCode`
slot would force every caller to write `if/else` on the number.
Instead, the factory `ClaudeApiError class >> fromStatusCode:json:requestId:`
dispatches to the right subclass — `ClaudeAuthError` for 401,
`ClaudeRateLimitError` for 429, and so on — so the caller can
`on: ClaudeAuthError do: [...]` and let the rest propagate.

Every error carries: `statusCode` (Integer), `message` (String),
`requestId` (String from the `request-id` header), `rawJson`
(String — the full error body for logging), `retryAfter` (Number
of seconds or nil, parsed from the `retry-after` or `retry-after-ms`
header on 429). The
base class defines `isRetryable` — 408, 429, and 5xx answer true;
4xx client errors and the synthetic 599 `ClaudeNetworkError`
answer false.

### Handling errors

The preferred pattern catches the base class at the outer scope and
dispatches on the specific subclass inside the handler. This lets
callers write one `on:do:` and still react differently to rate
limits vs auth failures:

```
| caught |
caught := [ (ClaudeApiError
    fromStatusCode: 401
    json: '{""error"":{""message"":""bad key""}}'
    requestId: 'req_1') signal ]
    on: ClaudeAuthError
    do: [ :e | e class name ].
caught
>>> #ClaudeAuthError
```

The factory is what `ClaudeClient` calls internally when a request
comes back with a non-2xx status. In application code you almost
never construct these directly — you catch them:

```
(ClaudeApiError fromStatusCode: 401 json: '{""error"":{""message"":""bad key""}}' requestId: 'req_1') class
>>> ClaudeAuthError
```

### Unknown status codes

`fromStatusCode:json:requestId:` falls back to `ClaudeServerError`
for any unmapped 5xx and to `ClaudeApiError` itself for unmapped
4xx. Callers that want to handle 'any API error' should always
catch `ClaudeApiError` as the base class, never a specific
subclass.

### Streaming errors

Errors can also arrive mid-stream as SSE `error` events. The class
method `fromSseErrorData:` parses the payload, populates
`statusCode` from the Anthropic error-type string (so `isRetryable`
and `printOn:` behave the same as sync-path errors), and returns
the matching subclass. The streaming code signals it against the
current process so `on:do:` works end-to-end whether the error
comes back on the status line or in a mid-stream event.

### Retry integration

`ClaudeClient` retries retryable errors internally — the default
budget is 5 retries with 0.5 s..8 s exponential backoff plus
±25% jitter. Callers only see the exception after all retries are
exhausted. Tests that exercise the retry path must set
`maxRetries: 0` or they will wait out the full backoff.


"
Class {
	#name : 'ClaudeApiError',
	#superclass : 'Error',
	#instVars : [
		'statusCode',
		'message',
		'requestId',
		'rawJson',
		'retryAfter',
		'responseMetadata'
	],
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}

{ #category : 'registries' }
ClaudeApiError class >> errorTypeRegistry [
	"Map Anthropic SSE error.type strings to the matching ClaudeApiError
	subclass. Used by fromSseErrorData: to raise the right exception when
	an error event arrives mid-stream."
	^ {
		'authentication_error' -> ClaudeAuthError.
		'billing_error' -> ClaudeBillingError.
		'permission_error' -> ClaudePermissionError.
		'not_found_error' -> ClaudeNotFoundError.
		'rate_limit_error' -> ClaudeRateLimitError.
		'timeout_error' -> ClaudeTimeoutError.
		'api_error' -> ClaudeServerError.
		'overloaded_error' -> ClaudeOverloadedError.
		'invalid_request_error' -> ClaudeInvalidRequestError
	} asDictionary
]

{ #category : 'instance creation' }
ClaudeApiError class >> fromSseErrorData: aDictionary [
	"Build a ClaudeApiError subclass from the data payload of an
	``error`` SSE event. The payload shape is
	{ 'type': 'error', 'error': { 'type': 'overloaded_error', 'message': '...' } }.
	Unknown error.type strings fall back to this class (ClaudeApiError)
	so the caller still gets an exception rather than a crash. Populates
	statusCode via sseErrorTypeStatusRegistry so isRetryable and printOn:
	work symmetrically with sync-path errors. See bead 8x5 round 2."

	| errorDict errorType subclass errorMessage statusForType |
	errorDict := aDictionary at: 'error' ifAbsent: [ Dictionary new ].
	errorType := errorDict at: 'type' ifAbsent: [ nil ].
	errorMessage := errorDict at: 'message' ifAbsent: [ 'Unknown streaming error' ].
	subclass := self errorTypeRegistry at: errorType ifAbsent: [ self ].
	statusForType := self sseErrorTypeStatusRegistry at: errorType ifAbsent: [ nil ].
	^ subclass new
		statusCode: statusForType;
		message: errorMessage;
		rawJson: (STONJSON toString: aDictionary);
		yourself
]

{ #category : 'instance creation' }
ClaudeApiError class >> fromStatusCode: anInteger json: jsonString requestId: aString [
	| data errorMessage subclass |
	data := [ STONJSON fromString: jsonString ] on: Error do: [ :e | Dictionary new ].
	errorMessage := (data at: 'error' ifAbsent: [ Dictionary new ]) at: 'message' ifAbsent: [ 'Unknown error' ].
	subclass := self subclassForStatus: anInteger.
	^ subclass new
		statusCode: anInteger;
		message: errorMessage;
		requestId: aString;
		rawJson: jsonString;
		yourself
]

{ #category : 'registries' }
ClaudeApiError class >> sseErrorTypeStatusRegistry [
	"Reverse mapping from Anthropic SSE error.type strings to their canonical
	HTTP status codes. Used by fromSseErrorData: to populate statusCode on
	SSE-origin errors so isRetryable and printOn: work correctly. Mirrors
	the shape of errorTypeRegistry and statusRegistry. See bead 8x5 round 2."
	^ {
		'authentication_error' -> 401.
		'billing_error' -> 402.
		'permission_error' -> 403.
		'not_found_error' -> 404.
		'timeout_error' -> 408.
		'rate_limit_error' -> 429.
		'api_error' -> 500.
		'overloaded_error' -> 529.
		'invalid_request_error' -> 400
	} asDictionary
]

{ #category : 'registries' }
ClaudeApiError class >> statusRegistry [
	^ {
		400 -> ClaudeInvalidRequestError.
		401 -> ClaudeAuthError.
		402 -> ClaudeBillingError.
		403 -> ClaudePermissionError.
		404 -> ClaudeNotFoundError.
		408 -> ClaudeTimeoutError.
		429 -> ClaudeRateLimitError.
		500 -> ClaudeServerError.
		504 -> ClaudeTimeoutError.
		529 -> ClaudeOverloadedError
	} asDictionary
]

{ #category : 'instance creation' }
ClaudeApiError class >> subclassForStatus: anInteger [
	^ self statusRegistry at: anInteger ifAbsent: [
		anInteger >= 500 ifTrue: [ ClaudeServerError ] ifFalse: [ self ] ]
]

{ #category : 'testing' }
ClaudeApiError >> isRetryable [
	"Return true if this error is one where the caller should retry the
	request (408 timeout, 429 rate limit, 5xx server errors). Defensive
	against nil statusCode so unknown SSE error types fall through to
	false instead of crashing with DNU on nil >=. See bead 8x5 round 3."

	statusCode ifNil: [ ^ false ].
	statusCode = 408 ifTrue: [ ^ true ].
	statusCode = 429 ifTrue: [ ^ true ].
	statusCode >= 500 ifTrue: [ ^ true ].
	^ false
]

{ #category : 'accessing' }
ClaudeApiError >> message [
	^ message
]

{ #category : 'accessing' }
ClaudeApiError >> message: aString [
	message := aString
]

{ #category : 'accessing' }
ClaudeApiError >> messageText [
	^ message ifNil: [ super messageText ]
]

{ #category : 'printing' }
ClaudeApiError >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		print: (statusCode ifNil: [ 0 ]);
		nextPutAll: ' ';
		nextPutAll: (message ifNil: [ '' ]).
	requestId ifNotNil: [ 
		aStream
			nextPutAll: ' [';
			nextPutAll: requestId;
			nextPut: $] ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
ClaudeApiError >> rawJson [
	^ rawJson
]

{ #category : 'accessing' }
ClaudeApiError >> rawJson: aString [
	rawJson := aString
]

{ #category : 'accessing' }
ClaudeApiError >> requestId [
  "Read-through accessor: prefer the responseMetadata-attached value
   when ClaudeClient has wired one (post-Phase 2), fall back to the
   instance slot for callers that still build errors via the
   fromStatusCode:json:requestId: factory directly."
  ^ responseMetadata
    ifNotNil: [ :m | m requestId ifNil: [ requestId ] ]
    ifNil: [ requestId ]
]

{ #category : 'accessing' }
ClaudeApiError >> requestId: aString [
	requestId := aString
]

{ #category : 'accessing' }
ClaudeApiError >> responseMetadata [
  ^ responseMetadata
]

{ #category : 'accessing' }
ClaudeApiError >> responseMetadata: aClaudeResponseMetadata [
  "Attach the parsed response-header metadata to this error. Wired by
   ClaudeClient>>errorFor: and ClaudeClient>>handleStreamingError:headers:socket:
   after construction so the existing fromStatusCode:json:requestId: factory
   stays signature-stable for callers that build errors directly."
  responseMetadata := aClaudeResponseMetadata
]

{ #category : 'accessing' }
ClaudeApiError >> retryAfter [
	^ retryAfter
]

{ #category : 'accessing' }
ClaudeApiError >> retryAfter: anIntegerOrNil [
	retryAfter := anIntegerOrNil
]

{ #category : 'accessing' }
ClaudeApiError >> statusCode [
	^ statusCode
]

{ #category : 'accessing' }
ClaudeApiError >> statusCode: anInteger [
	statusCode := anInteger
]
