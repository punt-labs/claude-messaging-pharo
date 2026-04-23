"
Tests for ClaudeOutputConfig -- effort level and output format serialization.
"
Class {
	#name : 'ClaudeOutputConfigTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeOutputConfigTest >> testAsJsonOmitsOutputConfigWhenEmpty [
  | req json |
  req := ClaudeMessageRequest new
    model: 'claude-sonnet-4-20250514';
    maxTokens: 100;
    addUserMessage: 'Hi'.
  json := req asJson.
  self deny: (json includesKey: 'output_config')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testAsJsonWithEffort [
  | req json oc |
  req := ClaudeMessageRequest new
    model: 'claude-sonnet-4-20250514';
    maxTokens: 100;
    effort: 'high';
    addUserMessage: 'Hi'.
  json := req asJson.
  oc := json at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'high'.
  self deny: (oc includesKey: 'format')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testAsJsonWithEffortAndJsonSchema [
  | schema req json oc |
  schema := ClaudeToolInputSchema new
    addProperty: 'x' type: 'integer' description: 'Value'.
  req := ClaudeMessageRequest new
    model: 'claude-sonnet-4-20250514';
    maxTokens: 100;
    effort: 'max';
    jsonSchema: schema;
    addUserMessage: 'Hi'.
  json := req asJson.
  oc := json at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'max'.
  self assert: ((oc at: 'format') at: 'type') equals: 'json_schema'
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testAsJsonWithJsonSchema [
	| schema req json oc fmt |
	schema := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'Name';
		require: 'name';
		yourself.
	req := ClaudeMessageRequest new
		model: 'claude-sonnet-4-20250514';
		maxTokens: 100;
		jsonSchema: schema;
		addUserMessage: 'Hi'.
	json := req asJson.
	oc := json at: 'output_config'.
	self deny: (oc includesKey: 'effort').
	fmt := oc at: 'format'.
	self assert: (fmt at: 'type') equals: 'json_schema'.
	self assert: ((fmt at: 'schema') at: 'type') equals: 'object'.
	self assert: ((fmt at: 'schema') at: 'required') asArray equals: #('name')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testAsJsonWithXhighEffort [
  | req json oc |
  req := ClaudeMessageRequest new
    model: 'claude-opus-4-7';
    maxTokens: 100;
    effort: 'xhigh';
    addUserMessage: 'Hi'.
  json := req asJson.
  oc := json at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'xhigh'.
  self deny: (oc includesKey: 'format')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testConvenienceEffortFactory [
  | config |
  config := ClaudeOutputConfig effort: 'low'.
  self assert: (config isKindOf: ClaudeOutputConfig).
  self assert: config effort equals: 'low'.
  self assert: config format isNil
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testConvenienceJsonSchemaFactory [
	| schema config |
	schema := ClaudeToolInputSchema new
		addProperty: 'x' type: 'integer' description: 'Value';
		yourself.
	config := ClaudeOutputConfig jsonSchema: schema.
	self assert: (config isKindOf: ClaudeOutputConfig).
	self assert: config effort isNil.
	self assert: (config format isKindOf: ClaudeJsonSchemaOutputFormat)
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testEffortAndFormatConfig [
  | schema config dict oc |
  schema := ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Name'.
  config := ClaudeOutputConfig effort: 'max' jsonSchema: schema.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  oc := dict at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'max'.
  self assert: ((oc at: 'format') at: 'type') equals: 'json_schema'
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testEffortOnlyConfig [
  | config dict oc |
  config := ClaudeOutputConfig effort: 'high'.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  oc := dict at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'high'.
  self deny: (oc includesKey: 'format')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testEmptyConfigOmitsOutputConfig [
  | config dict |
  config := ClaudeOutputConfig new.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  self deny: (dict includesKey: 'output_config')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testFormatOnlyConfig [
  | schema config dict oc fmt |
  schema := ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Name'.
  config := ClaudeOutputConfig jsonSchema: schema.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  oc := dict at: 'output_config'.
  self deny: (oc includesKey: 'effort').
  fmt := oc at: 'format'.
  self assert: (fmt at: 'type') equals: 'json_schema'.
  self assert: ((fmt at: 'schema') at: 'type') equals: 'object'
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaAutoSetsAdditionalProperties [
	| schema req json oc schemaJson |
	schema := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'test';
		require: 'name'.
	req := ClaudeMessageRequest new
		model: 'test'; maxTokens: 100;
		jsonSchema: schema.
	json := req asJson.
	oc := json at: 'output_config'.
	schemaJson := (oc at: 'format') at: 'schema'.
	self assert: (schemaJson at: 'additionalProperties') equals: false
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaItemsAdditionalProperties [
	| itemSchema arraySchema req json oc schemaJson itemsJson |
	itemSchema := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'Name'.
	arraySchema := ClaudeToolInputSchema new
		type: 'array';
		items: itemSchema.
	req := ClaudeMessageRequest new
		model: 'test'; maxTokens: 100;
		jsonSchema: arraySchema.
	json := req asJson.
	oc := json at: 'output_config'.
	schemaJson := (oc at: 'format') at: 'schema'.
	itemsJson := schemaJson at: 'items'.
	self deny: (schemaJson includesKey: 'additionalProperties').
	self assert: (itemsJson at: 'additionalProperties') equals: false
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaNestedAdditionalProperties [
	| inner outer req json oc schemaJson nestedJson |
	inner := ClaudeToolInputSchema new
		addProperty: 'street' type: 'string' description: 'Street';
		require: 'street'.
	outer := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'Name';
		addProperty: 'address' schema: inner;
		require: 'name'.
	req := ClaudeMessageRequest new
		model: 'test'; maxTokens: 100;
		jsonSchema: outer.
	json := req asJson.
	oc := json at: 'output_config'.
	schemaJson := (oc at: 'format') at: 'schema'.
	nestedJson := (schemaJson at: 'properties') at: 'address'.
	self assert: (schemaJson at: 'additionalProperties') equals: false.
	self assert: (nestedJson at: 'additionalProperties') equals: false.
	"Original schema is not mutated"
	self deny: (outer extraFields includesKey: 'additionalProperties')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaNoAdditionalPropertiesForNonObject [
	| schema req json oc schemaJson |
	schema := ClaudeToolInputSchema new type: 'string'.
	req := ClaudeMessageRequest new
		model: 'test'; maxTokens: 100;
		jsonSchema: schema.
	json := req asJson.
	oc := json at: 'output_config'.
	schemaJson := (oc at: 'format') at: 'schema'.
	self deny: (schemaJson includesKey: 'additionalProperties')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaPreservesExplicitAdditionalProperties [
	| schema req json oc schemaJson |
	schema := ClaudeToolInputSchema new
		addProperty: 'name' type: 'string' description: 'test';
		additionalProperties: true.
	req := ClaudeMessageRequest new
		model: 'test'; maxTokens: 100;
		jsonSchema: schema.
	json := req asJson.
	oc := json at: 'output_config'.
	schemaJson := (oc at: 'format') at: 'schema'.
	self assert: (schemaJson at: 'additionalProperties') equals: true
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testJsonSchemaViaToolInputSchema [
  | schema tool req json oc toolJson |
  schema := ClaudeToolInputSchema new
    addProperty: 'city' type: 'string' description: 'City name';
    addProperty: 'temperature' type: 'number' description: 'Temp in C';
    require: 'city'; require: 'temperature'.
  tool := ClaudeTool name: 'GetWeather' description: 'Get weather' inputSchema: schema.
  req := ClaudeMessageRequest new
    model: 'claude-sonnet-4-20250514';
    maxTokens: 100;
    jsonSchema: schema;
    addUserMessage: 'Hi'.
  req tools: (OrderedCollection with: tool).
  json := req asJson.
  toolJson := (json at: 'tools') first at: 'input_schema'.
  oc := json at: 'output_config'.
  self assert: (toolJson at: 'type') equals: 'object'.
  self assert: (toolJson at: 'required') asArray equals: #('city' 'temperature').
  self assert: ((oc at: 'format') at: 'type') equals: 'json_schema'.
  self assert: (((oc at: 'format') at: 'schema') at: 'required') asArray equals: #('city' 'temperature')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testTextFormatOmitsOutputConfig [
  "Text format is client-side only. A config with only text format should not emit output_config."
  | config dict |
  config := ClaudeOutputConfig new.
  config format: ClaudeTextOutputFormat pharoDefault.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  self deny: (dict includesKey: 'output_config')
]

{ #category : 'tests' }
ClaudeOutputConfigTest >> testXhighEffortSerialization [
  | config dict oc |
  config := ClaudeOutputConfig effort: 'xhigh'.
  dict := OrderedDictionary new.
  config addFieldsTo: dict.
  oc := dict at: 'output_config'.
  self assert: (oc at: 'effort') equals: 'xhigh'.
  self deny: (oc includesKey: 'format')
]
