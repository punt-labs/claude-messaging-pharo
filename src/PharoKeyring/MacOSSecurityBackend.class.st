"
Keyring backend for macOS using security(1) to access the system Keychain.

### Examples

```
MacOSSecurityBackend new class name
>>> 'MacOSSecurityBackend'
```

"
Class {
	#name : 'MacOSSecurityBackend',
	#superclass : 'PharoKeyringBackend',
	#category : 'PharoKeyring',
	#package : 'PharoKeyring'
}

{ #category : 'operations' }
MacOSSecurityBackend >> deleteService: serviceString account: accountString [
	| cmd |
	cmd := 'security delete-generic-password -s ', (self shellQuote: serviceString), ' -a ', (self shellQuote: accountString), ' 2>/dev/null'.
	LibC runCommand: cmd
]

{ #category : 'testing' }
MacOSSecurityBackend >> isAvailable [
	^ (self exitCodeFrom: (LibC runCommand: 'which security > /dev/null 2>&1')) = 0
]

{ #category : 'operations' }
MacOSSecurityBackend >> lookupService: serviceString account: accountString [
	| cmd result |
	cmd := 'security find-generic-password -s ', (self shellQuote: serviceString), ' -a ', (self shellQuote: accountString), ' -w 2>/dev/null'.
	result := LibC resultOfCommand: cmd.
	result ifNil: [ ^ nil ].
	result := result trimRight.
	result ifEmpty: [ ^ nil ].
	^ result
]

{ #category : 'accessing' }
MacOSSecurityBackend >> name [
	^ 'security'
]

{ #category : 'operations' }
MacOSSecurityBackend >> storeService: serviceString account: accountString secret: secretString label: labelString [
	| cmd status exitCode |
	cmd := 'security add-generic-password -U -s ', (self shellQuote: serviceString), ' -a ', (self shellQuote: accountString), ' -w ', (self shellQuote: secretString).
	status := LibC runCommand: cmd.
	exitCode := self exitCodeFrom: status.
	exitCode = 0 ifFalse: [
		KeyringCommandError new
			exitCode: exitCode;
			command: cmd;
			signal ]
]
