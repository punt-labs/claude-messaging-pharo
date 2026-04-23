"
One MCP server entry attached to a Claude message request. Required fields: name, url. Optional: authorizationToken (bearer for the MCP server's HTTP auth), toolConfiguration (per-server allow-list and enabled flag). The type slot defaults to 'url' and is the discriminator for forward-compat when Anthropic ships additional transport variants.

This connector lets the SDK pass MCP server URLs to Claude in a Messages request. Anthropic's infrastructure makes the outbound connection to those servers and acts as the MCP client during message generation. The SDK is NOT exposing the Pharo image as an MCP server (a separate feature, not v1.0), and this is unrelated to Claude Code's own MCP runtime that hosts biff/quarry/lux.

Forward compatibility: any wire keys outside knownJsonKeys are captured into extraFields by fromJson: and re-emitted by asJson, so a fromJson:/asJson roundtrip is lossless even when Anthropic ships new transport variants. Mirrors ClaudeContentBlock's rawJson strategy.

  (ClaudeMCPServerDefinition name: 'example' url: 'https://mcp.example.com/sse') type
  >>> 'url'

  (ClaudeMCPServerDefinition name: 'example' url: 'https://mcp.example.com/sse') asJson
  >>> an OrderedDictionary('type'->'url' 'name'->'example' 'url'->'https://mcp.example.com/sse')


"
Class {
	#name : 'ClaudeMCPServerDefinition',
	#superclass : 'Object',
	#instVars : [
		'name',
		'url',
		'authorizationToken',
		'toolConfiguration',
		'type',
		'extraFields'
	],
	#category : 'Claude-Messaging-MCP',
	#package : 'Claude-Messaging-MCP'
}

{ #category : 'json' }
ClaudeMCPServerDefinition class >> fromJson: aDictionary [
	"Construct from the wire dictionary. Known fields go in dedicated slots;
	 any unknown keys are preserved in extraFields so they roundtrip back
	 through asJson, matching the forward-compat strategy ClaudeContentBlock
	 uses for unknown block types."
	| def configDict known |
	def := self new
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		url: (aDictionary at: 'url' ifAbsent: [ nil ]);
		authorizationToken: (aDictionary at: 'authorization_token' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ 'url' ]);
		yourself.
	configDict := aDictionary at: 'tool_configuration' ifAbsent: [ nil ].
	configDict ifNotNil: [
		def toolConfiguration: (ClaudeMCPToolConfiguration fromJson: configDict) ].
	known := self knownJsonKeys.
	aDictionary keysAndValuesDo: [ :k :v |
		(known includes: k) ifFalse: [ def extraFields at: k put: v ] ].
	^ def
]

{ #category : 'json' }
ClaudeMCPServerDefinition class >> jsonKeyMap [
	^ {
		#name -> 'name'.
		#url -> 'url'.
		#authorizationToken -> 'authorization_token'.
		#toolConfiguration -> 'tool_configuration'.
		#type -> 'type'
	} asDictionary
]

{ #category : 'json' }
ClaudeMCPServerDefinition class >> knownJsonKeys [
	"The snake_case wire keys this class explicitly handles. Used by fromJson:
	 to identify which entries belong in extraFields for forward-compat
	 preservation. Mirrors the values of jsonKeyMap, plus tool_configuration
	 which is wired through ClaudeMCPToolConfiguration."
	^ #('name' 'url' 'authorization_token' 'tool_configuration' 'type') asSet
]

{ #category : 'instance creation' }
ClaudeMCPServerDefinition class >> name: aName url: aUrl [
	^ self new
		name: aName;
		url: aUrl;
		yourself
]

{ #category : 'json' }
ClaudeMCPServerDefinition >> asJson [
	"Emit the wire dictionary. Known fields are emitted explicitly; any
	 forward-compat unknown fields captured by fromJson: are appended so
	 a fromJson:/asJson roundtrip is lossless. Unknown keys are emitted
	 last so the canonical type/name/url order is preserved at the head."
	| dict configJson |
	name ifNil: [ self error: 'name is required' ].
	url ifNil: [ self error: 'url is required' ].
	dict := OrderedDictionary new.
	dict at: 'type' put: (type ifNil: [ 'url' ]).
	dict at: 'name' put: name.
	dict at: 'url' put: url.
	authorizationToken ifNotNil: [
		dict at: 'authorization_token' put: authorizationToken ].
	toolConfiguration ifNotNil: [
		configJson := toolConfiguration asJson.
		configJson isEmpty ifFalse: [
			dict at: 'tool_configuration' put: configJson ] ].
	extraFields ifNotNil: [
		extraFields keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	^ dict
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> authorizationToken [
	^ authorizationToken
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> authorizationToken: aString [
	authorizationToken := aString
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> extraFields [
	"Answer the dictionary of forward-compat unknown JSON fields captured
	 by fromJson:. Empty by default; never nil after initialize."
	^ extraFields
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> extraFields: aDictionary [
	"Set the forward-compat unknown JSON fields. Mainly for fromJson: and
	 tests; production code does not call this directly."
	extraFields := aDictionary
]

{ #category : 'initialization' }
ClaudeMCPServerDefinition >> initialize [
	super initialize.
	type := 'url'.
	extraFields := Dictionary new
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> name [
	^ name
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> name: aString [
	name := aString
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> toolConfiguration [
	^ toolConfiguration
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> toolConfiguration: aConfig [
	toolConfiguration := aConfig
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> type: aString [
	type := aString
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> url [
	^ url
]

{ #category : 'accessing' }
ClaudeMCPServerDefinition >> url: aString [
	url := aString
]
