"
Abstract base class for server-side tools in the Claude Messages API. Server tools are tools that Anthropic runs on its servers. Users add them to the tools[] array in a request. Claude invokes them during a conversation turn and returns results as content blocks in the response.

Server tools differ from user-defined tools (ClaudeTool): they have a fixed type and name (no description, no input_schema), and tool-specific config params. Both go into the same tools[] array and both respond to asJson.

Each concrete subclass sets defaultType and defaultName on the class side. Users can override the version string on individual instances.

### Examples

Concrete subclasses set defaultType and defaultName:
  MyTool new asJson
  ""produces an OrderedDictionary with type and name keys""

Verify asJson returns an OrderedDictionary:
  ClaudeServerTool new asJson class name
  >>> #OrderedDictionary

"
Class {
	#name : 'ClaudeServerTool',
	#superclass : 'Object',
	#instVars : [
		'toolType',
		'toolName',
		'cacheControl',
		'deferLoading',
		'strict',
		'allowedCallers',
		'inputExamples',
		'maxUses',
		'allowedDomains',
		'blockedDomains',
		'citations'
	],
	#classVars : [
		'TypeRegistry'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeServerTool class >> defaultName [
	"Answer the default API name for this tool type. Subclasses override."
	^ ''
]

{ #category : 'class initialization' }
ClaudeServerTool class >> defaultType [
	"Answer the default API type string for this tool. Subclasses override."
	^ ''
]

{ #category : 'instance creation' }
ClaudeServerTool class >> fromJson: aDictionary [
	"Reconstruct a server tool from a JSON dictionary. Dispatches on the name field (stable across versions), not the type field (version-specific). Returns nil for unknown names."
	| toolName cls |
	toolName := aDictionary at: 'name' ifAbsent: [ ^ nil ].
	cls := self typeRegistry at: toolName ifAbsent: [ ^ nil ].
	^ cls new populateFromJson: aDictionary; yourself
]

{ #category : 'class initialization' }
ClaudeServerTool class >> initialize [
  "Name-keyed registry. Concrete subclasses register themselves here."
  TypeRegistry ifNil: [ TypeRegistry := Dictionary new ]
]

{ #category : 'json' }
ClaudeServerTool class >> jsonKeyMap [
  ^ {
    #toolType -> 'type'.
    #toolName -> 'name'.
    #cacheControl -> 'cache_control'.
    #deferLoading -> 'defer_loading'.
    #strict -> 'strict'.
    #allowedCallers -> 'allowed_callers'.
    #inputExamples -> 'input_examples'.
    #maxUses -> 'max_uses'.
    #allowedDomains -> 'allowed_domains'.
    #blockedDomains -> 'blocked_domains'.
    #citations -> 'citations'
  } asDictionary
]

{ #category : 'registration' }
ClaudeServerTool class >> registerType: aName forClass: aClass [
	"Register a concrete server tool class for the given API name."
	TypeRegistry ifNil: [ TypeRegistry := Dictionary new ].
	TypeRegistry at: aName put: aClass
]

{ #category : 'accessing' }
ClaudeServerTool class >> typeRegistry [
	"Answer the type registry dictionary. For testing and introspection."
	TypeRegistry ifNil: [ TypeRegistry := Dictionary new ].
	^ TypeRegistry
]

{ #category : 'json - private' }
ClaudeServerTool >> addBaseFieldsTo: dict [
	"Add shared fields. Subclasses should NOT override this."
	deferLoading ifNotNil: [ dict at: 'defer_loading' put: deferLoading ].
	strict ifNotNil: [ dict at: 'strict' put: strict ].
	allowedCallers ifNotNil: [ dict at: 'allowed_callers' put: allowedCallers asArray ].
	inputExamples ifNotNil: [ dict at: 'input_examples' put: inputExamples asArray ].
	cacheControl ifNotNil: [ dict at: 'cache_control' put: cacheControl asJson ]
]

{ #category : 'json - private' }
ClaudeServerTool >> addConfigFieldsTo: dict [
  "Add shared config fields for server tools. Subclasses call super then add their own."
  maxUses ifNotNil: [ dict at: 'max_uses' put: maxUses ].
  allowedDomains ifNotNil: [ dict at: 'allowed_domains' put: allowedDomains asArray ].
  blockedDomains ifNotNil: [ dict at: 'blocked_domains' put: blockedDomains asArray ].
  citations ifNotNil: [ dict at: 'citations' put: citations ]
]

{ #category : 'accessing' }
ClaudeServerTool >> allowedCallers [
	^ allowedCallers
]

{ #category : 'accessing' }
ClaudeServerTool >> allowedCallers: aCollection [
	allowedCallers := aCollection
]

{ #category : 'accessing' }
ClaudeServerTool >> allowedDomains [
  ^ allowedDomains
]

{ #category : 'accessing' }
ClaudeServerTool >> allowedDomains: aCollection [
  allowedDomains := aCollection
]

{ #category : 'json' }
ClaudeServerTool >> asJson [
	"Serialize to an OrderedDictionary for the API request body."
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: toolType.
	dict at: 'name' put: toolName.
	self addBaseFieldsTo: dict.
	self addConfigFieldsTo: dict.
	^ dict
]

{ #category : 'accessing' }
ClaudeServerTool >> blockedDomains [
  ^ blockedDomains
]

{ #category : 'accessing' }
ClaudeServerTool >> blockedDomains: aCollection [
  blockedDomains := aCollection
]

{ #category : 'accessing' }
ClaudeServerTool >> cacheControl [
	^ cacheControl
]

{ #category : 'accessing' }
ClaudeServerTool >> cacheControl: aClaudeCacheControl [
	cacheControl := aClaudeCacheControl
]

{ #category : 'accessing' }
ClaudeServerTool >> citations [
  ^ citations
]

{ #category : 'accessing' }
ClaudeServerTool >> citations: aDictionary [
  citations := aDictionary
]

{ #category : 'accessing' }
ClaudeServerTool >> deferLoading [
	^ deferLoading
]

{ #category : 'accessing' }
ClaudeServerTool >> deferLoading: aBoolean [
	deferLoading := aBoolean
]

{ #category : 'initialization' }
ClaudeServerTool >> initialize [
	toolType := self class defaultType.
	toolName := self class defaultName
]

{ #category : 'accessing' }
ClaudeServerTool >> inputExamples [
	^ inputExamples
]

{ #category : 'accessing' }
ClaudeServerTool >> inputExamples: aCollection [
	inputExamples := aCollection
]

{ #category : 'accessing' }
ClaudeServerTool >> maxUses [
  ^ maxUses
]

{ #category : 'accessing' }
ClaudeServerTool >> maxUses: anInteger [
  maxUses := anInteger
]

{ #category : 'private' }
ClaudeServerTool >> populateDomainAndCitationsFrom: aDictionary [
	"Allow/block domains and citations."
	allowedDomains := aDictionary at: 'allowed_domains' ifAbsent: [ nil ].
	blockedDomains := aDictionary at: 'blocked_domains' ifAbsent: [ nil ].
	citations := aDictionary at: 'citations' ifAbsent: [ nil ]
]

{ #category : 'private' }
ClaudeServerTool >> populateFlagsFrom: aDictionary [
	"Boolean / list flags — defer_loading, strict, allowed_callers, input_examples, max_uses."
	deferLoading := aDictionary at: 'defer_loading' ifAbsent: [ nil ].
	strict := aDictionary at: 'strict' ifAbsent: [ nil ].
	allowedCallers := aDictionary at: 'allowed_callers' ifAbsent: [ nil ].
	inputExamples := aDictionary at: 'input_examples' ifAbsent: [ nil ].
	maxUses := aDictionary at: 'max_uses' ifAbsent: [ nil ]
]

{ #category : 'json' }
ClaudeServerTool >> populateFromJson: aDictionary [
	"Restore state from a JSON dictionary."
	self populateIdentityFrom: aDictionary.
	self populateFlagsFrom: aDictionary.
	(aDictionary at: 'cache_control' ifAbsent: [ nil ])
		ifNotNil: [ :cc | cacheControl := ClaudeCacheControl fromJson: cc ].
	self populateDomainAndCitationsFrom: aDictionary
]

{ #category : 'private' }
ClaudeServerTool >> populateIdentityFrom: aDictionary [
	"Identity slots — type and name."
	toolType := aDictionary at: 'type' ifAbsent: [ toolType ].
	toolName := aDictionary at: 'name' ifAbsent: [ toolName ]
]

{ #category : 'printing' }
ClaudeServerTool >> printOn: aStream [
  aStream
    nextPutAll: 'a ';
    nextPutAll: self class name;
    nextPut: $(;
    nextPutAll: (toolName ifNil: [ '?' ] ifNotNil: [ :n | n ifEmpty: [ '?' ] ]);
    nextPut: $)
]

{ #category : 'accessing' }
ClaudeServerTool >> strict [
	^ strict
]

{ #category : 'accessing' }
ClaudeServerTool >> strict: aBoolean [
	strict := aBoolean
]

{ #category : 'accessing' }
ClaudeServerTool >> toolName [
	^ toolName
]

{ #category : 'accessing' }
ClaudeServerTool >> toolName: aString [
	toolName := aString
]

{ #category : 'accessing' }
ClaudeServerTool >> toolType [
	^ toolType
]

{ #category : 'accessing' }
ClaudeServerTool >> toolType: aString [
	toolType := aString
]
