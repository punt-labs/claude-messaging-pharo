"
Signaled when a shell command to the OS keyring returns a non-zero exit code. Carries the exit code and command string for debugging.

### Examples

```
KeyringCommandError new class name
>>> 'KeyringCommandError'
```

"
Class {
	#name : 'KeyringCommandError',
	#superclass : 'PharoKeyringError',
	#instVars : [
		'exitCode',
		'command'
	],
	#category : 'PharoKeyring',
	#package : 'PharoKeyring'
}

{ #category : 'accessing' }
KeyringCommandError >> command [
	^ command
]

{ #category : 'accessing' }
KeyringCommandError >> command: aString [
	command := aString
]

{ #category : 'accessing' }
KeyringCommandError >> exitCode [
	^ exitCode
]

{ #category : 'accessing' }
KeyringCommandError >> exitCode: anInteger [
	exitCode := anInteger
]

{ #category : 'accessing' }
KeyringCommandError >> messageText [
	^ 'Keyring command failed (exit code ', exitCode printString, '): ', (command ifNil: [ '<unknown>' ])
]
