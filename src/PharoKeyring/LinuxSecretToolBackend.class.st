"
Keyring backend for Linux using secret-tool(1), which accesses GNOME Keyring or KDE Wallet via the Secret Service D-Bus API.

### Examples

```
LinuxSecretToolBackend new class name
>>> 'LinuxSecretToolBackend'
```

"
Class {
	#name : 'LinuxSecretToolBackend',
	#superclass : 'PharoKeyringBackend',
	#category : 'PharoKeyring',
	#package : 'PharoKeyring'
}

{ #category : 'operations' }
LinuxSecretToolBackend >> deleteService: serviceString account: accountString [
	| cmd |
	cmd := 'secret-tool clear service ', (self shellQuote: serviceString), ' account ', (self shellQuote: accountString).
	LibC runCommand: cmd
]

{ #category : 'testing' }
LinuxSecretToolBackend >> isAvailable [
	^ (self exitCodeFrom: (LibC runCommand: 'which secret-tool > /dev/null 2>&1')) = 0
]

{ #category : 'operations' }
LinuxSecretToolBackend >> lookupService: serviceString account: accountString [
	| cmd result |
	cmd := 'secret-tool lookup service ', (self shellQuote: serviceString), ' account ', (self shellQuote: accountString).
	result := LibC resultOfCommand: cmd.
	result ifNil: [ ^ nil ].
	result := result trimRight.
	result ifEmpty: [ ^ nil ].
	^ result
]

{ #category : 'accessing' }
LinuxSecretToolBackend >> name [
	^ 'secret-tool'
]

{ #category : 'operations' }
LinuxSecretToolBackend >> storeService: serviceString account: accountString secret: secretString label: labelString [
	| cmd status exitCode |
	cmd := 'printf %s ', (self shellQuote: secretString), ' | secret-tool store --label=', (self shellQuote: labelString), ' service ', (self shellQuote: serviceString), ' account ', (self shellQuote: accountString).
	status := LibC runCommand: cmd.
	exitCode := self exitCodeFrom: status.
	exitCode = 0 ifFalse: [
		KeyringCommandError new
			exitCode: exitCode;
			command: cmd;
			signal ]
]
