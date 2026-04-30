"
Production API client for the Anthropic Claude Messages API.

ClaudeClient is the entry point to the SDK. It holds authentication and
connection configuration, then creates a fresh ZnClient per request with
standard headers (`x-api-key`, `anthropic-version`). Retries are automatic
for retryable errors (429, 5xx) with exponential backoff (0.5s base, 8s
cap, 5 retries, +/-25% jitter).

One client, many requests. Construct once and reuse. There is no
connection pool -- every request opens a new ZnClient -- so ClaudeClient
itself is cheap to create but you pay the TLS handshake per call.

### Construction

An explicit API key is the simplest path:

```
ClaudeClient apiKey: 'sk-ant-api03-...'
>>> ClaudeClient(https://api.anthropic.com)
```

For examples and scripts, use `ClaudeExampleSupport resolveClient` instead.
It checks the OS keyring first, then the `ANTHROPIC_API_KEY` environment
variable, then prompts. Never hard-code a key in committed code.

```
| client |
client := ClaudeExampleSupport resolveClient.
```

Customize base URL or timeout when talking to a proxy or mock:

```
ClaudeClient
	apiKey: 'sk-ant-...'
	baseUrl: 'http://localhost:9999'
	timeout: 30
```

Defaults: baseUrl `https://api.anthropic.com`, apiVersion `2023-06-01`,
timeout 120s, streamingTimeout 300s, maxRetries 5.

### Sending a message

Build a `ClaudeMessageRequest`, hand it to `sendMessage:`, read the text
off the returned `ClaudeMessage`:

```
| client request response |
client := ClaudeExampleSupport resolveClient.
request := ClaudeMessageRequest new
	model: ClaudeModel opus46;
	maxTokens: 1024;
	addUserMessage: 'Write a haiku about Smalltalk.';
	yourself.
response := client sendMessage: request.
Transcript show: response textContent; cr.
```

`response` is a `ClaudeMessage` with `content` (a collection of content
blocks), `usage` (token counts), `stopReason`, and `id`. `textContent`
joins all text blocks into a single String.

### Streaming

`streamMessage:do:` calls your block once per Server-Sent Event. Each
event is a `Dictionary` with keys `'event'` (the SSE type as a String)
and `'data'` (the parsed JSON payload as a Dictionary). The method
returns the fully accumulated `ClaudeMessage` after the stream closes.

```
| client request final |
client := ClaudeExampleSupport resolveClient.
request := ClaudeMessageRequest new
	model: ClaudeModel opus46;
	maxTokens: 1024;
	addUserMessage: 'Count to five.';
	yourself.
final := client streamMessage: request do: [ :event |
	(event at: 'event') = 'content_block_delta' ifTrue: [
		| delta |
		delta := (event at: 'data') at: 'delta'.
		Transcript show: (delta at: 'text' ifAbsent: [ '' ]) ] ].
Transcript cr; show: 'stop reason: ', final stopReason.
```

For lower-level access, `openStreamingSocket:` returns a raw TLS socket
you can read with `ClaudeSSEDecoder onStream:`. Use this when you need
to interleave reads with other work.

### Counting tokens

Count *before* sending to budget costs or guard limits. The API accepts
the same request shape as `sendMessage:` but returns only
`ClaudeMessageTokensCount`.

```
| client request count |
client := ClaudeExampleSupport resolveClient.
request := ClaudeMessageRequest new
	model: ClaudeModel opus46;
	maxTokens: 1024;
	addUserMessage: 'Explain monads.';
	yourself.
count := client countTokens: request.
Transcript show: 'input tokens: ', count inputTokens printString.
```

### Listing models

`listModels` returns an `OrderedCollection` of `ClaudeModelInfo`. Use it
to discover what is currently available to your account.

```
| client models opus |
client := ClaudeExampleSupport resolveClient.
models := client listModels.
opus := models detect: [ :m | m id includesSubstring: 'opus-4-6' ].
Transcript show: opus displayName.
```

### Getting a single model

```
| client info |
client := ClaudeExampleSupport resolveClient.
info := client getModel: 'claude-opus-4-6'.
Transcript show: info displayName.
```

### Messages with images

Attach a `ClaudeImageBlock` to a user turn. Build the block from a file,
a raw base64 string, or a live `Form`:

```
| client request response |
client := ClaudeExampleSupport resolveClient.
request := ClaudeMessageRequest new
	model: ClaudeModel opus46;
	maxTokens: 1024;
	yourself.
request
	addUserMessage: 'What is on this screen?'
	withImage: (ClaudeImageBlock fromForm: World imageForm).
response := client sendMessage: request.
Transcript show: response textContent.
```

### Uploading skills

A skill is a directory tree containing a `SKILL.md` at its root. The
SDK uploads it as a multipart body via `uploadDirectory:displayTitle:`
(new skill) or `uploadVersionFor:fromDirectory:` (new version of an
existing skill).

Three client-side preconditions are checked before any bytes hit the
wire. Each raises a plain `Error` with a pinned message that names
the offending value, in this order:

1. **SKILL.md must exist at the directory root.** Absence raises
   `'SKILL.md not found at directory root: <path>'`.
2. **The directory basename must equal the `name:` field in
   SKILL.md's YAML frontmatter.** A `my-skill/` directory whose
   SKILL.md says `name: other` raises
   `'Skill directory basename """"""""my-skill"""""""" does not match name: """"""""other"""""""" in SKILL.md frontmatter'`.
   If SKILL.md has no frontmatter or no `name:` line, the guard
   skips and lets the server decide.
3. **Per-file and total size limits.** Per-file 25 MB
   (`ClaudeClient maxSkillFileBytes`), total 100 MB
   (`ClaudeClient maxSkillUploadBytes`). Either limit raises with
   the offending file basename (per-file) or the actual total in
   MB (total).

On the wire, every file is sent as a multipart part with
`fieldName: 'files[]'` (the literal bracketed field name the
Skills API expects) and a POSIX-separated filename prefixed with
the directory basename. A file at `my-skill/SKILL.md` sends as
`my-skill/SKILL.md`; a nested `my-skill/helpers/util.py` sends as
`my-skill/helpers/util.py`.

```
| client skill |
client := ClaudeExampleSupport resolveClient.
skill := client
	uploadDirectory: 'skills/my-skill' asFileReference
	displayTitle: 'My skill'.
Transcript show: skill id.
```

**Deleting skills.** `deleteSkill:` requires that every version of
the skill already be deleted via `deleteVersion:for:`. Calling
`deleteSkill:` on a skill that still has versions raises a server
error (`400 Cannot delete skill with existing versions. Delete all
versions first.`). A future release may add a cascade helper; for
now iterate with `listVersionsFor:` + `deleteVersion:for:` first.

### Files API

The Files API lets you upload a file once and then reference it by
ID in document blocks and image blocks on later requests, instead
of inlining base64 content on every call. All endpoints require
the Files API beta header (`ClaudeBetaHeader filesApi`);
`ClaudeClient` injects it automatically on every `/v1/files`
request via `newFileHttpClient`, so callers never spell the wire
identifier themselves.

