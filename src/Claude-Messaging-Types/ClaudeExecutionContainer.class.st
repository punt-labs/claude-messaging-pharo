"
Code execution sandbox info from the API response. Holds the container ID, expiration timestamp, and (optionally) the skills loaded into the container. Parsed from the nested container sub-dict in the response JSON.

### Examples

```
ClaudeExecutionContainer fromJson: (Dictionary newFromPairs: { 'container'. (Dictionary newFromPairs: { 'id'. 'ctr_123'. 'expires_at'. '2026-04-18T12:00:00Z' }) })
>>> a ClaudeExecutionContainer

(ClaudeExecutionContainer new containerId: 'ctr_123'; expiresAt: '2026-04-18T12:00:00Z') asJson
>>> an OrderedDictionary('id'->'ctr_123' 'expires_at'->'2026-04-18T12:00:00Z')

| ctr |
ctr := ClaudeExecutionContainer new.
ctr skills: { ClaudeSkillSpec skillId: 'sk_abc' type: 'custom' }.
ctr skills size
>>> 1
```


"
Class {
	#name : 'ClaudeExecutionContainer',
	#superclass : 'Object',
	#instVars : [
		'containerId',
		'expiresAt',
		'skills'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeExecutionContainer class >> fromJson: aDictionary [
	"Parse from a nested container dict in the API response."
	| containerDict rawSkills |
	aDictionary ifNil: [ ^ nil ].
	containerDict := aDictionary at: 'container' ifAbsent: [ nil ].
	containerDict ifNil: [ ^ nil ].
	rawSkills := containerDict at: 'skills' ifAbsent: [ nil ].
	^ self new
		containerId: (containerDict at: 'id' ifAbsent: [ nil ]);
		expiresAt: (containerDict at: 'expires_at' ifAbsent: [ nil ]);
		skills: (rawSkills
			ifNotNil: [ (rawSkills collect: [ :s | ClaudeSkillSpec fromJson: s ]) asOrderedCollection ]);
		yourself
]

{ #category : 'persistence' }
ClaudeExecutionContainer class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		containerId: (dict at: #containerId ifAbsent: [ nil ]);
		expiresAt: (dict at: #expiresAt ifAbsent: [ nil ]);
		skills: (dict at: #skills ifAbsent: [ nil ]);
		yourself
]

{ #category : 'json' }
ClaudeExecutionContainer class >> jsonKeyMap [
	^ {
		#containerId -> 'id'.
		#expiresAt -> 'expires_at'
	} asDictionary
]

{ #category : 'json' }
ClaudeExecutionContainer >> asJson [
	| dict |
	dict := OrderedDictionary new.
	containerId ifNotNil: [ dict at: 'id' put: containerId ].
	expiresAt ifNotNil: [ dict at: 'expires_at' put: expiresAt ].
	(skills notNil and: [ skills notEmpty ]) ifTrue: [
		dict at: 'skills' put: (skills collect: [ :s | s asJson ]) asArray ].
	^ dict
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> containerId [
	^ containerId
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> containerId: aString [
	containerId := aString
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> expiresAt [
	^ expiresAt
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> expiresAt: aString [
	expiresAt := aString
]

{ #category : 'printing' }
ClaudeExecutionContainer >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeExecutionContainer(';
		nextPutAll: (containerId ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> skills [
	^ skills
]

{ #category : 'accessing' }
ClaudeExecutionContainer >> skills: aCollection [
	skills := aCollection
]

{ #category : 'persistence' }
ClaudeExecutionContainer >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		containerId ifNotNil: [ map at: #containerId put: containerId ].
		expiresAt ifNotNil: [ map at: #expiresAt put: expiresAt ].
		skills ifNotNil: [ map at: #skills put: skills ] ]
]
