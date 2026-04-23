"
Cache-control marker for Anthropic's prompt-caching feature. Mark a tool, text block, or tool result as cacheable and the API will cache the serialized prefix across requests that share your API key — reducing input-token cost on repeated prompts (see `https://docs.claude.com/en/docs/build-with-claude/prompt-caching`).

### The two-group wiring

Setters named `cacheControl:` split across two groups depending on
when the marker is serialized:

1. **asJson group** — `ClaudeTextBlock` and `ClaudeServerTool`
   accept a `ClaudeCacheControl` instance (or nil) and call
   `asJson` on it at request-serialization time. Pass the
   instance.
2. **Raw-dictionary group** — `ClaudeTool`, `ClaudeToolResultBlock`,
   `ClaudeMessageRequest`, and `ClaudeRequestOptions` store the
   value already serialized and pass it through unchanged. Pass
   `ClaudeCacheControl new asJson` (or a compatible Dictionary)
   — NOT the instance.

This split exists so legacy code that already ships a raw
Dictionary keeps working while new code can pass a typed instance
in the more common case.

### Building a marker

The class-side factories return a fully initialized instance. The
default TTL is the server-side 5-minute ephemeral cache; pass
`'5m'` or `'1h'` to `ephemeralWithTTL:` for explicit control:

```
ClaudeCacheControl ephemeral asJson
>>> an OrderedDictionary('type'->'ephemeral')
```

```
(ClaudeCacheControl ephemeralWithTTL: '5m') asJson
>>> an OrderedDictionary('type'->'ephemeral' 'ttl'->'5m')
```

`type` is always `'ephemeral'` — the only cache type Anthropic
currently exposes. A future `persistent` type would become a new
factory on the class side (`ClaudeCacheControl persistent`) rather
than a new instance variable.

### Wiring a tool as cacheable

Tools store cache markers as raw dictionaries, so serialize with
`asJson` when calling `cacheControl:`:

```
| tool |
tool := ClaudeTool
    name: 'analyze'
    description: 'Analyze code'
    inputSchema: ClaudeToolInputSchema new.
tool cacheControl: ClaudeCacheControl ephemeral asJson.
tool cacheControl
>>> an OrderedDictionary('type'->'ephemeral')
```

### Observing cache effectiveness

`ClaudeUsage` tracks cache hits and misses via
`cacheCreationInputTokens` (tokens written to the cache on a miss)
and `cacheReadInputTokens` (tokens served from the cache on a hit).
The Messages response carries these after every request; no extra
API call is needed.

### Limits

Four markers maximum per request — Anthropic enforces this on the
server side. Mark your largest static prefix first (system prompt,
tool definitions, RAG context) and use shorter `ttl` values only
when you need sub-5-minute eviction.
"
Class {
	#name : 'ClaudeCacheControl',
	#superclass : 'Object',
	#instVars : [
		'type',
		'ttl'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeCacheControl class >> ephemeral [
	^ self new
]

{ #category : 'instance creation' }
ClaudeCacheControl class >> ephemeralWithTTL: aString [
	^ self new
		ttl: aString;
		yourself
]

{ #category : 'json' }
ClaudeCacheControl class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ 'ephemeral' ]);
		ttl: (aDictionary at: 'ttl' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeCacheControl class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'json' }
ClaudeCacheControl >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: type.
	ttl ifNotNil: [ dict at: 'ttl' put: ttl ].
	^ dict
]

{ #category : 'initialization' }
ClaudeCacheControl >> initialize [
	super initialize.
	type := 'ephemeral'
]

{ #category : 'printing' }
ClaudeCacheControl >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeCacheControl(';
		nextPutAll: (type ifNil: [ '?' ]).
	ttl ifNotNil: [
		aStream nextPutAll: ' ttl: '; nextPutAll: ttl ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
ClaudeCacheControl >> ttl [
	^ ttl
]

{ #category : 'accessing' }
ClaudeCacheControl >> ttl: aString [
	ttl := aString
]

{ #category : 'accessing' }
ClaudeCacheControl >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeCacheControl >> type: aString [
	type := aString
]
