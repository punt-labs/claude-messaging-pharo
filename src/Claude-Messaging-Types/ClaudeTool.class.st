"
Tool definition for Claude API requests. Contains the tool name, description, input schema, and optional cache control. Serializes to the format expected by the Messages API tools parameter.

### Examples

```
| tool |
tool := ClaudeTool name: 'test' description: 'A test tool' inputSchema: ClaudeToolInputSchema new.
tool name
>>> 'test'
```

"
Class {
	#name : 'ClaudeTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'description',
		'inputSchema',
		'cacheControl',
		'strict'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeTool class >> fromJson: aDictionary [
	^ self new
		populateFromJson: aDictionary;
		yourself
]

{ #category : 'json' }
ClaudeTool class >> jsonKeyMap [
	^ {
		#inputSchema -> 'input_schema'.
		#cacheControl -> 'cache_control'.
		#strict -> 'strict'
	} asDictionary
]

{ #category : 'instance creation' }
ClaudeTool class >> name: aName description: aDescription inputSchema: aSchema [
	^ self new
		name: aName;
		description: aDescription;
		inputSchema: aSchema;
		yourself
]

{ #category : 'json' }
ClaudeTool >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'name' put: name.
	dict at: 'description' put: description.
	dict at: 'input_schema' put: inputSchema asJson.
	cacheControl ifNotNil: [ dict at: 'cache_control' put: cacheControl ].
	strict ifNotNil: [ dict at: 'strict' put: strict ].
	^ dict
]

{ #category : 'accessing' }
ClaudeTool >> cacheControl [
	^ cacheControl
]

{ #category : 'accessing' }
ClaudeTool >> cacheControl: aDictionary [
	cacheControl := aDictionary
]

{ #category : 'accessing' }
ClaudeTool >> description [
	^ description
]

{ #category : 'accessing' }
ClaudeTool >> description: aString [
	description := aString
]

{ #category : 'accessing' }
ClaudeTool >> inputSchema [
	^ inputSchema
]

{ #category : 'accessing' }
ClaudeTool >> inputSchema: aClaudeToolInputSchema [
	inputSchema := aClaudeToolInputSchema
]

{ #category : 'accessing' }
ClaudeTool >> name [
	^ name
]

{ #category : 'accessing' }
ClaudeTool >> name: aString [
	name := aString
]

{ #category : 'json' }
ClaudeTool >> populateFromJson: aDictionary [
	name := aDictionary at: 'name' ifAbsent: [ nil ].
	description := aDictionary at: 'description' ifAbsent: [ nil ].
	(aDictionary at: 'input_schema' ifAbsent: [ nil ])
		ifNotNil: [ :s | inputSchema := ClaudeToolInputSchema fromJson: s ].
	cacheControl := aDictionary at: 'cache_control' ifAbsent: [ nil ].
	strict := aDictionary at: 'strict' ifAbsent: [ nil ]
]

{ #category : 'printing' }
ClaudeTool >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeTool(';
		nextPutAll: (name ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeTool >> strict [
	^ strict
]

{ #category : 'accessing' }
ClaudeTool >> strict: aBoolean [
	strict := aBoolean
]
