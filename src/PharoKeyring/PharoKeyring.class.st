"
Cross-platform OS keyring facade. Detects the current platform and delegates to the appropriate backend (secret-tool on Linux, security(1) on macOS). Use withBackend: to inject a mock for testing.

### Examples

```
PharoKeyring default backendName
>>> 'secret-tool'
```

"
Class {
	#name : 'PharoKeyring',
	#superclass : 'Object',
	#instVars : [
		'backend'
	],
	#category : 'PharoKeyring',
	#package : 'PharoKeyring'
}

{ #category : 'instance creation' }
PharoKeyring class >> default [
	^ self new
]

{ #category : 'instance creation' }
PharoKeyring class >> withBackend: aBackend [
	^ self basicNew
		backend: aBackend;
		yourself
]

{ #category : 'accessing' }
PharoKeyring >> backend [
	^ backend
]

{ #category : 'accessing' }
PharoKeyring >> backend: aBackend [
	backend := aBackend
]

{ #category : 'accessing' }
PharoKeyring >> backendName [
	^ backend name
]

{ #category : 'operations' }
PharoKeyring >> delete: serviceString account: accountString [
	backend deleteService: serviceString account: accountString
]

{ #category : 'initialization' }
PharoKeyring >> detectBackend [
	OSPlatform current isMacOS ifTrue: [ ^ backend := MacOSSecurityBackend new ].
	OSPlatform current isUnix ifTrue: [ ^ backend := LinuxSecretToolBackend new ].
	Error signal: 'Unsupported platform: ', OSPlatform current name
]

{ #category : 'testing' }
PharoKeyring >> has: serviceString account: accountString [
	^ (self lookup: serviceString account: accountString) isNotNil
]

{ #category : 'initialization' }
PharoKeyring >> initialize [
	self detectBackend
]

{ #category : 'testing' }
PharoKeyring >> isAvailable [
	^ backend isAvailable
]

{ #category : 'operations' }
PharoKeyring >> lookup: serviceString account: accountString [
	^ backend lookupService: serviceString account: accountString
]

{ #category : 'operations' }
PharoKeyring >> store: serviceString account: accountString secret: secretString [
	self store: serviceString account: accountString secret: secretString label: serviceString
]

{ #category : 'operations' }
PharoKeyring >> store: serviceString account: accountString secret: secretString label: labelString [
	backend storeService: serviceString account: accountString secret: secretString label: labelString
]
