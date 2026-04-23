"
JSON schema output format for Claude API structured output. Forces Claude to return valid JSON matching the provided schema. The schema slot holds a ClaudeToolInputSchema instance.

  | fmt |
  fmt := ClaudeJsonSchemaOutputFormat schema: (ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Name').
  (fmt asJson at: 'type')
  >>> 'json_schema'

"
Class {
	#name : 'ClaudeJsonSchemaOutputFormat',
	#superclass : 'ClaudeOutputFormat',
	#instVars : [
		'schema'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeJsonSchemaOutputFormat class >> schema: aClaudeToolInputSchema [
  ^ self new schema: aClaudeToolInputSchema; yourself
]

{ #category : 'json' }
ClaudeJsonSchemaOutputFormat >> asJson [
  ^ OrderedDictionary new
      at: 'type' put: 'json_schema';
      at: 'schema' put: schema asJson;
      yourself
]

{ #category : 'initialization' }
ClaudeJsonSchemaOutputFormat >> initialize [
  type := 'json_schema'
]

{ #category : 'accessing' }
ClaudeJsonSchemaOutputFormat >> schema [
  ^ schema
]

{ #category : 'accessing' }
ClaudeJsonSchemaOutputFormat >> schema: aClaudeToolInputSchema [
  schema := aClaudeToolInputSchema copy.
  schema ensureAdditionalPropertiesFalse
]
