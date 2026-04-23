"
Tests for ClaudeOutputFormat hierarchy -- text and json_schema output formats.
"
Class {
	#name : 'ClaudeOutputFormatTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeOutputFormatTest >> testJsonSchemaOutputFormatAsJson [
  | schema fmt json schemaJson |
  schema := ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Name';
    require: 'name'.
  fmt := ClaudeJsonSchemaOutputFormat schema: schema.
  json := fmt asJson.
  self assert: (json at: 'type') equals: 'json_schema'.
  schemaJson := json at: 'schema'.
  self assert: (schemaJson at: 'type') equals: 'object'.
  self assert: ((schemaJson at: 'properties') includesKey: 'name').
  self assert: (schemaJson at: 'required') asArray equals: #('name')
]

{ #category : 'tests' }
ClaudeOutputFormatTest >> testJsonSchemaOutputFormatPrintOn [
  | schema fmt |
  schema := ClaudeToolInputSchema new.
  fmt := ClaudeJsonSchemaOutputFormat schema: schema.
  self assert: fmt printString equals: 'ClaudeJsonSchemaOutputFormat(json_schema)'
]

{ #category : 'tests' }
ClaudeOutputFormatTest >> testOutputFormatJsonSchemaFactory [
  | schema fmt |
  schema := ClaudeToolInputSchema new.
  fmt := ClaudeOutputFormat jsonSchema: schema.
  self assert: (fmt isKindOf: ClaudeJsonSchemaOutputFormat).
  self assert: fmt type equals: 'json_schema'
]

{ #category : 'tests' }
ClaudeOutputFormatTest >> testOutputFormatTextFactory [
  | fmt |
  fmt := ClaudeOutputFormat text.
  self assert: (fmt isKindOf: ClaudeTextOutputFormat).
  self assert: fmt type equals: 'text'
]

{ #category : 'tests' }
ClaudeOutputFormatTest >> testTextOutputFormatAsJson [
  "Text format is client-side only. It must not serialize to JSON — the API rejects type=text."
  self assert: ClaudeTextOutputFormat new asJson isNil
]
