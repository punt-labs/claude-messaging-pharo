"
Tests for ClaudeTool and ClaudeToolInputSchema — builder pattern, JSON serialization, round-trip fidelity.
"
Class {
	#name : 'ClaudeToolTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeToolTest >> testSchemaAdditionalProperties [
  | schema json |
  schema := ClaudeToolInputSchema new
    additionalProperties: false.
  json := schema asJson.
  self assert: (json at: 'additionalProperties') equals: false
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaAdditionalPropertiesRoundTrip [
  | schema json restored restoredJson |
  schema := ClaudeToolInputSchema new
    additionalProperties: false.
  json := schema asJson.
  restored := ClaudeToolInputSchema fromJson: json.
  restoredJson := restored asJson.
  self assert: (restoredJson at: 'additionalProperties') equals: false
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaArrayWithItems [
  | schema itemSchema json |
  itemSchema := ClaudeToolInputSchema new
    addProperty: 'source' type: 'string' description: 'Source code';
    addProperty: 'protocol' type: 'string' description: 'Protocol';
    require: 'source'; require: 'protocol'.
  schema := ClaudeToolInputSchema new
    type: 'array';
    items: itemSchema.
  json := schema asJson.
  self assert: (json at: 'type') equals: 'array'.
  self assert: ((json at: 'items') at: 'type') equals: 'object'.
  self assert: (((json at: 'items') at: 'properties') includesKey: 'source').
  self assert: ((json at: 'items') at: 'required') asArray equals: #('source' 'protocol')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaAsJson [
	| schema json |
	schema := ClaudeToolInputSchema new
		addProperty: 'x' type: 'integer' description: 'A number';
		yourself.
	json := schema asJson.
	self assert: (json at: 'type') equals: 'object'.
	self assert: (json includesKey: 'properties').
	self deny: (json includesKey: 'required')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaBuilder [
	| schema |
	schema := ClaudeToolInputSchema new
		addProperty: 'city' type: 'string' description: 'City name';
		addProperty: 'country' type: 'string' description: 'Country code';
		require: 'city';
		yourself.
	self assert: schema properties size equals: 2.
	self assert: (schema properties includesKey: 'city').
	self assert: (schema properties includesKey: 'country').
	self assert: schema required asArray equals: #('city')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaCustomType [
  | schema json |
  schema := ClaudeToolInputSchema new type: 'array'.
  json := schema asJson.
  self assert: (json at: 'type') equals: 'array'.
  self deny: (json includesKey: 'properties')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaDefaultType [
  | schema |
  schema := ClaudeToolInputSchema new.
  self assert: schema type equals: 'object'.
  self assert: (schema asJson at: 'type') equals: 'object'
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaDescription [
  | schema json |
  schema := ClaudeToolInputSchema new
    description: 'A test schema'.
  json := schema asJson.
  self assert: (json at: 'description') equals: 'A test schema'
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaEmptyRoundTrip [
  | schema json restored restoredJson |
  schema := ClaudeToolInputSchema new.
  json := schema asJson.
  self assert: (json at: 'type') equals: 'object'.
  self assert: (json at: 'properties') equals: OrderedDictionary new.
  restored := ClaudeToolInputSchema fromJson: json.
  restoredJson := restored asJson.
  self assert: restoredJson equals: json
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaExtraFields [
  | schema json |
  schema := ClaudeToolInputSchema new
    schemaField: '$defs' put: (OrderedDictionary new at: 'Color' put: (OrderedDictionary new at: 'type' put: 'string'; yourself); yourself).
  json := schema asJson.
  self assert: (json includesKey: '$defs').
  self assert: ((json at: '$defs') includesKey: 'Color')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaFieldCollisionWithKnownKey [
  | schema json |
  schema := ClaudeToolInputSchema new
    schemaField: 'type' put: 'string'.
  self assert: schema type equals: 'string'.
  json := schema asJson.
  self assert: (json at: 'type') equals: 'string'.
  "Known key must NOT leak into extraFields"
  self deny: (schema extraFields includesKey: 'type')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaNestedObject [
  | schema addressSchema json addrJson |
  addressSchema := ClaudeToolInputSchema new
    addProperty: 'street' type: 'string' description: 'Street address';
    addProperty: 'city' type: 'string' description: 'City';
    require: 'street'; require: 'city'.
  schema := ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Person name';
    addProperty: 'address' schema: addressSchema;
    require: 'name'; require: 'address'.
  json := schema asJson.
  addrJson := (json at: 'properties') at: 'address'.
  self assert: (addrJson at: 'type') equals: 'object'.
  self assert: ((addrJson at: 'properties') at: 'street') equals:
    (OrderedDictionary new at: 'type' put: 'string'; at: 'description' put: 'Street address'; yourself).
  self assert: (addrJson at: 'required') asArray equals: #('street' 'city')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaPrintOn [
  | schema |
  schema := ClaudeToolInputSchema new
    addProperty: 'x' type: 'integer' description: 'A number'.
  self assert: schema printString equals: 'ClaudeToolInputSchema(object, 1 props)'
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaRoundTripWithExtraFields [
  | original restored restoredJson |
  original := OrderedDictionary new.
  original at: 'type' put: 'object'.
  original at: 'properties' put: (OrderedDictionary new
    at: 'name' put: (OrderedDictionary new at: 'type' put: 'string'; yourself);
    yourself).
  original at: 'required' put: #('name').
  original at: 'additionalProperties' put: false.
  restored := ClaudeToolInputSchema fromJson: original.
  restoredJson := restored asJson.
  self assert: (restoredJson at: 'type') equals: 'object'.
  self assert: ((restoredJson at: 'properties') at: 'name') equals: (OrderedDictionary new at: 'type' put: 'string'; yourself).
  self assert: (restoredJson at: 'required') asArray equals: #('name').
  self assert: (restoredJson at: 'additionalProperties') equals: false
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaStringTypeNoProperties [
  | schema json |
  schema := ClaudeToolInputSchema new type: 'string'.
  json := schema asJson.
  self assert: (json at: 'type') equals: 'string'.
  self deny: (json includesKey: 'properties')
]

{ #category : 'tests' }
ClaudeToolTest >> testSchemaWithEnum [
	| schema json propJson |
	schema := ClaudeToolInputSchema new
		addProperty: 'unit' type: 'string' description: 'Temperature unit' enum: #('celsius' 'fahrenheit');
		yourself.
	json := schema asJson.
	propJson := (json at: 'properties') at: 'unit'.
	self assert: (propJson at: 'type') equals: 'string'.
	self assert: (propJson at: 'description') equals: 'Temperature unit'.
	self assert: (propJson at: 'enum') asArray equals: #('celsius' 'fahrenheit')
]

{ #category : 'tests' }
ClaudeToolTest >> testToolAsJson [
	| schema tool json inputSchema |
	schema := ClaudeToolInputSchema new
		addProperty: 'city' type: 'string' description: 'City name';
		require: 'city';
		yourself.
	tool := ClaudeTool name: 'GetWeather' description: 'Get current weather' inputSchema: schema.
	json := tool asJson.
	self assert: (json at: 'name') equals: 'GetWeather'.
	self assert: (json at: 'description') equals: 'Get current weather'.
	inputSchema := json at: 'input_schema'.
	self assert: (inputSchema at: 'type') equals: 'object'.
	self assert: ((inputSchema at: 'properties') at: 'city') equals:
		(OrderedDictionary new at: 'type' put: 'string'; at: 'description' put: 'City name'; yourself).
	self assert: (inputSchema at: 'required') asArray equals: #('city')
]

{ #category : 'tests' }
ClaudeToolTest >> testToolFromJson [
	| json tool |
	json := Dictionary new.
	json at: 'name' put: 'GetWeather'.
	json at: 'description' put: 'Get current weather'.
	json at: 'input_schema' put: (Dictionary new
		at: 'type' put: 'object';
		at: 'properties' put: (Dictionary new
			at: 'city' put: (Dictionary new at: 'type' put: 'string'; at: 'description' put: 'City name'; yourself);
			yourself);
		at: 'required' put: #('city');
		yourself).
	tool := ClaudeTool fromJson: json.
	self assert: tool name equals: 'GetWeather'.
	self assert: tool description equals: 'Get current weather'.
	self assert: (tool inputSchema properties at: 'city')
		equals: (Dictionary new at: 'type' put: 'string'; at: 'description' put: 'City name'; yourself).
	self assert: tool inputSchema required asArray equals: #('city')
]

{ #category : 'tests' }
ClaudeToolTest >> testToolJsonKeyMap [
	| map |
	map := ClaudeTool jsonKeyMap.
	self assert: (map at: #inputSchema) equals: 'input_schema'.
	self assert: (map at: #cacheControl) equals: 'cache_control'.
	self assert: (map at: #strict) equals: 'strict'.
	self assert: map size equals: 3
]

{ #category : 'tests' }
ClaudeToolTest >> testToolRoundTrip [
	| schema original restored |
	schema := ClaudeToolInputSchema new
		addProperty: 'city' type: 'string' description: 'City name';
		addProperty: 'unit' type: 'string' description: 'Temperature unit' enum: #('celsius' 'fahrenheit');
		require: 'city';
		yourself.
	original := ClaudeTool name: 'GetWeather' description: 'Get current weather' inputSchema: schema.
	restored := ClaudeTool fromJson: original asJson.
	self assert: restored name equals: original name.
	self assert: restored description equals: original description.
	self assert: restored inputSchema required asArray equals: original inputSchema required asArray.
	self assert: (restored inputSchema properties at: 'city')
		equals: (original inputSchema properties at: 'city').
	self assert: ((restored inputSchema properties at: 'unit') at: 'enum') asArray
		equals: #('celsius' 'fahrenheit')
]
