"
Client-attached rendering metadata. Holds the output format from request params. NOT serialized in JSON (transport-only), but persisted via STON for session replay.

The HTTP request-id used to live here too; in Phase 2 (mission yvyt+pch2)
it migrated to ClaudeResponseMetadata so it can sit alongside the rate-limit
and retry-after telemetry that arrives on the same response.

The migratedRequestId slot is a one-way migration carrier for legacy STON
snapshots written before the Phase 2 split. ClaudeRequestContext>>fromSton:
captures the legacy #requestId field there; ClaudeMessage>>fromSton: rescues
the value into responseMetadata.requestId and clears the slot. The slot is
never serialized via stonOn: so a re-saved snapshot writes only the new
shape. See PR #136 round-5.

### Examples

  ClaudeRequestContext new outputFormat: ClaudeTextOutputFormat new; outputFormat
  >>> a ClaudeTextOutputFormat

"
Class {
	#name : 'ClaudeRequestContext',
	#superclass : 'Object',
	#instVars : [
		'outputFormat',
		'migratedRequestId'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'persistence' }
ClaudeRequestContext class >> fromSton: stonReader [
  "Restore from STON. The requestId field migrated to ClaudeResponseMetadata
   in Phase 2 (mission yvyt+pch2). For backward compatibility with snapshots
   written before that migration, a legacy #requestId in the STON map is
   captured into the transient migratedRequestId slot so ClaudeMessage>>
   fromSton: can rescue it into responseMetadata. The slot is never written
   back to STON via stonOn:."
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    outputFormat: (dict at: #outputFormat ifAbsent: [ nil ]);
    migratedRequestId: (dict at: #requestId ifAbsent: [ nil ]);
    yourself
]

{ #category : 'private - migration' }
ClaudeRequestContext >> migratedRequestId [
  "Transient holder for the legacy requestId field that pre-yvyt+pch2 STON
   snapshots stored on this class. Populated by fromSton: when an old
   snapshot is parsed, then read and cleared by ClaudeMessage>>fromSton:
   which migrates the value into responseMetadata. Never serialized via
   stonOn:."
  ^ migratedRequestId
]

{ #category : 'private - migration' }
ClaudeRequestContext >> migratedRequestId: aString [
  "Transient setter used by fromSton: to carry a legacy requestId out
   to ClaudeMessage>>fromSton: for one-way migration into responseMetadata."
  migratedRequestId := aString
]

{ #category : 'accessing' }
ClaudeRequestContext >> outputFormat [
	^ outputFormat
]

{ #category : 'accessing' }
ClaudeRequestContext >> outputFormat: anObject [
	outputFormat := anObject
]

{ #category : 'printing' }
ClaudeRequestContext >> printOn: aStream [
  "Compact debug rendering. The requestId field migrated to
   ClaudeResponseMetadata; only outputFormat lives here now.
   Renders ClaudeRequestContext(?) when outputFormat is nil, otherwise
   ClaudeRequestContext(<outputFormat printString>). Mirrors the
   sibling pattern in ClaudeResponseMetadata>>printOn: where missing
   slots render as a bare ? without quote delimiters."
  aStream nextPutAll: 'ClaudeRequestContext('.
  outputFormat
    ifNil: [ aStream nextPutAll: '?' ]
    ifNotNil: [ aStream print: outputFormat ].
  aStream nextPut: $)
]

{ #category : 'persistence' }
ClaudeRequestContext >> stonOn: aStonWriter [
  "Persist outputFormat only. requestId now lives on
   ClaudeResponseMetadata (mission yvyt+pch2)."
  aStonWriter writeObject: self streamMap: [ :map |
    outputFormat ifNotNil: [ map at: #outputFormat put: outputFormat ] ]
]