The Pharo surface covers six Files API operations via seven
selectors on `ClaudeClient` (`uploadFile:` and `listFiles` each
have a one-arg and a parameterized form):

- `uploadFile:` and `uploadFile:filename:mimeType:` — POST
  `/v1/files`, multipart; returns `ClaudeFileMetadata`. The plain
  `uploadFile:` variant infers the MIME type from the file
  extension.
- `listFiles` and `listFiles:` — GET `/v1/files`; returns
  `ClaudeFilePage`. Pass a `ClaudeFileListParams` for cursor-based
  pagination (`limit`, `afterId`, `beforeId`).
- `getFileMetadata:` — GET `/v1/files/{id}`; returns
  `ClaudeFileMetadata`.
- `downloadFile:` — GET `/v1/files/{id}/content`; returns a
  `ByteArray`. Only Claude-generated files are downloadable — user
  uploads report `downloadable = false`.
- `deleteFile:` — DELETE `/v1/files/{id}`; returns
  `ClaudeDeletedFile`.

Uploads stream from disk in 64 KB chunks via
`ClaudeStreamingMultiPartEntity` so peak VM memory stays bounded
regardless of file size. Client-side, the Files API accepts any
file type and size the server accepts; unlike skills, there are
no hard SDK limits.

The example below uses `ClaudeMockServer` so it runs without an
API key or network. In real code you build `client` via
`ClaudeExampleSupport resolveClient` and point it at
`https://api.anthropic.com`:

```
| server client meta page |
server := ClaudeMockServer startOn: 0.
[ server
    respondTo: '/v1/files'
    with: '{""data"":[{""id"":""file-abc"",""type"":""file"",""filename"":""notes.txt"",""mime_type"":""text/plain"",""size_bytes"":6,""created_at"":""2026-04-21T00:00:00Z"",""downloadable"":false}],""has_more"":false,""first_id"":""file-abc"",""last_id"":""file-abc""}'.
  server
    respondTo: '/v1/files/file-abc'
    with: '{""id"":""file-abc"",""type"":""file"",""filename"":""notes.txt"",""mime_type"":""text/plain"",""size_bytes"":6,""created_at"":""2026-04-21T00:00:00Z"",""downloadable"":false}'.
  client := ClaudeClient
    apiKey: 'test-key'
    baseUrl: 'http://localhost:' , server port printString
    timeout: 5.
  page := client listFiles.
  meta := client getFileMetadata: 'file-abc'.
  ^ { page data size. page data first id. meta filename. meta sizeBytes } ]
    ensure: [ server stop ]
>>> #(1 'file-abc' 'notes.txt' 6)
```

### Error handling

Every HTTP failure raises a `ClaudeApiError` subclass. Catch the base
class to handle any API error; the handler receives the most specific
instance so you can dispatch on class when you need to.

```
| client request |
client := ClaudeExampleSupport resolveClient.
request := ClaudeMessageRequest new
	model: ClaudeModel opus46;
	maxTokens: 100;
	addUserMessage: 'Hello';
	yourself.
[ client sendMessage: request ]
	on: ClaudeApiError
	do: [ :e | Transcript show: e class name, ': ', e messageText; cr ].
```

To catch only one condition and let the rest propagate, name that
subclass directly:

```
[ client sendMessage: request ]
	on: ClaudeAuthError
	do: [ :e | Transcript show: 'check your API key' ].
```

Subclasses: `ClaudeAuthError` (401), `ClaudePermissionError` (403),
`ClaudeNotFoundError` (404), `ClaudeRateLimitError` (429),
`ClaudeBillingError` (402), `ClaudeServerError` (500),
`ClaudeOverloadedError` (529), `ClaudeTimeoutError` (network timeout).
Retryable errors (429, 5xx, timeouts) are retried automatically up to
`maxRetries` times before the exception reaches your handler.

### Limits

The SDK enforces a fixed set of numeric limits. Every value below is a
hard default set in `initialize` or a class-side constant; each can be
overridden where noted.

- **Timeouts** -- `timeout` defaults to **120 s** (non-streaming requests), `streamingTimeout` defaults to **300 s** (streaming requests). Both are per-request; override via `client timeout: seconds` / `client streamingTimeout: seconds` before the call.
- **Retries** -- `maxRetries` defaults to **5**. Retryable conditions: HTTP **408, 429, >=500 server responses except 599 network failures** (see `ClaudeApiError >> isRetryable` and `ClaudeNetworkError >> isRetryable`). Backoff is exponential with **0.5 s base, 8 s cap, +/-25% jitter**; any `retry-after-ms` or `retry-after` header is honored (clamped to 0-30 s). Override via `client maxRetries: n`.
- **Skill upload sizes** -- per-file **25 MB** (`ClaudeClient maxSkillFileBytes`), total **100 MB** summed across a skill directory (`ClaudeClient maxSkillUploadBytes`). Enforced client-side by `validateSkillUploadSize:` before any bytes are read. The server applies its own limits too.
- **Streaming chunk size** -- multipart uploads stream from disk in **64 KB** chunks via `ClaudeStreamingMultiPartEntity`. Peak VM memory is bounded by chunk size + entity framing, not total body size.
- **Error status codes** -- **400** `ClaudeInvalidRequestError`, **401** `ClaudeAuthError`, **402** `ClaudeBillingError`, **403** `ClaudePermissionError`, **404** `ClaudeNotFoundError`, **408** `ClaudeTimeoutError`, **429** `ClaudeRateLimitError`, **500** `ClaudeServerError`, **504** `ClaudeTimeoutError`, **529** `ClaudeOverloadedError`. Network/transport failures surface as `ClaudeNetworkError` using synthetic status **599** (not an HTTP response; not retried -- connection failures are not transient).

### Threading

Every method on ClaudeClient is synchronous and blocks the calling
process for the duration of the HTTP request. **Never call these
methods directly from the Morphic UI thread.** Fork a process and
defer UI updates:

```
[ | response |
	response := client sendMessage: request.
	WorldState defer: [ label contents: response textContent ]
] forkAt: Processor userBackgroundPriority named: 'Claude call'.
```

The Workbench already does this for you; if you are writing your own
Morphic UI, follow the same pattern.

### Also see

- `ClaudeMessageRequest` -- builder for message params
- `ClaudeMessage` -- the response envelope
- `ClaudeContentBlock` and subclasses -- text, images, tool use/result
- `ClaudeExchange` -- automates the tool-use loop
- `ClaudeApiError` -- error hierarchy
- `ClaudeExampleSupport` -- keyring/env key resolution for examples





"
Class {
	#name : 'ClaudeClient',
	#superclass : 'Object',
	#instVars : [
		'apiKey',
		'baseUrl',
		'apiVersion',
		'timeout',
		'streamingTimeout',
		'maxRetries',
		'rateLimiter',
		'debugLogBlock'
	],
	#category : 'Claude-Messaging-Client',
	#package : 'Claude-Messaging-Client'
}

