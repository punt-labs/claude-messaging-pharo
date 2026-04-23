"
Tests for ClaudeClient -- creation, defaults, configuration, HTTP helper setup, and printOn:.
"
Class {
	#name : 'ClaudeClientTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'tests' }
ClaudeClientTest >> testClientApiVersion [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client apiVersion equals: '2023-06-01'
]

{ #category : 'tests' }
ClaudeClientTest >> testClientCreationWithApiKey [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client apiKey equals: 'sk-test'.
	self assert: client baseUrl equals: 'https://api.anthropic.com'.
	self assert: client timeout equals: 120
]

{ #category : 'tests' }
ClaudeClientTest >> testClientCreationWithOptions [

	| client |
	client := ClaudeClient apiKey: 'sk-test' baseUrl: 'https://custom.api.com' timeout: 60.
	self assert: client apiKey equals: 'sk-test'.
	self assert: client baseUrl equals: 'https://custom.api.com'.
	self assert: client timeout equals: 60
]

{ #category : 'tests' }
ClaudeClientTest >> testClientDefaultBaseUrl [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client baseUrl equals: 'https://api.anthropic.com'
]

{ #category : 'tests' }
ClaudeClientTest >> testClientDefaultMaxRetries [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client maxRetries equals: 5
]

{ #category : 'tests' }
ClaudeClientTest >> testClientDefaultStreamingTimeout [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client streamingTimeout equals: 300
]

{ #category : 'tests' }
ClaudeClientTest >> testClientDefaultTimeout [

	| client |
	client := ClaudeClient apiKey: 'sk-test'.
	self assert: client timeout equals: 120
]

{ #category : 'tests - debug logging' }
ClaudeClientTest >> testDebugLogBlockCalledOnSend [
	"Verify debugLog: block is invoked with request and response entries."
	| client logs |
	client := ClaudeClient apiKey: 'test-key'.
	logs := OrderedCollection new.
	client debugLog: [ :entry | logs add: entry ].
	
	"Verify the log block is called via notifyDebugLog:"
	client notifyDebugLog: { #direction -> #request . #url -> 'http://test' } asDictionary.
	client notifyDebugLog: { #direction -> #response . #status -> 200 } asDictionary.
	
	self assert: logs size equals: 2.
	self assert: (logs first at: #direction) equals: #request.
	self assert: (logs first at: #url) equals: 'http://test'.
	self assert: (logs second at: #direction) equals: #response.
	self assert: (logs second at: #status) equals: 200
]

{ #category : 'tests - debug logging' }
ClaudeClientTest >> testDebugLogNilByDefault [
	"Verify default nil debugLogBlock does not raise errors."
	| client |
	client := ClaudeClient apiKey: 'test-key'.
	"Should not raise - nil block is silently ignored"
	client notifyDebugLog: { #direction -> #request } asDictionary.
	self assert: true description: 'No error raised with nil debugLogBlock'
]

{ #category : 'tests' }
ClaudeClientTest >> testListModelsWithPagination [
	| client url response |
	client := ClaudeClient apiKey: 'test-key'.
	
	"Test with both pagination parameters"
	url := client buildModelListUrlWithLimit: 10 after: 'model-123'.
	self assert: (url includesSubstring: 'limit=10').
	self assert: (url includesSubstring: 'after_id=model-123').
	self assert: (url includesSubstring: '?').
	self assert: (url includesSubstring: '&').
	
	"Test with only limit"
	url := client buildModelListUrlWithLimit: 20 after: nil.
	self assert: (url includesSubstring: 'limit=20').
	self deny: (url includesSubstring: 'after_id').
	
	"Test with only after"
	url := client buildModelListUrlWithLimit: nil after: 'model-456'.
	self assert: (url includesSubstring: 'after_id=model-456').
	self deny: (url includesSubstring: 'limit').
	
	"Test with neither"
	url := client buildModelListUrlWithLimit: nil after: nil.
	self deny: (url includesSubstring: '?').
	
	"Test response parsing"
	response := client parseModelListResponse: (Dictionary new
		at: 'data' put: #();
		at: 'has_more' put: true;
		at: 'first_id' put: 'model-1';
		at: 'last_id' put: 'model-10';
		yourself).
	
	self assert: (response at: 'has_more').
	self assert: (response at: 'first_id') equals: 'model-1'.
	self assert: (response at: 'last_id') equals: 'model-10'.
	self assert: (response at: 'data') isEmpty
]

{ #category : 'tests' }
ClaudeClientTest >> testNewHttpClientForIncludesBetaHeader [
	| client params http |
	client := ClaudeClient apiKey: 'sk-test'.
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet45.
	params maxTokens: 100.
	params addUserMessage: 'test'.
	params betas: #('pdfs-2024-09-25' 'output-128k-2025-02-19').
	http := client newHttpClientFor: params.
	self assert: (http request headers at: 'anthropic-beta') equals: 'pdfs-2024-09-25,output-128k-2025-02-19'
]

{ #category : 'tests' }
ClaudeClientTest >> testNewHttpClientForOmitsBetaHeaderWhenNoBetas [
	| client params http |
	client := ClaudeClient apiKey: 'sk-test'.
	params := ClaudeMessageRequest new.
	params model: ClaudeModel sonnet45.
	params maxTokens: 100.
	params addUserMessage: 'test'.
	http := client newHttpClientFor: params.
	self deny: (http request headers includesKey: 'anthropic-beta')
]

{ #category : 'tests' }
ClaudeClientTest >> testNewHttpClientHeaders [

	| client http |
	client := ClaudeClient apiKey: 'sk-test'.
	http := client newHttpClient.
	self assert: (http request headers at: 'x-api-key') equals: 'sk-test'.
	self assert: (http request headers at: 'anthropic-version') equals: '2023-06-01'.
	self assert: (http request headers at: 'content-type') equals: 'application/json'.
	self assert: (http request headers at: 'accept') equals: 'application/json'
]

{ #category : 'tests' }
ClaudeClientTest >> testNewHttpClientTimeout [

	| client http |
	client := ClaudeClient apiKey: 'sk-test'.
	client timeout: 60.
	http := client newHttpClient.
	self assert: http timeout equals: 60
]

{ #category : 'tests' }
ClaudeClientTest >> testPrintOn [

	| client str |
	client := ClaudeClient apiKey: 'sk-test'.
	str := client printString.
	self assert: (str includesSubstring: 'https://api.anthropic.com').
	self assert: (str includesSubstring: 'ClaudeClient')
]

{ #category : 'tests - response metadata' }
ClaudeClientTest >> testRateLimitErrorCarriesResponseMetadata [
  "On 429, errorFor: attaches a ClaudeResponseMetadata to the
   ClaudeApiError so callers can inspect rate-limit telemetry and
   pick a smarter backoff than retry-after alone."
  | server client request raised body errorHeaders |
  server := ClaudeMockServer startOn: 0.
  [ body := '{"type":"error","error":{"type":"rate_limit_error","message":"too many requests"}}'.
    errorHeaders := Dictionary new
      at: 'request-id' put: 'req_429';
      at: 'anthropic-ratelimit-requests-limit' put: '100';
      at: 'anthropic-ratelimit-requests-remaining' put: '0';
      at: 'anthropic-ratelimit-requests-reset' put: '2026-04-22T18:05:00Z';
      at: 'Retry-After' put: '2';
      yourself.
    server respondTo: '/v1/messages' withSequence: (OrderedCollection with:
      (server errorResponse: 429 message: 'too many requests' headers: errorHeaders)).
    client := ClaudeClient
      apiKey: 'test-key'
      baseUrl: 'http://localhost:' , server port printString
      timeout: 5.
    client maxRetries: 0.
    request := ClaudeMessageRequest new
      model: 'claude-opus-4-6';
      maxTokens: 100;
      addUserMessage: 'hi';
      yourself.
    raised := nil.
    [ client sendMessage: request ]
      on: ClaudeRateLimitError
      do: [ :e | raised := e ].
    self assert: raised notNil.
    self assert: raised class equals: ClaudeRateLimitError.
    self assert: raised responseMetadata class equals: ClaudeResponseMetadata.
    self assert: raised requestId equals: 'req_429'.
    self assert: raised responseMetadata rateLimitRequestsRemaining equals: 0.
    self assert: raised responseMetadata rateLimitRequestsReset equals: '2026-04-22T18:05:00Z'.
    self assert: raised responseMetadata retryAfter equals: 2.
    self assert: raised retryAfter equals: 2
  ] ensure: [ server stop ]
]

{ #category : 'tests - response metadata' }
ClaudeClientTest >> testSendMessageMetadataNilSlotsWhenHeadersAbsent [
  "With no rate-limit headers on the response, hasRateLimits is false
   but responseMetadata is still attached and requestId still resolves."
  | server client request response body |
  server := ClaudeMockServer startOn: 0.
  [ body := '{"id":"msg_y","type":"message","role":"assistant","content":[{"type":"text","text":"ok"}],"model":"claude-opus-4-6","stop_reason":"end_turn","usage":{"input_tokens":2,"output_tokens":1}}'.
    server respondTo: '/v1/messages' with: body headers: (Dictionary new at: 'request-id' put: 'req_only'; yourself).
    client := ClaudeClient
      apiKey: 'test-key'
      baseUrl: 'http://localhost:' , server port printString
      timeout: 5.
    request := ClaudeMessageRequest new
      model: 'claude-opus-4-6';
      maxTokens: 100;
      addUserMessage: 'hi';
      yourself.
    response := client sendMessage: request.
    self assert: response responseMetadata class equals: ClaudeResponseMetadata.
    self assert: response requestId equals: 'req_only'.
    self deny: response responseMetadata hasRateLimits.
    self assert: response responseMetadata rateLimitRequestsLimit isNil.
    self assert: response responseMetadata retryAfter isNil
  ] ensure: [ server stop ]
]

{ #category : 'tests - response metadata' }
ClaudeClientTest >> testSendMessageWiresResponseMetadata [
  "sendMessage: parses anthropic-ratelimit-* headers and request-id
   into a ClaudeResponseMetadata attached to the returned message
   (mission yvyt+pch2). Existing requestId surface still resolves."
  | server client request response body headers |
  server := ClaudeMockServer startOn: 0.
  [ body := '{"id":"msg_x","type":"message","role":"assistant","content":[{"type":"text","text":"hi"}],"model":"claude-opus-4-6","stop_reason":"end_turn","usage":{"input_tokens":3,"output_tokens":1,"service_tier":"standard"}}'.
    headers := Dictionary new
      at: 'request-id' put: 'req_test_meta';
      at: 'anthropic-ratelimit-requests-limit' put: '100';
      at: 'anthropic-ratelimit-requests-remaining' put: '97';
      at: 'anthropic-ratelimit-requests-reset' put: '2026-04-22T18:00:00Z';
      at: 'anthropic-ratelimit-input-tokens-remaining' put: '49000';
      yourself.
    server respondTo: '/v1/messages' with: body headers: headers.
    client := ClaudeClient
      apiKey: 'test-key'
      baseUrl: 'http://localhost:' , server port printString
      timeout: 5.
    request := ClaudeMessageRequest new
      model: 'claude-opus-4-6';
      maxTokens: 100;
      addUserMessage: 'hi';
      yourself.
    response := client sendMessage: request.
    self assert: response responseMetadata class equals: ClaudeResponseMetadata.
    self assert: response requestId equals: 'req_test_meta'.
    self assert: response responseMetadata rateLimitRequestsLimit equals: 100.
    self assert: response responseMetadata rateLimitRequestsRemaining equals: 97.
    self assert: response responseMetadata rateLimitRequestsReset equals: '2026-04-22T18:00:00Z'.
    self assert: response responseMetadata rateLimitInputTokensRemaining equals: 49000.
    self assert: response responseMetadata hasRateLimits.
    self assert: response rateLimits identicalTo: response responseMetadata.
    self assert: response usage serviceTier equals: 'standard'
  ] ensure: [ server stop ]
]
