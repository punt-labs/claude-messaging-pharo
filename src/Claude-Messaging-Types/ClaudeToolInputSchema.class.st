"
JSON Schema definition for tool input parameters and structured output schemas. Supports flat object schemas via the builder pattern, nested schemas via addProperty:schema: and items:, and arbitrary JSON Schema keywords via schemaField:put: or fromJson:. The type defaults to 'object' for backward compatibility with tool definitions.

  ClaudeToolInputSchema new
    addProperty: 'city' type: 'string' description: 'City name';
    properties size
  >>> 1

  ClaudeToolInputSchema new type: 'array'; type
  >>> 'array'

  (ClaudeToolInputSchema new
    addProperty: 'x' type: 'integer' description: 'A number';
    asJson) at: 'type'
  >>> 'object'

"
Class {
	#name : 'ClaudeToolInputSchema',
	#superclass : 'Object',
	#instVars : [
		'properties',
		'required',
		'type',
		'description',
		'extraFields'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeToolInputSchema class >> fromJson: aDictionary [
	^ self new
		populateFromJson: aDictionary;
		yourself
]

{ #category : 'building' }
ClaudeToolInputSchema >> addProperty: aName schema: aClaudeToolInputSchema [
  properties at: aName put: aClaudeToolInputSchema
]

{ #category : 'building' }
ClaudeToolInputSchema >> addProperty: aName type: aType description: aDescription [
	| prop |
	prop := OrderedDictionary new.
	prop at: 'type' put: aType.
	prop at: 'description' put: aDescription.
	properties at: aName put: prop
]

{ #category : 'building' }
ClaudeToolInputSchema >> addProperty: aName type: aType description: aDescription enum: anArray [
	| prop |
	prop := OrderedDictionary new.
	prop at: 'type' put: aType.
	prop at: 'description' put: aDescription.
	prop at: 'enum' put: anArray asArray.
	properties at: aName put: prop
]

{ #category : 'building' }
ClaudeToolInputSchema >> additionalProperties: aBoolean [
  extraFields at: 'additionalProperties' put: aBoolean
]

{ #category : 'json' }
ClaudeToolInputSchema >> asJson [
  | dict serializedProps |
  dict := OrderedDictionary new.
  dict at: 'type' put: type.
  description ifNotNil: [ dict at: 'description' put: description ].
  (type = 'object' or: [ properties notEmpty ])
    ifTrue: [
      serializedProps := OrderedDictionary new.
      properties keysAndValuesDo: [ :k :v |
        serializedProps at: k put: (v class == self class ifTrue: [ v asJson ] ifFalse: [ v ]) ].
      dict at: 'properties' put: serializedProps ].
  required ifNotEmpty: [ dict at: 'required' put: required asArray ].
  extraFields keysAndValuesDo: [ :k :v |
    dict at: k put: (v class == self class ifTrue: [ v asJson ] ifFalse: [ v ]) ].
  ^ dict
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> description [
  ^ description
]

{ #category : 'building' }
ClaudeToolInputSchema >> description: aString [
  description := aString
]

{ #category : 'building' }
ClaudeToolInputSchema >> ensureAdditionalPropertiesFalse [
  "Recursively set additionalProperties: false on this and all nested object schemas."
  type = 'object' ifTrue: [
    (extraFields includesKey: 'additionalProperties')
      ifFalse: [ self additionalProperties: false ] ].
  properties valuesDo: [ :prop |
    prop class == self class
      ifTrue: [ prop ensureAdditionalPropertiesFalse ] ].
  (extraFields at: 'items' ifAbsent: [ nil ]) ifNotNil: [ :itemsSchema |
    itemsSchema class == self class
      ifTrue: [ itemsSchema ensureAdditionalPropertiesFalse ] ]
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> extraFields [
  ^ extraFields
]

{ #category : 'initialization' }
ClaudeToolInputSchema >> initialize [
  properties := OrderedDictionary new.
  required := OrderedCollection new.
  type := 'object'.
  extraFields := OrderedDictionary new
]

{ #category : 'building' }
ClaudeToolInputSchema >> items: aClaudeToolInputSchema [
  extraFields at: 'items' put: aClaudeToolInputSchema
]

{ #category : 'json' }
ClaudeToolInputSchema >> populateFromJson: aDictionary [
  | known |
  known := #('type' 'description' 'properties' 'required').
  type := aDictionary at: 'type' ifAbsent: [ 'object' ].
  description := aDictionary at: 'description' ifAbsent: [ nil ].
  (aDictionary at: 'properties' ifAbsent: [ nil ])
    ifNotNil: [ :p | p keysAndValuesDo: [ :k :v | properties at: k put: v ] ].
  required addAll: (aDictionary at: 'required' ifAbsent: [ #() ]).
  aDictionary keysAndValuesDo: [ :k :v |
    (known includes: k) ifFalse: [ extraFields at: k put: v ] ]
]

{ #category : 'copying' }
ClaudeToolInputSchema >> postCopy [
  super postCopy.
  properties := properties copy.
  required := required copy.
  extraFields := extraFields copy
]

{ #category : 'printing' }
ClaudeToolInputSchema >> printOn: aStream [
  aStream
    nextPutAll: 'ClaudeToolInputSchema(';
    nextPutAll: type;
    nextPutAll: ', ';
    print: properties size;
    nextPutAll: ' props';
    nextPut: $)
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> properties [
	^ properties
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> properties: anOrderedDictionary [
	properties := anOrderedDictionary
]

{ #category : 'building' }
ClaudeToolInputSchema >> require: aPropertyName [
	required add: aPropertyName
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> required [
	^ required
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> required: anOrderedCollection [
	required := anOrderedCollection
]

{ #category : 'building' }
ClaudeToolInputSchema >> schemaField: aKey put: aValue [
  "Set an arbitrary JSON Schema keyword. Known keys are routed
  through their dedicated setters to keep internal state consistent."
  aKey = 'type' ifTrue: [ ^ self type: aValue ].
  aKey = 'description' ifTrue: [ ^ self description: aValue ].
  aKey = 'properties' ifTrue: [ ^ self properties: aValue ].
  aKey = 'required' ifTrue: [ ^ self required: aValue ].
  extraFields at: aKey put: aValue
]

{ #category : 'accessing' }
ClaudeToolInputSchema >> type [
  ^ type
]

{ #category : 'building' }
ClaudeToolInputSchema >> type: aString [
  type := aString
]
