"
Abstract backend protocol for OS keyring access. Subclasses implement platform-specific commands for secret-tool (Linux) and security(1) (macOS).

### Examples

```
PharoKeyringBackend subclasses size >= 2
>>> true
```

"
Class {
	#name : 'PharoKeyringBackend',
	#superclass : 'Object',
	#category : 'PharoKeyring',
	#package : 'PharoKeyring'
}

{ #category : 'operations' }
PharoKeyringBackend >> deleteService: serviceString account: accountString [
	^ self subclassResponsibility
]

{ #category : 'private' }
PharoKeyringBackend >> exitCodeFrom: waitStatus [
	"Extract process exit code from wait(2) status."
	^ (waitStatus >> 8) bitAnd: 16rFF
]

{ #category : 'testing' }
PharoKeyringBackend >> isAvailable [
	^ self subclassResponsibility
]

{ #category : 'operations' }
PharoKeyringBackend >> lookupService: serviceString account: accountString [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
PharoKeyringBackend >> name [
	^ self subclassResponsibility
]

{ #category : 'private' }
PharoKeyringBackend >> shellQuote: aString [
	"POSIX single-quote escaping. Each embedded single-quote is replaced with the four-character sequence: close-quote, backslash, quote, open-quote."
	| sq replacement |
	sq := String with: $'.
	replacement := sq, (String with: $\), sq, sq.
	^ sq, (aString copyReplaceAll: sq with: replacement), sq
]

{ #category : 'operations' }
PharoKeyringBackend >> storeService: serviceString account: accountString secret: secretString label: labelString [
	^ self subclassResponsibility
]
