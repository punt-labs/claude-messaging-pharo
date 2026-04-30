"
Request-side container parameters for code-execution requests with skills. Pass an instance to ClaudeMessageRequest container: (or ClaudeRequestOptions container:) to load skills into a code-execution container. The container slot is polymorphic and also accepts a plain String container ID for back-compat -- see ClaudeRequestOptions container: for the dispatch.

Forward compatibility: any wire keys outside knownJsonKeys are captured into extraFields by fromJson: and re-emitted by asJson, so a fromJson:/asJson roundtrip is lossless even when Anthropic ships new container fields. Mirrors ClaudeMCPServerDefinition forward-compat strategy.

  (ClaudeContainerParams new id: 'ctr_abc'; yourself) id
  >>> 'ctr_abc'

  | params |
  params := ClaudeContainerParams new.
  params skills: { ClaudeSkillSpec skillId: 'sk_1' type: 'custom' }.
  (params asJson at: 'skills') size
  >>> 1

  ClaudeContainerParams new asJson isEmpty
  >>> true

"
Class {
	#name : 'ClaudeContainerParams',
	#superclass : 'Object',
	#instVars : [
		'id',
		'skills',
		'extraFields'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeContainerParams class >> fromJson: aDictionary [
	"Construct from the wire dictionary. Known fields go in dedicated slots;
	 any unknown keys are preserved in extraFields so they roundtrip back
	 through asJson. Mirrors ClaudeMCPServerDefinition forward-compat strategy."
	| params rawSkills known |
	rawSkills := aDictionary at: 'skills' ifAbsent: [ nil ].
	params := self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		skills: (rawSkills
			ifNotNil: [ (rawSkills collect: [ :s | ClaudeSkillSpec fromJson: s ]) asOrderedCollection ]);
		yourself.
	known := self knownJsonKeys.
	aDictionary keysAndValuesDo: [ :k :v |
		(known includes: k) ifFalse: [ params extraFields at: k put: v ] ].
	^ params
]

{ #category : 'instance creation' }
ClaudeContainerParams class >> id: aContainerId skills: aCollection [
	^ self new
		id: aContainerId;
		skills: aCollection;
		yourself
]

{ #category : 'json' }
ClaudeContainerParams class >> jsonKeyMap [
	^ Dictionary new
]

{ #category : 'json' }
ClaudeContainerParams class >> knownJsonKeys [
	"The snake_case wire keys this class explicitly handles. Used by fromJson:
	 to identify which entries belong in extraFields for forward-compat
	 preservation. Mirrors ClaudeMCPServerDefinition knownJsonKeys."
	^ #('id' 'skills') asSet
]

{ #category : 'json' }
ClaudeContainerParams >> asJson [
	"Emit the wire dictionary. Known fields go first; any forward-compat
	 unknown fields captured by fromJson: are appended last so a roundtrip
	 is lossless and the canonical id/skills order stays at the head."
	| dict |
	dict := OrderedDictionary new.
	id ifNotNil: [ dict at: 'id' put: id ].
	(skills notNil and: [ skills notEmpty ]) ifTrue: [
		dict at: 'skills' put: (skills collect: [ :s | s asJson ]) asArray ].
	extraFields ifNotNil: [
		extraFields keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	^ dict
]

{ #category : 'accessing' }
ClaudeContainerParams >> extraFields [
	"Answer the dictionary of forward-compat unknown JSON fields captured
	 by fromJson:. Empty by default; never nil after initialize."
	^ extraFields
]

{ #category : 'accessing' }
ClaudeContainerParams >> extraFields: aDictionary [
	"Set the forward-compat unknown JSON fields. Mainly for fromJson: and
	 tests; production code does not call this directly."
	extraFields := aDictionary
]

{ #category : 'accessing' }
ClaudeContainerParams >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeContainerParams >> id: aString [
	id := aString
]

{ #category : 'initialization' }
ClaudeContainerParams >> initialize [
	super initialize.
	extraFields := Dictionary new
]

{ #category : 'testing' }
ClaudeContainerParams >> isClaudeContainerParams [
	^ true
]

{ #category : 'accessing' }
ClaudeContainerParams >> skills [
	^ skills
]

{ #category : 'accessing' }
ClaudeContainerParams >> skills: aCollection [
	skills := aCollection
]