{ #category : 'instance creation' }
ClaudeClient class >> apiKey: aString [

	^ self new apiKey: aString; yourself
]

{ #category : 'instance creation' }
ClaudeClient class >> apiKey: aString baseUrl: urlString timeout: seconds [

	^ self new
		apiKey: aString;
		baseUrl: urlString;
		timeout: seconds;
		yourself
]

{ #category : 'instance creation' }
ClaudeClient class >> fromEnvironment [

	| key |
	key := Smalltalk os environment at: 'ANTHROPIC_API_KEY' ifAbsent: [ nil ].
	key ifNil: [ Error signal: 'ANTHROPIC_API_KEY not set' ].
	^ self new apiKey: key; yourself
]

{ #category : 'limits' }
ClaudeClient class >> maxSkillFileBytes [
	"Per-file upload size limit in bytes (25 MB).
	Files larger than this are rejected client-side before the round-trip.

	  ClaudeClient maxSkillFileBytes
	  >>> 26214400
	"
	^ 25 * 1024 * 1024
]

{ #category : 'limits' }
ClaudeClient class >> maxSkillUploadBytes [
	"Total upload size limit in bytes (100 MB) summed across every file
	in a skill directory. Uploads exceeding this are rejected client-side
	before the round-trip.

	  ClaudeClient maxSkillUploadBytes
	  >>> 104857600
	"
	^ 100 * 1024 * 1024
]

{ #category : 'private' }
ClaudeClient >> apiHost [
	"Extract hostname from baseUrl. E.g., https://api.anthropic.com -> api.anthropic.com"
	| url |
	url := baseUrl.
	(url beginsWith: 'https://') ifTrue: [ url := url allButFirst: 8 ].
	(url beginsWith: 'http://') ifTrue: [ url := url allButFirst: 7 ].
	(url includes: $/) ifTrue: [ url := url copyUpTo: $/ ].
	^ url
]

{ #category : 'accessing' }
ClaudeClient >> apiKey [

	^ apiKey
]

{ #category : 'accessing' }
ClaudeClient >> apiKey: aString [

	apiKey := aString
]

{ #category : 'accessing' }
ClaudeClient >> apiVersion [

	^ apiVersion
]

{ #category : 'accessing' }
ClaudeClient >> apiVersion: aString [

	apiVersion := aString
]

{ #category : 'private' }
ClaudeClient >> appendQueryParams: aDictionary toUrl: aUrl [
	"Append a sorted, percent-encoded query string to aUrl. Uses '?' if aUrl
	 has no query string yet, otherwise '&'. Each value is percent-encoded so
	 page tokens containing reserved characters survive transport. Returns the
	 new URL string; empty/nil dictionary returns aUrl unchanged. Three-strikes
	 extraction from listFiles:, listSkills:, and listVersionsFor:params:."
	| parts separator |
	(aDictionary isNil or: [ aDictionary isEmpty ]) ifTrue: [ ^ aUrl ].
	parts := OrderedCollection new.
	aDictionary keys asSortedCollection do: [ :k |
		parts add: k, '=', (aDictionary at: k) urlEncoded ].
	separator := (aUrl indexOf: $?) > 0 ifTrue: [ '&' ] ifFalse: [ '?' ].
	^ aUrl, separator, (parts joinUsing: '&')
]

{ #category : 'private' }
ClaudeClient >> applyRetryAfterMsFrom: aHeaders to: anError [
	"Parse retry-after-ms (milliseconds) from aHeaders. If present and parseable,
	 set anError retryAfter (clamped to zero) and answer true. If absent or unparseable,
	 answer false so the caller can fall back to plain retry-after."
	| raw parsed |
	raw := aHeaders at: 'retry-after-ms' ifAbsent: [ ^ false ].
	parsed := raw asInteger.
	parsed ifNil: [ ^ false ].
	anError retryAfter: (parsed max: 0) / 1000.0.
	^ true
]

{ #category : 'private' }
ClaudeClient >> applyRetryAfterSecondsFrom: aHeaders to: anError [
	"Parse plain retry-after (seconds) from aHeaders. If present and parseable,
	 set anError retryAfter clamped to zero. Malformed values leave it nil so
	 backoffDelay:retryAfter: uses exponential backoff."
	| raw parsed |
	raw := aHeaders at: 'retry-after' ifAbsent: [ ^ self ].
	parsed := raw asInteger.
	parsed ifNil: [ ^ self ].
	anError retryAfter: (parsed max: 0)
]

{ #category : 'private' }
ClaudeClient >> backoffDelay: attempt retryAfter: retryAfterOrNil [
	"Calculate delay for retry attempt.
	 Respects Retry-After header value (in seconds), clamped to [0s, 30s] to
	 defend against negative values (clock skew / proxy / malicious) and
	 excessive values (worst case 120s x maxRetries = 10 minutes wall block).
	 Falls back to exponential backoff with jitter, capped at 8s."
	| baseDelay jitteredDelay clampedRetryAfter |
	retryAfterOrNil ifNotNil: [ :ra |
		clampedRetryAfter := (ra max: 0) min: 30.
		^ Delay forMilliseconds: (clampedRetryAfter * 1000) asInteger ].
	baseDelay := 0.5 * (2 raisedTo: attempt - 1).
	baseDelay := baseDelay min: 8.0.
	jitteredDelay := baseDelay * (0.75 + (0.5 * (101 atRandom - 1) / 100.0)).
	^ Delay forMilliseconds: (jitteredDelay * 1000) asInteger
]

{ #category : 'accessing' }
ClaudeClient >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
ClaudeClient >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'private' }
ClaudeClient >> betaHeaderValueFor: aClaudeMessageRequest [
	"Answer the comma-joined anthropic-beta header value from request options, or nil."
	^ aClaudeMessageRequest requestOptions ifNotNil: [ :opts | opts betaHeader ]
]

{ #category : 'private' }
ClaudeClient >> buildModelListUrlWithLimit: limit after: afterId [
	"Private. Build URL with query parameters for model listing."
	| url params |
	url := baseUrl, '/v1/models'.
	
	(limit notNil or: [ afterId notNil ]) ifFalse: [ ^ url ].
	
	params := OrderedCollection new.
	limit ifNotNil: [ params add: 'limit=', limit asString ].
	afterId ifNotNil: [ params add: 'after_id=', afterId ].
	
	^ params ifEmpty: [ url ] ifNotEmpty: [ url, '?', (params joinUsing: '&') ]
]

{ #category : 'private' }
ClaudeClient >> buildStreamingSkillPartsInto: aStreamingEntity fromDirectory: aDirectoryReference [
    "Validate SKILL.md is at the directory root, that the directory's
    basename matches the frontmatter name: field, and that the total
    size is within the upload limits, then enumerate every file under
    aDirectoryReference and append each as a streaming file part on
    aStreamingEntity. Each part uses fieldName 'files[]' (the literal
    bracketed field name the Skills API expects) and a POSIX-separated
    fileName prefixed with the directory basename — so a file at
    skillDir/SKILL.md serializes as '<basename>/SKILL.md' and a nested
    skillDir/helpers/util.py as '<basename>/helpers/util.py'.

    Guard order (matters for error precedence): SKILL.md presence →
    directory-name matches frontmatter name: → total/per-file size. A
    skill whose directory name disagrees with SKILL.md's name: AND
    whose files are oversized reports the name mismatch first.

    Limits: per-file 25 MB (ClaudeClient maxSkillFileBytes), total
    100 MB (ClaudeClient maxSkillUploadBytes). The per-file cap is
    defense in depth — with streaming uploads the client memory
    pressure argument is gone, but the server has its own limits and
    rejecting locally before bytes fly is cheaper than a 413.

    Raises Error if SKILL.md is missing, the directory basename does
    not match the frontmatter name: value, or a file / total size
    exceeds the documented limit.

    Returns self for chaining; mutates aStreamingEntity by appending
    file parts."
    | skillMd rootName frontmatterName allFiles |
    skillMd := aDirectoryReference / 'SKILL.md'.
    skillMd exists ifFalse: [
        Error signal: 'SKILL.md not found at directory root: ', aDirectoryReference fullName ].
    rootName := aDirectoryReference basename.
    frontmatterName := self skillNameFromFrontmatterAt: skillMd.
    (frontmatterName notNil and: [ frontmatterName ~= rootName ]) ifTrue: [
        Error signal: 'Skill directory basename "', rootName, '" does not match name: "',
            frontmatterName, '" in SKILL.md frontmatter' ].
    allFiles := aDirectoryReference allFiles.
    self validateSkillUploadSize: allFiles.
    allFiles do: [ :file |
        | posixName |
        posixName := String streamContents: [ :s |
            s nextPutAll: rootName; nextPutAll: '/'.
            (file relativeTo: aDirectoryReference) segments
                do: [ :seg | s nextPutAll: seg ]
                separatedBy: [ s nextPutAll: '/' ] ].
        aStreamingEntity
            addFilePart: 'files[]'
            fileName: posixName
            contentType: (ZnMimeType forFilenameExtension: file extension)
            fileReference: file ].
    ^ self
]

{ #category : 'private' }
ClaudeClient >> checkResponse: aZnResponse [
	"Signal typed ClaudeApiError if response is not 2xx. Parses Retry-After headers.
	 Tries retry-after-ms first; if absent or unparseable, falls through to retry-after
	 (seconds). Negative or malformed values are clamped/discarded — neither can reach
	 backoffDelay:retryAfter: as a crash sentinel. See bead zty and
	 docs/coes/2026-04-08-rename-method-cascade.md."
	| error headers |
	aZnResponse isSuccess ifTrue: [ ^ self ].
	headers := aZnResponse headers.
	error := self errorFor: aZnResponse.
	(self applyRetryAfterMsFrom: headers to: error)
		ifFalse: [ self applyRetryAfterSecondsFrom: headers to: error ].
	error signal
]

{ #category : 'API' }
ClaudeClient >> countTokens: aClaudeMessageRequest [
	"Count tokens for a message. Returns ClaudeMessageTokensCount.
	 The count_tokens endpoint accepts model, messages, system, and tools only.
	 Uses composedSystem to include the output format suffix in the count."
	^ self executeWithRetry: [
		| http json response payload composed |
		http := self newHttpClientFor: aClaudeMessageRequest.
		payload := OrderedDictionary new.
		payload at: 'model' put: aClaudeMessageRequest model.
		payload at: 'messages' put: (aClaudeMessageRequest messages collect: [ :m | m asParam ]) asArray.
		composed := aClaudeMessageRequest composedSystem.
		composed ifNotNil: [ :s |
			payload at: 'system' put: (s isString
				ifTrue: [ s ]
				ifFalse: [ (s collect: [ :b | b asJson ]) asArray ]) ].
		aClaudeMessageRequest tools ifNotNil: [ :t |
			payload at: 'tools' put: (t collect: [ :tool | tool asJson ]) asArray ].
		json := STONJSON toString: payload.
		response := http
			url: baseUrl, '/v1/messages/count_tokens';
			entity: (ZnEntity json: json);
			post;
			response.
		self checkResponse: response.
		ClaudeMessageTokensCount fromJson: (STONJSON fromString: response contents) ]
]

{ #category : 'configuration' }
ClaudeClient >> debugLog: aBlockOrNil [
	"Set a debug logging block. The block receives a Dictionary with keys
	 #direction (#request or #response), #url, #body, #status (response only).
	 Pass nil to disable logging.
	 Raises an Error if the argument is not nil and does not respond to #value:."
	(aBlockOrNil isNil or: [ aBlockOrNil isBlock ])
		ifFalse: [
			Error signal: 'debugLog: requires a block (or nil), got: '
				, aBlockOrNil printString ].
	debugLogBlock := aBlockOrNil
]

{ #category : 'files' }
ClaudeClient >> deleteFile: aFileId [
	"Delete a file. Returns ClaudeDeletedFile."
	^ self executeWithRetry: [
		| http resp |
		http := self newFileHttpClient.
		http url: baseUrl, '/v1/files/', aFileId.
		resp := http delete; response.
		self checkResponse: resp.
		ClaudeDeletedFile fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'skills' }
ClaudeClient >> deleteSkill: aSkillId [
	"Delete a skill. Returns ClaudeDeletedSkill."
	^ self executeWithRetry: [
		| http resp |
		http := self newSkillHttpClient.
		http url: baseUrl, '/v1/skills/', aSkillId, '?beta=true'.
		resp := http delete; response.
		self checkResponse: resp.
		ClaudeDeletedSkill fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'skills' }
ClaudeClient >> deleteVersion: aVersionId for: aSkillId [
	"Delete a skill version. Returns ClaudeDeletedSkillVersion."
	^ self executeWithRetry: [
		| http resp |
		http := self newSkillHttpClient.
		http url: baseUrl, '/v1/skills/', aSkillId, '/versions/', aVersionId, '?beta=true'.
		resp := http delete; response.
		self checkResponse: resp.
		ClaudeDeletedSkillVersion fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'files' }
ClaudeClient >> downloadFile: aFileId [
	"Download file content. Returns ByteArray."
	^ self executeWithRetry: [
		| http resp |
		http := self newFileHttpClient.
		http
			headerAt: 'accept' put: '*/*';
			url: baseUrl, '/v1/files/', aFileId, '/content';
			beBinary.
		resp := http get; response.
		self checkResponse: resp.
		resp entity bytes ]
]

{ #category : 'private' }
ClaudeClient >> errorFor: aZnResponse [
  "Build a typed ClaudeApiError from a non-2xx response and attach the
   parsed response-header metadata so callers handling 429 / overload
   can inspect rate-limit headers and request-id without re-parsing."
  | requestId metadata error |
  metadata := ClaudeResponseMetadata fromZnHeaders: aZnResponse headers.
  requestId := metadata requestId ifNil: [ '' ].
  error := ClaudeApiError
    fromStatusCode: aZnResponse statusLine code
    json: (aZnResponse contents ifNil: [ '' ])
    requestId: requestId.
  error responseMetadata: metadata.
  ^ error
]

{ #category : 'private' }
ClaudeClient >> executeWithRetry: aBlock [
	"Execute aBlock (which does HTTP + checkResponse:). Acquire a rate limit permit
	 before each attempt when a rate limiter is set. Retry on retryable errors,
	 logging each attempt and any final exhaustion to the Transcript.
	 Network errors from ZnClient are narrowed:
	   - ConnectionTimedOut -> ClaudeTimeoutError(408), retryable (matches streaming path).
	   - Other NetworkError subclasses (ConnectionRefused, SocketClosed, TLS failures)
	     -> ClaudeNetworkError(599), non-retryable, propagates to caller. See i7uc."

	| attempt |
	attempt := 0.
	[
		rateLimiter ifNotNil: [ :rl | rl acquire ].
		[[[ ^ aBlock value ]
			on: ConnectionTimedOut
			do: [ :timeoutError |
				(ClaudeTimeoutError new
					statusCode: 408;
					message: timeoutError messageText;
					yourself) signal ] ]
			on: NetworkError
			do: [ :netError |
				(ClaudeNetworkError new
					statusCode: 599;
					message: netError class name , ': ' , netError messageText;
					yourself) signal ] ]
			on: ClaudeApiError
			do: [ :error |
				error isRetryable ifFalse: [ error signal ].
				attempt := attempt + 1.
				attempt > maxRetries ifTrue: [
					self logRetryExhaustedFor: error at: attempt.
					error signal ].
				self logRetryAttempt: attempt of: maxRetries for: error.
				(self backoffDelay: attempt retryAfter: error retryAfter) wait ]
	] repeat
]

{ #category : 'files' }
ClaudeClient >> getFileMetadata: aFileId [
	"Get metadata for a file. Returns ClaudeFileMetadata."
	^ self executeWithRetry: [
		| http resp |
		http := self newFileHttpClient.
		http url: baseUrl, '/v1/files/', aFileId.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeFileMetadata fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'api' }
ClaudeClient >> getModel: modelId [
	"Get model info. Returns ClaudeModelInfo."
	^ self executeWithRetry: [
		| http response |
		http := self newHttpClient.
		response := http
			url: baseUrl, '/v1/models/', modelId;
			get;
			response.
		self checkResponse: response.
		ClaudeModelInfo fromJson: (STONJSON fromString: response contents) ]
]

{ #category : 'skills' }
ClaudeClient >> getSkill: aSkillId [
	"Get a skill by ID. Returns ClaudeSkill."
	^ self executeWithRetry: [
		| http resp |
		http := self newSkillHttpClient.
		http url: baseUrl, '/v1/skills/', aSkillId, '?beta=true'.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeSkill fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'skills' }
ClaudeClient >> getVersion: aVersionId for: aSkillId [
	"Get a specific skill version. Returns ClaudeSkillVersion."
	^ self executeWithRetry: [
		| http resp |
		http := self newSkillHttpClient.
		http url: baseUrl, '/v1/skills/', aSkillId, '/versions/', aVersionId, '?beta=true'.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeSkillVersion fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'private' }
ClaudeClient >> handleStreamingError: statusCode headers: headers socket: sock [
  "Handle HTTP error responses from a streaming socket. Attaches
   ClaudeResponseMetadata so streaming-path errors carry the same
   header surface as non-streaming-path errors (mission yvyt+pch2)."
  | body error metadata |
  body := [sock readLine]
    on: Error
    do: [:e | '' ].
  sock close.
  metadata := ClaudeResponseMetadata fromZnHeaders: headers.
  error := ClaudeApiError
    fromStatusCode: statusCode
    json: body
    requestId: (metadata requestId ifNil: [ '' ]).
  error responseMetadata: metadata.
  error signal
]

{ #category : 'initialization' }
ClaudeClient >> initialize [

	baseUrl := 'https://api.anthropic.com'.
	apiVersion := '2023-06-01'.
	timeout := 120.
	streamingTimeout := 300.
	maxRetries := 5
]

{ #category : 'files' }
ClaudeClient >> listFiles [
	"List files with default pagination. Returns ClaudeFilePage."
	^ self listFiles: nil
]

{ #category : 'files' }
ClaudeClient >> listFiles: aClaudeFileListParams [
	"List files with optional pagination params. Returns ClaudeFilePage."
	^ self executeWithRetry: [
		| http url resp |
		http := self newFileHttpClient.
		url := baseUrl, '/v1/files'.
		aClaudeFileListParams ifNotNil: [ :params |
			url := self appendQueryParams: params asQueryParams toUrl: url ].
		http url: url.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeFilePage fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'api' }
ClaudeClient >> listModels [
	"List available models. Returns OrderedCollection of ClaudeModelInfo."
	^ self executeWithRetry: [
		| http response data |
		http := self newHttpClient.
		self notifyDebugLog: { #direction -> #request . #url -> (baseUrl, '/v1/models') } asDictionary.
		response := http
			url: baseUrl, '/v1/models';
			get;
			response.
		self notifyDebugLog: { #direction -> #response . #status -> response code . #body -> response contents } asDictionary.
		self checkResponse: response.
		data := STONJSON fromString: response contents.
		((data at: 'data') collect: [ :each | ClaudeModelInfo fromJson: each ]) asOrderedCollection ]
]

{ #category : 'api' }
ClaudeClient >> listModels: limit after: afterId [
	"List available models with pagination. Returns Dictionary with data, has_more, first_id, last_id."
	^ self executeWithRetry: [
		| http response data url |
		url := self buildModelListUrlWithLimit: limit after: afterId.
		
		http := self newHttpClient.
		self notifyDebugLog: { #direction -> #request . #url -> url } asDictionary.
		response := http
			url: url;
			get;
			response.
		self notifyDebugLog: { #direction -> #response . #status -> response code . #body -> response contents } asDictionary.
		self checkResponse: response.
		data := STONJSON fromString: response contents.
		
		self parseModelListResponse: data ]
]

{ #category : 'skills' }
ClaudeClient >> listSkills [
	"List skills with default pagination. Returns ClaudeSkillPage."
	^ self listSkills: nil
]

{ #category : 'skills' }
ClaudeClient >> listSkills: aClaudeSkillListParamsOrNil [
	"List skills with optional query params. Returns ClaudeSkillPage."
	^ self executeWithRetry: [
		| http url resp |
		http := self newSkillHttpClient.
		url := baseUrl, '/v1/skills?beta=true'.
		aClaudeSkillListParamsOrNil ifNotNil: [ :params |
			url := self appendQueryParams: params asQueryParams toUrl: url ].
		http url: url.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeSkillPage fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'skills' }
ClaudeClient >> listVersionsFor: aSkillId [
	"List versions for a skill with default pagination. Returns ClaudeSkillVersionPage."
	^ self listVersionsFor: aSkillId params: nil
]

{ #category : 'skills' }
ClaudeClient >> listVersionsFor: aSkillId params: aClaudeSkillVersionListParamsOrNil [
	"List versions for a skill with optional query params. Returns ClaudeSkillVersionPage."
	^ self executeWithRetry: [
		| http url resp |
		http := self newSkillHttpClient.
		url := baseUrl, '/v1/skills/', aSkillId, '/versions?beta=true'.
		aClaudeSkillVersionListParamsOrNil ifNotNil: [ :params |
			url := self appendQueryParams: params asQueryParams toUrl: url ].
		http url: url.
		resp := http get; response.
		self checkResponse: resp.
		ClaudeSkillVersionPage fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'private' }
ClaudeClient >> logRetryAttempt: attempt of: maxAttempts for: error [
	"Log a retry attempt to Transcript so callers see why we are pausing."
	Transcript
		nextPutAll: '[Claude retry] attempt ';
		nextPutAll: attempt printString;
		nextPutAll: '/';
		nextPutAll: maxAttempts printString;
		nextPutAll: ': ';
		nextPutAll: error class name;
		nextPutAll: ' (';
		nextPutAll: error statusCode printString;
		nextPutAll: ')';
		cr;
		flush
]

{ #category : 'private' }
ClaudeClient >> logRetryExhaustedFor: error at: attempt [
	"Log retry budget exhaustion so the agent sees why a retry failed
	 instead of just receiving a raised error after a long pause."
	Transcript
		nextPutAll: '[Claude retry] exhausted after ';
		nextPutAll: attempt printString;
		nextPutAll: ' attempts: ';
		nextPutAll: error class name;
		nextPutAll: ' (';
		nextPutAll: error statusCode printString;
		nextPutAll: ')';
		cr;
		flush
]

{ #category : 'accessing' }
ClaudeClient >> maxRetries [

	^ maxRetries
]

{ #category : 'accessing' }
ClaudeClient >> maxRetries: anInteger [

	maxRetries := anInteger
]

{ #category : 'private' }
ClaudeClient >> newFileHttpClient [
	"Create a ZnClient with auth headers and the Files API beta header."
	^ ZnClient new
		headerAt: 'x-api-key' put: apiKey;
		headerAt: 'anthropic-version' put: apiVersion;
		headerAt: 'anthropic-beta' put: ClaudeBetaHeader filesApi;
		headerAt: 'accept' put: 'application/json';
		timeout: timeout;
		yourself
]

{ #category : 'private' }
ClaudeClient >> newHttpClient [
	"Create a fresh ZnClient with standard headers"

	^ ZnClient new
		headerAt: 'x-api-key' put: apiKey;
		headerAt: 'anthropic-version' put: apiVersion;
		headerAt: 'content-type' put: 'application/json';
		headerAt: 'accept' put: 'application/json';
		timeout: timeout;
		yourself
]

{ #category : 'private' }
ClaudeClient >> newHttpClientFor: aClaudeMessageRequest [
	"Build a ZnClient with standard auth headers, and the anthropic-beta header when betas are set on the request options."
	| http betaValue |
	http := self newHttpClient.
	betaValue := self betaHeaderValueFor: aClaudeMessageRequest.
	betaValue ifNotNil: [ http headerAt: 'anthropic-beta' put: betaValue ].
	^ http
]

{ #category : 'private' }
ClaudeClient >> newSkillHttpClient [
	"Create a ZnClient with auth headers and the Skills API beta header."
	^ ZnClient new
		headerAt: 'x-api-key' put: apiKey;
		headerAt: 'anthropic-version' put: apiVersion;
		headerAt: 'anthropic-beta' put: ClaudeBetaHeader skills;
		headerAt: 'accept' put: 'application/json';
		timeout: timeout;
		yourself
]

{ #category : 'private' }
ClaudeClient >> notifyDebugLog: anObject [
	"If a debug log block is set, evaluate it with anObject."
	debugLogBlock ifNotNil: [ :blk | blk value: anObject ]
]

{ #category : 'private' }
ClaudeClient >> openBufferedStreamingSocket: aClaudeMessageRequest [
	"Buffered streaming via ZnClient. Reads full response then returns a ReadStream. Used for HTTP mock servers in tests."
	^ self executeWithRetry: [
		| http paramsJson contents |
		http := self newHttpClientFor: aClaudeMessageRequest.
		http timeout: streamingTimeout.
		paramsJson := STONJSON toString: aClaudeMessageRequest asJson.
		http
			url: baseUrl, '/v1/messages';
			entity: (ZnEntity text: paramsJson);
			streaming: true;
			post.
		self checkResponse: http response.
		contents := http response entity contents asString.
		contents readStream ]
]

{ #category : 'streaming' }
ClaudeClient >> openStreamingSocket: aClaudeMessageRequest [
	"Open a streaming connection. Uses real TLS socket for HTTPS (incremental SSE) or falls back to buffered ZnClient for HTTP (test/mock servers). Both return objects compatible with ClaudeSSEDecoder (atEnd/nextLine)."
	aClaudeMessageRequest stream: true.
	(baseUrl beginsWith: 'https://')
		ifTrue: [ ^ self openTLSStreamingSocket: aClaudeMessageRequest ]
		ifFalse: [ ^ self openBufferedStreamingSocket: aClaudeMessageRequest ]
]

{ #category : 'private' }
ClaudeClient >> openTLSStreamingSocket: aClaudeMessageRequest [
	"Real incremental streaming via TLS socket. Returns a ClaudeStreamingSocket
	 for line-by-line SSE reading. Network errors are narrowed:
	   - ConnectionTimedOut -> ClaudeTimeoutError(408), retryable at the caller level.
	   - Other NetworkError subclasses -> ClaudeNetworkError(599), non-retryable.
	 See i7uc."

	| sock statusCode headers |
	sock := ClaudeStreamingSocket host: self apiHost.
	sock timeout: streamingTimeout.
	statusCode := 0.
	headers := Dictionary new.
	[[
		sock connect.
		sock sendPost: '/v1/messages'
			headers: (self streamingHeadersFor: aClaudeMessageRequest)
			body: (STONJSON toString: aClaudeMessageRequest asJson).
		statusCode := sock readStatusLine.
		headers := sock readHeaders ]
		on: ConnectionTimedOut
		do: [ :e | self signalTimeoutClosing: sock message: e messageText ] ]
		on: NetworkError
		do: [ :e | self signalNetworkErrorClosing: sock message: e class name , ': ' , e messageText ].
	statusCode >= 400
		ifTrue: [ self handleStreamingError: statusCode headers: headers socket: sock ].
	sock requestId: (headers at: 'request-id' ifAbsent: [ nil ]).
	^ sock
]

{ #category : 'private' }
ClaudeClient >> parseFrontmatterNameValue: aLine [
	"Parse the value side of a `name: <value>` frontmatter line.
	 Strips matched single- or double-quote pairs around the value;
	 lone or mismatched quotes are left in place so the caller sees
	 the raw oddity rather than a silently truncated name. Returns nil
	 if the line is too short, the value is empty, or the value is
	 still empty after quote stripping and trimming."
	| value |
	aLine size < 6 ifTrue: [ ^ nil ].
	value := (aLine copyFrom: 6 to: aLine size) trimBoth.
	value isEmpty ifTrue: [ ^ nil ].
	(value size >= 2 and: [ value first = $" and: [ value last = $" ] ])
		ifTrue: [ value := value copyFrom: 2 to: value size - 1 ].
	(value size >= 2 and: [ value first = $' and: [ value last = $' ] ])
		ifTrue: [ value := value copyFrom: 2 to: value size - 1 ].
	value := value trimBoth.
	value isEmpty ifTrue: [ ^ nil ].
	^ value
]

{ #category : 'private' }
ClaudeClient >> parseModelListResponse: jsonData [
	"Private. Parse model list API response into structured dictionary."
	^ Dictionary new
		at: 'data' put: ((jsonData at: 'data') collect: [ :each | 
			ClaudeModelInfo fromJson: each ]) asOrderedCollection;
		at: 'has_more' put: (jsonData at: 'has_more' ifAbsent: [ false ]);
		at: 'first_id' put: (jsonData at: 'first_id' ifAbsent: [ nil ]);
		at: 'last_id' put: (jsonData at: 'last_id' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'printing' }
ClaudeClient >> printOn: aStream [

	aStream
		nextPutAll: 'ClaudeClient(';
		nextPutAll: baseUrl;
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeClient >> rateLimiter [
	"Answer the rate limiter for this client, or nil if none is set."
	^ rateLimiter
]

{ #category : 'accessing' }
ClaudeClient >> rateLimiter: aClaudeRateLimiter [
	rateLimiter := aClaudeRateLimiter
]

{ #category : 'API' }
ClaudeClient >> sendMessage: aClaudeMessageRequest [
  "Send a non-streaming message. Returns ClaudeMessage. The returned
   message carries a ClaudeResponseMetadata holding request-id, the
   nine anthropic-ratelimit-* monitoring counters, and Retry-After
   when present (mission yvyt+pch2). msg requestId still works
   transparently --- storage delegates to responseMetadata."
  | response |
  response := self executeWithRetry: [
    | http json resp msg metadata |
    http := self newHttpClientFor: aClaudeMessageRequest.
    json := STONJSON toString: aClaudeMessageRequest asJson.
    http
      url: baseUrl, '/v1/messages';
      entity: (ZnEntity json: json).
    self notifyDebugLog: { #direction -> #request . #url -> (baseUrl, '/v1/messages') . #body -> json } asDictionary.
    resp := http post; response.
    self notifyDebugLog: { #direction -> #response . #status -> resp code . #body -> resp contents } asDictionary.
    self checkResponse: resp.
    msg := ClaudeMessage fromJson: (STONJSON fromString: resp contents).
    metadata := ClaudeResponseMetadata fromZnHeaders: resp headers.
    msg responseMetadata: metadata.
    msg ].
  response outputFormat: aClaudeMessageRequest outputFormat.
  ^ response
]

{ #category : 'private' }
ClaudeClient >> signalNetworkErrorClosing: sock message: aString [
	"Close socket and signal ClaudeNetworkError with statusCode 599.
	 Used by openTLSStreamingSocket: for non-timeout NetworkError
	 subclasses (refused connections, closed sockets, TLS handshake
	 failures). Sibling of signalTimeoutClosing:message: — kept as a
	 separate helper so the timeout path retains its exact behavior
	 and so each caller reads as ``signal the right thing, then close``.
	 See bead i7uc."

	sock close.
	(ClaudeNetworkError new statusCode: 599; message: aString; yourself) signal
]

{ #category : 'private' }
ClaudeClient >> signalTimeoutClosing: sock message: aString [
	"Close socket and signal ClaudeTimeoutError with statusCode 408."
	sock close.
	(ClaudeTimeoutError new statusCode: 408; message: aString; yourself) signal
]

{ #category : 'private' }
ClaudeClient >> skillNameFromFrontmatterAt: aSkillMdReference [
	"Scan the SKILL.md file for a YAML frontmatter `name:` field.
	 Returns the trimmed, unquoted name value as a String, or nil if no
	 frontmatter exists, no name: line is found, or the name value is
	 empty. Does NOT require a full YAML parser -- we only need the
	 leading `---` ... `---` block, and within it a simple
	 `/^name:\s*(.+)$/` line. See #parseFrontmatterNameValue: for the
	 quote-stripping rules applied to the value side."
	| lines |
	aSkillMdReference exists ifFalse: [ ^ nil ].
	lines := aSkillMdReference contents lines.
	lines isEmpty ifTrue: [ ^ nil ].
	(lines first trimBoth = '---') ifFalse: [ ^ nil ].
	2 to: lines size do: [ :i |
		| line |
		line := lines at: i.
		line trimBoth = '---' ifTrue: [ ^ nil ].
		(line beginsWith: 'name:')
			ifTrue: [ ^ self parseFrontmatterNameValue: line ] ].
	^ nil
]

{ #category : 'batches' }
ClaudeClient >> streamBatchResults: aBatchId do: aBlock [
	"Fetch the JSONL results for an ended batch and yield each parsed
	 ClaudeBatchResult to aBlock. Returns an OrderedCollection of every result.

	 Buffered (not incremental) for v0.6: reads the full JSONL response into
	 memory, parses every non-empty line into a local collection, then does a
	 single pass at the end yielding each entry to aBlock. The Anthropic
	 results endpoint sends one complete JSON object per line over a
	 non-chunked HTTP response, so ZnClient buffers it correctly without
	 needing the SSE-style streaming socket. ADR-43 documents the rationale;
	 an incremental variant can be added later if callers report memory
	 pressure on very large batches.

	 Both side effects -- aBlock invocation and results accumulation -- happen
	 exactly once per entry, after the response is fully and successfully
	 parsed. If executeWithRetry: retries the GET (e.g., a transient 5xx),
	 the partially-parsed entries from the failed attempt are discarded and
	 the caller never sees duplicates.

	 Raises ClaudeBatchNotEndedError if resultsUrl is nil (batch hasn't
	 ended yet -- poll getBatch: or use pollBatch:untilEndedEvery: first)."
	| batch |
	batch := self getBatch: aBatchId.
	batch resultsUrl ifNil: [ ClaudeBatchNotEndedError signal ].
	^ self executeWithRetry: [
		| http resp body results |
		http := self newBatchHttpClient.
		http
			headerAt: 'accept' put: 'application/x-jsonl';
			url: batch resultsUrl.
		resp := http get; response.
		self checkResponse: resp.
		body := (resp contents ifNil: [ '' ]) asString.
		results := (body lines reject: [ :line | line trimBoth isEmpty ])
			collect: [ :line | ClaudeBatchResult fromJson: (STONJSON fromString: line) ].
		results do: aBlock.
		results ]
]

{ #category : 'streaming' }
ClaudeClient >> streamMessage: aClaudeMessageRequest do: aBlock [
	"Send a streaming message. Calls aBlock with each event dict. Returns the
	 accumulated ClaudeMessage. Uses incremental TLS streaming for HTTPS,
	 buffered for HTTP. Network errors during SSE decoding are narrowed the
	 same way as executeWithRetry: — ConnectionTimedOut becomes
	 ClaudeTimeoutError(408), other NetworkError subclasses become
	 ClaudeNetworkError(599). See i7uc."

	| sock decoder message |
	aClaudeMessageRequest stream: true.
	sock := self openStreamingSocket: aClaudeMessageRequest.
	message := ClaudeMessage new.
	decoder := ClaudeSSEDecoder onStream: sock.
	[[[ [ decoder hasNext ] whileTrue: [
		| event |
		event := decoder nextEvent.
		message accumulate: event.
		aBlock value: event ] ]
		on: ConnectionTimedOut
		do: [ :e | self signalTimeoutClosing: sock message: e messageText ] ]
		on: NetworkError
		do: [ :e | self signalNetworkErrorClosing: sock message: e class name , ': ' , e messageText ]
	] ensure: [ sock close ].
	sock isClaudeStreamingSocket
		ifTrue: [ message requestId: sock requestId ].
	message outputFormat: aClaudeMessageRequest outputFormat.
	^ message
]

{ #category : 'streaming' }
ClaudeClient >> streamRawBody: aClaudeMessageRequest [
	"Send a streaming request, return the raw SSE response body as a String.
	 Uses newHttpClientFor: so that anthropic-beta headers are propagated."
	^ self executeWithRetry: [
		| http requestJson response |
		aClaudeMessageRequest stream: true.
		http := self newHttpClientFor: aClaudeMessageRequest.
		http timeout: streamingTimeout.
		requestJson := STONJSON toString: aClaudeMessageRequest asJson.
		response := http
			url: baseUrl, '/v1/messages';
			entity: (ZnEntity text: requestJson);
			post;
			response.
		self checkResponse: response.
		response contents ]
]

{ #category : 'private' }
ClaudeClient >> streamingHeaders [
	"Build HTTP headers for a streaming request."
	^ OrderedDictionary newFromPairs: {
		'x-api-key'. apiKey.
		'anthropic-version'. apiVersion.
		'content-type'. 'application/json'.
		'accept'. 'text/event-stream' }
]

{ #category : 'private' }
ClaudeClient >> streamingHeadersFor: aClaudeMessageRequest [
	"Build HTTP headers for a streaming request, adding anthropic-beta when betas are set."
	| headers betaValue |
	headers := self streamingHeaders.
	betaValue := self betaHeaderValueFor: aClaudeMessageRequest.
	betaValue ifNotNil: [ headers at: 'anthropic-beta' put: betaValue ].
	^ headers
]

{ #category : 'accessing' }
ClaudeClient >> streamingTimeout [

	^ streamingTimeout
]

{ #category : 'accessing' }
ClaudeClient >> streamingTimeout: anInteger [

	streamingTimeout := anInteger
]

{ #category : 'accessing' }
ClaudeClient >> timeout [

	^ timeout
]

{ #category : 'accessing' }
ClaudeClient >> timeout: anInteger [

	timeout := anInteger
]

{ #category : 'skills' }
ClaudeClient >> uploadDirectory: aDirectoryReference displayTitle: aDisplayTitleOrNil [
    "Upload a directory tree as a new skill. Walks the directory, validates
     that SKILL.md exists at the root (LD-5), and POSTs a multipart body
     with one 'files[]' file part per file plus an optional display_title
     form field. The multipart body streams from disk in 64 KB chunks —
     even a skill at the 100 MB total limit never fully materializes in
     memory. Returns ClaudeSkill."
    | entity |
    entity := ClaudeStreamingMultiPartEntity new.
    aDisplayTitleOrNil ifNotNil: [
        entity addValuePart: 'display_title' value: aDisplayTitleOrNil ].
    self buildStreamingSkillPartsInto: entity fromDirectory: aDirectoryReference.
    ^ self executeWithRetry: [
        | http resp |
        http := self newSkillHttpClient.
        http
            url: baseUrl, '/v1/skills?beta=true';
            entity: entity.
        resp := http post; response.
        self checkResponse: resp.
        ClaudeSkill fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'files' }
ClaudeClient >> uploadFile: aFileReference [
	"Upload a file. Auto-detects MIME type from extension."
	| mimeType |
	mimeType := ZnMimeType forFilenameExtension: aFileReference extension.
	^ self uploadFile: aFileReference filename: aFileReference basename mimeType: mimeType printString
]

{ #category : 'files' }
ClaudeClient >> uploadFile: aFileReference filename: aFilename mimeType: aMimeTypeString [
    "Upload a file with explicit filename and MIME type. Returns ClaudeFileMetadata.
    Uses ClaudeStreamingMultiPartEntity so the file streams from disk in 64 KB
    chunks rather than being read entirely into memory (see mission sylk)."
    ^ self executeWithRetry: [
        | http entity resp |
        http := self newFileHttpClient.
        entity := ClaudeStreamingMultiPartEntity new.
        entity
            addFilePart: 'file'
            fileName: aFilename
            contentType: (ZnMimeType fromString: aMimeTypeString)
            fileReference: aFileReference.
        http
            url: baseUrl, '/v1/files';
            entity: entity.
        resp := http post; response.
        self checkResponse: resp.
        ClaudeFileMetadata fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'skills' }
ClaudeClient >> uploadVersionFor: aSkillId fromDirectory: aDirectoryReference [
    "Upload a directory tree as a new version of an existing skill.
     SKILL.md must exist at the root. Streams from disk in 64 KB chunks
     via ClaudeStreamingMultiPartEntity. Returns ClaudeSkillVersion."
    | entity |
    entity := ClaudeStreamingMultiPartEntity new.
    self buildStreamingSkillPartsInto: entity fromDirectory: aDirectoryReference.
    ^ self executeWithRetry: [
        | http resp |
        http := self newSkillHttpClient.
        http
            url: baseUrl, '/v1/skills/', aSkillId, '/versions?beta=true';
            entity: entity.
        resp := http post; response.
        self checkResponse: resp.
        ClaudeSkillVersion fromJson: (STONJSON fromString: resp contents) ]
]

{ #category : 'private' }
ClaudeClient >> validateSkillUploadSize: aCollectionOfFiles [
	"Reject skill uploads that exceed the per-file limit (25 MB) or the
	total upload limit (100 MB summed across all files). Both limits are
	enforced client-side so callers see a clear error before bytes are
	read from disk and before the network round-trip. Uploads stream from
	disk via ClaudeStreamingMultiPartEntity — the limits are defense in
	depth against server-side rejection (413 Payload Too Large) and not
	a client-side memory ceiling.

	Raises Error with the offending file basename (per-file case) or the
	actual total size in MB (total case). The total is formatted as a
	float with 2 decimal places so non-aligned totals report as
	'107.50MB' rather than the Smalltalk Fraction printString
	'(112721920/1048576)MB'."
	| perFileLimit totalLimit totalBytes |
	perFileLimit := self class maxSkillFileBytes.
	totalLimit := self class maxSkillUploadBytes.
	aCollectionOfFiles do: [ :file |
		file size > perFileLimit ifTrue: [
			Error signal: (String streamContents: [ :s |
				s nextPutAll: 'Skill file exceeds 25MB limit: '.
				s nextPutAll: file basename ]) ] ].
	totalBytes := aCollectionOfFiles inject: 0 into: [ :sum :f | sum + f size ].
	totalBytes > totalLimit ifTrue: [
		Error signal: (String streamContents: [ :s |
			s nextPutAll: 'Skill upload exceeds 100MB total limit (got '.
			s nextPutAll: ((totalBytes / (1024 * 1024)) asFloat printShowingDecimalPlaces: 2).
			s nextPutAll: 'MB)' ]) ]
]
