"
Output configuration for Claude API requests. Groups effort level and output format -- the parameters that control what shape the response takes. Extracted as a parameter group following the same pattern as ClaudeSamplingParams and ClaudeThinkingParams.

Valid effort levels (ascending): 'low', 'medium', 'high', 'xhigh', 'max'.

  ClaudeOutputConfig effort: 'high'
  >>> a ClaudeOutputConfig

  ClaudeOutputConfig effort: 'xhigh'
  >>> a ClaudeOutputConfig

  (ClaudeOutputConfig jsonSchema: (ClaudeToolInputSchema new
    addProperty: 'name' type: 'string' description: 'Name')) format
  >>> a ClaudeJsonSchemaOutputFormat

"
Class {
	#name : 'ClaudeOutputConfig',
	#superclass : 'Object',
	#instVars : [
		'effort',
		'format'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeOutputConfig class >> effort: aString [
  ^ self new effort: aString; yourself
]

{ #category : 'instance creation' }
ClaudeOutputConfig class >> effort: aString jsonSchema: aClaudeToolInputSchema [
  ^ self new
    effort: aString;
    format: (ClaudeJsonSchemaOutputFormat schema: aClaudeToolInputSchema);
    yourself
]

{ #category : 'instance creation' }
ClaudeOutputConfig class >> jsonSchema: aClaudeToolInputSchema [
  ^ self new
    format: (ClaudeJsonSchemaOutputFormat schema: aClaudeToolInputSchema);
    yourself
]

{ #category : 'json' }
ClaudeOutputConfig >> addFieldsTo: dict [
  | configDict |
  (effort isNil and: [ format isNil ]) ifTrue: [ ^ self ].
  configDict := OrderedDictionary new.
  effort ifNotNil: [ configDict at: 'effort' put: effort ].
  format ifNotNil: [ format asJson ifNotNil: [ :fj | configDict at: 'format' put: fj ] ].
  configDict ifEmpty: [ ^ self ].
  dict at: 'output_config' put: configDict
]

{ #category : 'accessing' }
ClaudeOutputConfig >> effort [
  ^ effort
]

{ #category : 'accessing' }
ClaudeOutputConfig >> effort: aString [
  effort := aString
]

{ #category : 'accessing' }
ClaudeOutputConfig >> format [
  ^ format
]

{ #category : 'accessing' }
ClaudeOutputConfig >> format: aClaudeOutputFormat [
  format := aClaudeOutputFormat
]
