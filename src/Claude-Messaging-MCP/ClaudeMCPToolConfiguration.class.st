"
Per-server tool configuration sent in mcp_servers entries. Holds an enabled flag (nil means server default) and an optional allow-list of tool names. Serialized to JSON as {enabled, allowed_tools}.

Forward compatibility: any wire keys outside knownJsonKeys are captured into extraFields by fromJson: and re-emitted by asJson, so a fromJson:/asJson roundtrip is lossless even when Anthropic ships new per-server tool configuration fields. Mirrors the same strategy used by ClaudeMCPServerDefinition.

  ClaudeMCPToolConfiguration new enabled: true; allowedTools: #('echo' 'add'); allowedTools
  >>> #('echo' 'add')

  (ClaudeMCPToolConfiguration enabled: true allowedTools: #('echo')) asJson
  >>> an OrderedDictionary('enabled'->true 'allowed_tools'->#('echo'))


"
Class {
	#name : 'ClaudeMCPToolConfiguration',
	#superclass : 'Object',
	#instVars : [
		'enabled',
		'allowedTools',
		'extraFields'
	],
	#category : 'Claude-Messaging-MCP',
	#package : 'Claude-Messaging-MCP'
}

{ #category : 'instance creation' }
ClaudeMCPToolConfiguration class >> enabled: aBoolean allowedTools: aCollection [
	^ self new
		enabled: aBoolean;
		allowedTools: aCollection;
		yourself
]

{ #category : 'json' }
ClaudeMCPToolConfiguration class >> fromJson: aDictionary [
	"Construct from the wire dictionary. Known fields go in dedicated slots;
	 any unknown keys are preserved in extraFields so they roundtrip back
	 through asJson, matching the forward-compat strategy ClaudeMCPServerDefinition
	 uses on its parent dict."
	| config known |
	config := self new
		enabled: (aDictionary at: 'enabled' ifAbsent: [ nil ]);
		allowedTools: (aDictionary at: 'allowed_tools' ifAbsent: [ nil ]);
		yourself.
	known := self knownJsonKeys.
	aDictionary keysAndValuesDo: [ :k :v |
		(known includes: k) ifFalse: [ config extraFields at: k put: v ] ].
	^ config
]

{ #category : 'json' }
ClaudeMCPToolConfiguration class >> jsonKeyMap [
	^ {
		#enabled -> 'enabled'.
		#allowedTools -> 'allowed_tools'
	} asDictionary
]

{ #category : 'json' }
ClaudeMCPToolConfiguration class >> knownJsonKeys [
	"The snake_case wire keys this class explicitly handles. Used by fromJson:
	 to identify which entries belong in extraFields for forward-compat
	 preservation. Mirrors the values of jsonKeyMap."
	^ #('enabled' 'allowed_tools') asSet
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> allowedTools [
	^ allowedTools
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> allowedTools: aCollection [
	allowedTools := aCollection
]

{ #category : 'json' }
ClaudeMCPToolConfiguration >> asJson [
	"Emit the wire dictionary. Known fields are emitted explicitly; any
	 forward-compat unknown fields captured by fromJson: are appended so
	 a fromJson:/asJson roundtrip is lossless. Unknown keys are emitted
	 last so the canonical enabled/allowed_tools order is preserved at the head."
	| dict |
	dict := OrderedDictionary new.
	enabled ifNotNil: [ dict at: 'enabled' put: enabled ].
	allowedTools ifNotNil: [
		dict at: 'allowed_tools' put: allowedTools asArray ].
	extraFields ifNotNil: [
		extraFields keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	^ dict
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> enabled [
	^ enabled
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> enabled: aBoolean [
	enabled := aBoolean
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> extraFields [
	"Answer the dictionary of forward-compat unknown JSON fields captured
	 by fromJson:. Empty by default; never nil after initialize."
	^ extraFields
]

{ #category : 'accessing' }
ClaudeMCPToolConfiguration >> extraFields: aDictionary [
	"Set the forward-compat unknown JSON fields. Mainly for fromJson: and
	 tests; production code does not call this directly."
	extraFields := aDictionary
]

{ #category : 'initialization' }
ClaudeMCPToolConfiguration >> initialize [
	super initialize.
	extraFields := Dictionary new
]
