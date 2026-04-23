"
Request-side specification for a skill to load into a code-execution container. Pass instances inside a ClaudeContainerParams to load skills when running with the code-execution tool. type is 'custom' (user skills) or 'anthropic' (built-in skills). version is optional; omitting it tells Anthropic to use the latest published version.

Required fields: skillId, type. asJson raises if either is missing so the bug surfaces at construction time, not inside an API 400.

Forward compatibility: any wire keys outside knownJsonKeys are captured into extraFields by fromJson: and re-emitted by asJson, so a fromJson:/asJson roundtrip is lossless even when Anthropic ships new skill spec fields. Mirrors ClaudeMCPServerDefinition forward-compat strategy.

  (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom') skillId
  >>> 'sk_abc'

  (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom') asJson
  >>> an OrderedDictionary('skill_id'->'sk_abc' 'type'->'custom')

  (ClaudeSkillSpec skillId: 'sk_abc' type: 'custom' version: '1759178010641129') asJson
  >>> an OrderedDictionary('skill_id'->'sk_abc' 'type'->'custom' 'version'->'1759178010641129')

"
Class {
	#name : 'ClaudeSkillSpec',
	#superclass : 'Object',
	#instVars : [
		'skillId',
		'type',
		'version',
		'extraFields'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeSkillSpec class >> fromJson: aDictionary [
	"Construct from the wire dictionary. Known fields go in dedicated slots;
	 any unknown keys are preserved in extraFields so they roundtrip back
	 through asJson. Mirrors ClaudeMCPServerDefinition forward-compat strategy."
	| spec known |
	spec := self new
		skillId: (aDictionary at: 'skill_id' ifAbsent: [ nil ]);
		type: (aDictionary at: 'type' ifAbsent: [ nil ]);
		version: (aDictionary at: 'version' ifAbsent: [ nil ]);
		yourself.
	known := self knownJsonKeys.
	aDictionary keysAndValuesDo: [ :k :v |
		(known includes: k) ifFalse: [ spec extraFields at: k put: v ] ].
	^ spec
]

{ #category : 'json' }
ClaudeSkillSpec class >> jsonKeyMap [
	^ {
		#skillId -> 'skill_id'
	} asDictionary
]

{ #category : 'json' }
ClaudeSkillSpec class >> knownJsonKeys [
	"The snake_case wire keys this class explicitly handles. Used by fromJson:
	 to identify which entries belong in extraFields for forward-compat
	 preservation. Mirrors ClaudeMCPServerDefinition knownJsonKeys."
	^ #('skill_id' 'type' 'version') asSet
]

{ #category : 'instance creation' }
ClaudeSkillSpec class >> skillId: aSkillId type: aType [
	^ self new
		skillId: aSkillId;
		type: aType;
		yourself
]

{ #category : 'instance creation' }
ClaudeSkillSpec class >> skillId: aSkillId type: aType version: aVersion [
	^ self new
		skillId: aSkillId;
		type: aType;
		version: aVersion;
		yourself
]

{ #category : 'json' }
ClaudeSkillSpec >> asJson [
	"Emit the wire dictionary. Required fields raise if missing; optional
	 version is omitted when nil. Forward-compat unknown fields captured by
	 fromJson: are appended last so a roundtrip is lossless."
	| dict |
	skillId ifNil: [ self error: 'skill_id is required' ].
	type ifNil: [ self error: 'type is required' ].
	dict := OrderedDictionary new.
	dict at: 'skill_id' put: skillId.
	dict at: 'type' put: type.
	version ifNotNil: [ dict at: 'version' put: version ].
	extraFields ifNotNil: [
		extraFields keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	^ dict
]

{ #category : 'accessing' }
ClaudeSkillSpec >> extraFields [
	"Answer the dictionary of forward-compat unknown JSON fields captured
	 by fromJson:. Empty by default; never nil after initialize."
	^ extraFields
]

{ #category : 'accessing' }
ClaudeSkillSpec >> extraFields: aDictionary [
	"Set the forward-compat unknown JSON fields. Mainly for fromJson: and
	 tests; production code does not call this directly."
	extraFields := aDictionary
]

{ #category : 'initialization' }
ClaudeSkillSpec >> initialize [
	super initialize.
	extraFields := Dictionary new
]

{ #category : 'accessing' }
ClaudeSkillSpec >> skillId [
	^ skillId
]

{ #category : 'accessing' }
ClaudeSkillSpec >> skillId: aString [
	skillId := aString
]

{ #category : 'accessing' }
ClaudeSkillSpec >> type [
	^ type
]

{ #category : 'accessing' }
ClaudeSkillSpec >> type: aString [
	type := aString
]

{ #category : 'accessing' }
ClaudeSkillSpec >> version [
	^ version
]

{ #category : 'accessing' }
ClaudeSkillSpec >> version: aString [
	version := aString
]
