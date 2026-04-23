"
Unit tests for LinuxSecretToolBackend shell quoting and command construction.
"
Class {
	#name : 'LinuxSecretToolBackendTest',
	#superclass : 'TestCase',
	#instVars : [
		'backend'
	],
	#category : 'PharoKeyring-Tests',
	#package : 'PharoKeyring-Tests'
}

{ #category : 'running' }
LinuxSecretToolBackendTest >> setUp [
	super setUp.
	backend := LinuxSecretToolBackend new
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testExitCodeExtraction [
	self assert: (backend exitCodeFrom: 0) equals: 0.
	self assert: (backend exitCodeFrom: 256) equals: 1.
	self assert: (backend exitCodeFrom: 512) equals: 2
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testIsAvailable [
	self assert: backend isAvailable
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testName [
	self assert: backend name equals: 'secret-tool'
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testShellQuoteEmbeddedQuote [
	| input result sq bsq expected |
	sq := String with: $'.
	bsq := String with: $\.
	input := 'it', sq, 's'.
	result := backend shellQuote: input.
	expected := sq, 'it', sq, bsq, sq, sq, 's', sq.
	self assert: result equals: expected
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testShellQuoteEmpty [
	self assert: (backend shellQuote: '') equals: (String with: $'), (String with: $')
]

{ #category : 'tests' }
LinuxSecretToolBackendTest >> testShellQuoteSimple [
	self assert: (backend shellQuote: 'hello') equals: (String with: $'), 'hello', (String with: $')
]
