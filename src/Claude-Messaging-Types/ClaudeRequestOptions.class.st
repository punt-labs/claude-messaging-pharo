"
Optional per-request controls for Anthropic API calls: metadata, cache control, service tier, eager input streaming, streaming mode, beta feature flags, and MCP servers. Pass via ClaudeMessageRequest requestOptions to activate these controls.

The stream slot holds a boolean that tells the API to deliver the response as SSE events. Delegated from ClaudeMessageRequest stream / stream: for public API compatibility.

The betas slot holds an array of beta feature flag strings. When set, ClaudeClient sends them as a comma-joined anthropic-beta HTTP header on every request.

The mcpServers slot holds a collection of ClaudeMCPServerDefinition instances that Anthropic's infrastructure will connect out to during message generation. Activate by setting both betas: #('mcp-client-2025-04-04') and mcpServers: { ... }.

The container slot is polymorphic. It accepts either a plain String container ID (back-compat with the original Code Execution Tool shape) or a ClaudeContainerParams instance to load skills into the container. addFieldsTo: dispatches on isString so each form emits the correct wire shape.

### Examples

  ClaudeRequestOptions new betas: #('pdfs-2024-09-25' 'output-128k-2025-02-19'); betaHeader
  >>> 'pdfs-2024-09-25,output-128k-2025-02-19'

  ClaudeRequestOptions new hasBetas
  >>> false

  ClaudeRequestOptions new betas: #('pdfs-2024-09-25'); hasBetas
  >>> true

  ClaudeRequestOptions new stream: true; stream
  >>> true

  | opts |
  opts := ClaudeRequestOptions new.
  opts mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://mcp.example.com/sse' }.
  opts mcpServers size
  >>> 1

  | opts |
  opts := ClaudeRequestOptions new.
  opts container: 'ctr_abc'.
  opts container
  >>> 'ctr_abc'

  | opts |
  opts := ClaudeRequestOptions new.
  opts container: (ClaudeContainerParams new id: 'ctr_abc').
  (opts container isKindOf: ClaudeContainerParams)
  >>> true


"
Class {
	#name : 'ClaudeRequestOptions',
	#superclass : 'Object',
	#instVars : [
		'metadata',
		'cacheControl',
		'serviceTier',
		'eagerInputStreaming',
		'betas',
		'stream',
		'inferenceGeo',
		'container',
		'speed',
		'mcpServers'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'JSON' }
ClaudeRequestOptions class >> jsonKeyMap [
	^ {
		#cacheControl -> 'cache_control'.
		#serviceTier -> 'service_tier'.
		#eagerInputStreaming -> 'eager_input_streaming'.
		#betas -> 'betas'.
		#stream -> 'stream'.
		#inferenceGeo -> 'inference_geo'.
		#container -> 'container'.
		#speed -> 'speed'.
		#mcpServers -> 'mcp_servers'
	} asDictionary
]

