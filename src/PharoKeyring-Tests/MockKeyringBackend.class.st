"
In-memory keyring backend for unit testing. Stores secrets in a nested Dictionary keyed by service then account.
"
Class {
	#name : 'MockKeyringBackend',
	#superclass : 'PharoKeyringBackend',
	#instVars : [
		'store'
	],
	#category : 'PharoKeyring-Tests',
	#package : 'PharoKeyring-Tests'
}

{ #category : 'operations' }
MockKeyringBackend >> deleteService: serviceString account: accountString [
	| serviceDict |
	serviceDict := store at: serviceString ifAbsent: [ ^ self ].
	serviceDict removeKey: accountString ifAbsent: [ ]
]

{ #category : 'initialization' }
MockKeyringBackend >> initialize [
	store := Dictionary new
]

{ #category : 'testing' }
MockKeyringBackend >> isAvailable [
	^ true
]

{ #category : 'operations' }
MockKeyringBackend >> lookupService: serviceString account: accountString [
	| serviceDict |
	serviceDict := store at: serviceString ifAbsent: [ ^ nil ].
	^ serviceDict at: accountString ifAbsent: [ nil ]
]

{ #category : 'accessing' }
MockKeyringBackend >> name [
	^ 'mock'
]

{ #category : 'operations' }
MockKeyringBackend >> storeService: serviceString account: accountString secret: secretString label: labelString [
	| serviceDict |
	serviceDict := store at: serviceString ifAbsentPut: [ Dictionary new ].
	serviceDict at: accountString put: secretString
]
