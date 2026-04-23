"
Token count result from the Claude count_tokens API endpoint. Contains the number of input tokens that a message would consume. Returned by ClaudeClient>>countTokens:.

### Examples

```
(ClaudeMessageTokensCount fromJson: (Dictionary newFromPairs: #('input_tokens' 42))) inputTokens
>>> 42
```

"
Class {
	#name : 'ClaudeMessageTokensCount',
	#superclass : 'Object',
	#instVars : [
		'inputTokens'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeMessageTokensCount class >> fromJson: aDictionary [
	^ self new
		inputTokens: (aDictionary at: 'input_tokens' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeMessageTokensCount class >> jsonKeyMap [
	^ {
		#inputTokens -> 'input_tokens'
	} asDictionary
]

{ #category : 'json' }
ClaudeMessageTokensCount >> asJson [
	| dict |
	dict := OrderedDictionary new.
	inputTokens ifNotNil: [ dict at: 'input_tokens' put: inputTokens ].
	^ dict
]

{ #category : 'accessing' }
ClaudeMessageTokensCount >> inputTokens [
	^ inputTokens
]

{ #category : 'accessing' }
ClaudeMessageTokensCount >> inputTokens: anInteger [
	inputTokens := anInteger
]

{ #category : 'printing' }
ClaudeMessageTokensCount >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeMessageTokensCount(';
		print: (inputTokens ifNil: [ 0 ]);
		nextPut: $)
]