{ #category : 'private' }
ClaudeRequestOptions >> addContainerFieldTo: dict [
	"Container slot serializes either as a String container ID (back-compat)
	 or as a ClaudeContainerParams via asJson."
	container ifNil: [ ^ self ].
	dict at: 'container' put: (container isString
		ifTrue: [ container ]
		ifFalse: [ container asJson ])
]

{ #category : 'json' }
ClaudeRequestOptions >> addFieldsTo: dict [
	"Emit each non-nil request option as a snake_case wire key into the
	 caller's wire-Dictionary. Each axis (routing, container, mcp,
	 streaming) is handled by a private helper to keep the body short
	 and the field set readable."
	metadata ifNotNil: [ dict at: 'metadata' put: metadata ].
	self addRoutingFieldsTo: dict.
	self addContainerFieldTo: dict.
	speed ifNotNil: [ dict at: 'speed' put: speed ].
	self addMcpServersTo: dict.
	(stream notNil and: [ stream ]) ifTrue: [ dict at: 'stream' put: true ]
]

{ #category : 'private' }
ClaudeRequestOptions >> addMcpServersTo: dict [
	"MCP servers serialize as an Array of asJson dictionaries."
	(mcpServers notNil and: [ mcpServers notEmpty ]) ifFalse: [ ^ self ].
	dict at: 'mcp_servers' put: (mcpServers collect: [ :s | s asJson ]) asArray
]

{ #category : 'private' }
ClaudeRequestOptions >> addRoutingFieldsTo: dict [
	"Cache, service tier, eager streaming, inference geo — request routing controls."
	cacheControl ifNotNil: [ dict at: 'cache_control' put: cacheControl ].
	serviceTier ifNotNil: [ dict at: 'service_tier' put: serviceTier ].
	eagerInputStreaming ifNotNil: [ dict at: 'eager_input_streaming' put: eagerInputStreaming ].
	inferenceGeo ifNotNil: [ dict at: 'inference_geo' put: inferenceGeo ]
]

{ #category : 'accessing' }
ClaudeRequestOptions >> betaHeader [
	"Answer the comma-joined anthropic-beta header value, or nil when no betas are set."
	self hasBetas ifFalse: [ ^ nil ].
	^ ',' join: betas
]

{ #category : 'accessing' }
ClaudeRequestOptions >> betas [
	"Answer the collection of beta feature flag strings, or nil."
	^ betas
]

{ #category : 'accessing' }
ClaudeRequestOptions >> betas: aCollection [
	"Set the beta feature flag strings. Accepts an array/collection of strings, or nil."
	betas := aCollection
]

{ #category : 'accessing' }
ClaudeRequestOptions >> cacheControl [
	^ cacheControl
]

{ #category : 'accessing' }
ClaudeRequestOptions >> cacheControl: aDictionary [
	cacheControl := aDictionary
]

{ #category : 'accessing' }
ClaudeRequestOptions >> container [
	^ container
]

{ #category : 'accessing' }
ClaudeRequestOptions >> container: aStringOrContainerParams [
	"Set the container for this request. Accepts either a plain String
	 container ID for back-compat, or a ClaudeContainerParams instance
	 to load skills into the container. Polymorphic dispatch in
	 addFieldsTo: emits each form correctly on the wire. Validate the
	 type up front so callers fail fast on misuse instead of getting a
	 doesNotUnderstand: deep inside serialization."
	(aStringOrContainerParams isNil
		or: [ aStringOrContainerParams isString
			or: [ aStringOrContainerParams isClaudeContainerParams ] ])
		ifFalse: [ self error: 'container: requires a String or ClaudeContainerParams, got: ' , aStringOrContainerParams class name ].
	container := aStringOrContainerParams
]

{ #category : 'accessing' }
ClaudeRequestOptions >> eagerInputStreaming [
	^ eagerInputStreaming
]

{ #category : 'accessing' }
ClaudeRequestOptions >> eagerInputStreaming: aBoolean [
	eagerInputStreaming := aBoolean
]

{ #category : 'testing' }
ClaudeRequestOptions >> hasBetas [
	"Answer true if at least one beta flag is set."
	^ betas notNil and: [ betas notEmpty ]
]

{ #category : 'accessing' }
ClaudeRequestOptions >> inferenceGeo [
	^ inferenceGeo
]

{ #category : 'accessing' }
ClaudeRequestOptions >> inferenceGeo: aString [
	inferenceGeo := aString
]

{ #category : 'accessing' }
ClaudeRequestOptions >> mcpServers [
	"Answer the collection of ClaudeMCPServerDefinition instances, or nil."
	^ mcpServers
]

{ #category : 'accessing' }
ClaudeRequestOptions >> mcpServers: aCollection [
	"Set the MCP server definitions for this request. Accepts a collection of
	 ClaudeMCPServerDefinition instances, or nil. An empty collection is
	 normalized to nil — empty means unset for this field, consistent with
	 the Go SDK omitzero semantic for mcp_servers."
	mcpServers := (aCollection notNil and: [ aCollection isEmpty ])
		ifTrue: [ nil ]
		ifFalse: [ aCollection ]
]

{ #category : 'accessing' }
ClaudeRequestOptions >> metadata [
	^ metadata
]

{ #category : 'accessing' }
ClaudeRequestOptions >> metadata: aDictionary [
	metadata := aDictionary
]

{ #category : 'accessing' }
ClaudeRequestOptions >> serviceTier [
	^ serviceTier
]

{ #category : 'accessing' }
ClaudeRequestOptions >> serviceTier: aString [
	serviceTier := aString
]

{ #category : 'accessing' }
ClaudeRequestOptions >> speed [
	^ speed
]

{ #category : 'accessing' }
ClaudeRequestOptions >> speed: aString [
	speed := aString
]

{ #category : 'accessing' }
ClaudeRequestOptions >> stream [
	^ stream ifNil: [ false ]
]

{ #category : 'accessing' }
ClaudeRequestOptions >> stream: aBoolean [
	stream := aBoolean ifNil: [ false ]
]
