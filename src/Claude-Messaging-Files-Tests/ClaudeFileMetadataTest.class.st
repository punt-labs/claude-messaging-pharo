"
Tests for ClaudeFileMetadata JSON, STON, and printing.
"
Class {
	#name : 'ClaudeFileMetadataTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Files-Tests',
	#package : 'Claude-Messaging-Files-Tests'
}

{ #category : 'tests' }
ClaudeFileMetadataTest >> testConstruction [
	| m |
	m := ClaudeFileMetadata new.
	m id: 'file-123'.
	m filename: 'report.pdf'.
	m mimeType: 'application/pdf'.
	m sizeBytes: 1024.
	m createdAt: '2026-01-01T00:00:00Z'.
	m downloadable: true.
	self assert: m id equals: 'file-123'.
	self assert: m filename equals: 'report.pdf'.
	self assert: m mimeType equals: 'application/pdf'.
	self assert: m sizeBytes equals: 1024.
	self assert: m createdAt equals: '2026-01-01T00:00:00Z'.
	self assert: m type equals: 'file'.
	self assert: m downloadable equals: true
]

{ #category : 'tests' }
ClaudeFileMetadataTest >> testFromJsonRoundTrip [
	| json original restored |
	json := Dictionary new.
	json at: 'id' put: 'file-abc'.
	json at: 'filename' put: 'test.pdf'.
	json at: 'mime_type' put: 'application/pdf'.
	json at: 'size_bytes' put: 2048.
	json at: 'created_at' put: '2026-01-01T00:00:00Z'.
	json at: 'type' put: 'file'.
	json at: 'downloadable' put: true.
	original := ClaudeFileMetadata fromJson: json.
	restored := original asJson.
	self assert: (restored at: 'id') equals: 'file-abc'.
	self assert: (restored at: 'filename') equals: 'test.pdf'.
	self assert: (restored at: 'mime_type') equals: 'application/pdf'.
	self assert: (restored at: 'size_bytes') equals: 2048.
	self assert: (restored at: 'created_at') equals: '2026-01-01T00:00:00Z'.
	self assert: (restored at: 'type') equals: 'file'.
	self assert: (restored at: 'downloadable') equals: true
]

{ #category : 'tests' }
ClaudeFileMetadataTest >> testPrintOn [
	| m |
	m := ClaudeFileMetadata new.
	m id: 'file-abc'.
	m filename: 'test.pdf'.
	self assert: m printString equals: 'ClaudeFileMetadata(file-abc test.pdf)'
]

{ #category : 'tests' }
ClaudeFileMetadataTest >> testStonRoundTrip [
	| original ston restored |
	original := ClaudeFileMetadata new.
	original id: 'file-xyz'.
	original filename: 'data.csv'.
	original mimeType: 'text/csv'.
	original sizeBytes: 512.
	original createdAt: '2026-02-01T12:00:00Z'.
	original downloadable: false.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored id equals: 'file-xyz'.
	self assert: restored filename equals: 'data.csv'.
	self assert: restored mimeType equals: 'text/csv'.
	self assert: restored sizeBytes equals: 512.
	self assert: restored createdAt equals: '2026-02-01T12:00:00Z'.
	self assert: restored type equals: 'file'.
	self assert: restored downloadable equals: false
]
