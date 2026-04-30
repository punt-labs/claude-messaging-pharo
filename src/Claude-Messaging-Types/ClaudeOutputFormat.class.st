"
Abstract base for output format specifications in the Claude Messages API. Subclasses represent specific format types: text (default) and json_schema (structured output). Only json_schema serializes to wire JSON (response_format parameter). Text format returns nil from asJson because it is client-side only -- its constraints are injected into the system prompt.

  ClaudeOutputFormat text
  >>> a ClaudeTextOutputFormat

  ClaudeOutputFormat jsonSchema: ClaudeToolInputSchema new
  >>> a ClaudeJsonSchemaOutputFormat

"
Class {
	#name : 'ClaudeOutputFormat',
	#superclass : 'Object',
	#instVars : [
		'type'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeOutputFormat class >> jsonSchema: aClaudeToolInputSchema [
  ^ ClaudeJsonSchemaOutputFormat schema: aClaudeToolInputSchema
]

{ #category : 'instance creation' }
ClaudeOutputFormat class >> text [
  ^ ClaudeTextOutputFormat new
]

{ #category : 'json' }
ClaudeOutputFormat >> asJson [
  self subclassResponsibility
]

{ #category : 'printing' }
ClaudeOutputFormat >> printOn: aStream [
  aStream
    nextPutAll: self class name;
    nextPut: $(;
    nextPutAll: (type ifNil: [ '?' ]);
    nextPut: $)
]

{ #category : 'accessing' }
ClaudeOutputFormat >> systemPromptSuffix [
	"Polymorphic default: most output formats don't append a system-prompt
	 suffix. ClaudeTextOutputFormat overrides this when configured to inject
	 schema/style guidance. Returning nil here lets ClaudeMessageRequest>>
	 composedSystem dispatch without a respondsTo: guard."
	^ nil
]

{ #category : 'accessing' }
ClaudeOutputFormat >> type [
  ^ type
]
