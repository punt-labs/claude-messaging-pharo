"
Integration tests against the real OS keyring. Uses unique service names to avoid collision. Runs on Linux (secret-tool) and macOS (security command). Tests assert prerequisites and fail clearly when missing; they are excluded from make test.

  PharoKeyringIntegrationTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'PharoKeyringIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'keyring',
		'testService'
	],
	#category : 'PharoKeyring-Tests',
	#package : 'PharoKeyring-Tests'
}

{ #category : 'running' }
PharoKeyringIntegrationTest >> setUp [
	super setUp.
	self assert: OSPlatform current isUnix description: 'Keyring integration tests require Unix (Linux/macOS).'.
	keyring := PharoKeyring default.
	self assert: keyring isAvailable description: 'Keyring backend not available (secret-tool or security not installed).'.
	testService := 'pharotest-', UUID new printString
]

{ #category : 'running' }
PharoKeyringIntegrationTest >> tearDown [
	testService ifNotNil: [
		keyring delete: testService account: 'testaccount'.
		keyring delete: testService account: 'special' ].
	super tearDown
]

{ #category : 'tests-integration' }
PharoKeyringIntegrationTest >> testDeleteAndLookup [
	keyring store: testService account: 'testaccount' secret: 'temporary'.
	keyring delete: testService account: 'testaccount'.
	self assert: (keyring lookup: testService account: 'testaccount') isNil
]

{ #category : 'tests-integration' }
PharoKeyringIntegrationTest >> testOverwrite [
	keyring store: testService account: 'testaccount' secret: 'first'.
	keyring store: testService account: 'testaccount' secret: 'second'.
	self assert: (keyring lookup: testService account: 'testaccount') equals: 'second'
]

{ #category : 'tests-integration' }
PharoKeyringIntegrationTest >> testRoundTrip [
	keyring store: testService account: 'testaccount' secret: 'mysecret'.
	self assert: (keyring lookup: testService account: 'testaccount') equals: 'mysecret'
]

{ #category : 'tests-integration' }
PharoKeyringIntegrationTest >> testSpecialCharacters [
	| secret |
	secret := 'p@$$w0rd!#%^&*()'.
	keyring store: testService account: 'special' secret: secret.
	self assert: (keyring lookup: testService account: 'special') equals: secret
]
