"
Unit tests for PharoKeyring using MockKeyringBackend. Covers store, lookup, delete, has, overwrite, and availability.
"
Class {
	#name : 'PharoKeyringTest',
	#superclass : 'TestCase',
	#instVars : [
		'keyring'
	],
	#category : 'PharoKeyring-Tests',
	#package : 'PharoKeyring-Tests'
}

{ #category : 'running' }
PharoKeyringTest >> setUp [
	super setUp.
	keyring := PharoKeyring withBackend: MockKeyringBackend new
]

{ #category : 'tests' }
PharoKeyringTest >> testBackendName [
	self assert: keyring backendName equals: 'mock'
]

{ #category : 'tests' }
PharoKeyringTest >> testDeleteExisting [
	keyring store: 'svc' account: 'acct' secret: 'pw'.
	keyring delete: 'svc' account: 'acct'.
	self assert: (keyring lookup: 'svc' account: 'acct') isNil
]

{ #category : 'tests' }
PharoKeyringTest >> testDeleteMissing [
	"Deleting a non-existent item should not signal an error."
	keyring delete: 'nosvc' account: 'noacct'
]

{ #category : 'tests' }
PharoKeyringTest >> testHasExisting [
	keyring store: 'svc' account: 'acct' secret: 'pw'.
	self assert: (keyring has: 'svc' account: 'acct')
]

{ #category : 'tests' }
PharoKeyringTest >> testHasMissing [
	self deny: (keyring has: 'nosvc' account: 'noacct')
]

{ #category : 'tests' }
PharoKeyringTest >> testIsAvailable [
	self assert: keyring isAvailable
]

{ #category : 'tests' }
PharoKeyringTest >> testLookupMissing [
	self assert: (keyring lookup: 'noservice' account: 'nouser') isNil
]

{ #category : 'tests' }
PharoKeyringTest >> testOverwrite [
	keyring store: 'svc' account: 'acct' secret: 'old'.
	keyring store: 'svc' account: 'acct' secret: 'new'.
	self assert: (keyring lookup: 'svc' account: 'acct') equals: 'new'
]

{ #category : 'tests' }
PharoKeyringTest >> testStoreAndLookup [
	keyring store: 'myservice' account: 'user1' secret: 's3cret'.
	self assert: (keyring lookup: 'myservice' account: 'user1') equals: 's3cret'
]
