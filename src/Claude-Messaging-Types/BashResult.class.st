"
Value object capturing the result of a shell command execution.

Holds the original command string, the integer exit code, the combined stdout+stderr output, and a flag indicating whether the command was killed by the timeout wrapper. Provides convenience predicates for success/error checking.

The timedOut flag disambiguates exit code 1 from a timeout-kill. Without it, a grep that exited 1 because it found no match is indistinguishable in the audit log from a command that ran too long and was killed. Default is false so pre-existing code paths remain correct.

	BashResult command: 'echo hi' exitCode: 0 output: 'hi'
	>>> BashResult(exit=0)

	| r | r := BashResult command: 'sleep 10' exitCode: 1 output: ''.
	r timedOut: true.
	r timedOut
	>>> true
"
Class {
	#name : 'BashResult',
	#superclass : 'Object',
	#instVars : [
		'command',
		'exitCode',
		'output',
		'timedOut'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
BashResult class >> command: commandString exitCode: anInteger output: outputString [
	^ self new
		command: commandString;
		exitCode: anInteger;
		output: outputString;
		yourself
]

{ #category : 'accessing' }
BashResult >> command [
	^ command
]

{ #category : 'accessing' }
BashResult >> command: aString [
	command := aString
]

{ #category : 'accessing' }
BashResult >> exitCode [
	^ exitCode
]

{ #category : 'accessing' }
BashResult >> exitCode: anInteger [
	exitCode := anInteger
]

{ #category : 'initialization' }
BashResult >> initialize [
	"Initialize timedOut to false so the slot holds the default value
	directly instead of relying on an accessor fallback. The timedOut
	disambiguation between a timeout-kill and a legitimate exit-code-1
	result is a core contract of BashResult — the slot should carry
	the default, not a nil that the accessor papers over."
	super initialize.
	timedOut := false
]

{ #category : 'testing' }
BashResult >> isError [
	^ exitCode ~= 0
]

{ #category : 'testing' }
BashResult >> isSuccess [
	^ exitCode = 0
]

{ #category : 'accessing' }
BashResult >> output [
	^ output
]

{ #category : 'accessing' }
BashResult >> output: aString [
	output := aString
]

{ #category : 'printing' }
BashResult >> printOn: aStream [
	aStream
		nextPutAll: 'BashResult(';
		nextPutAll: 'exit=';
		print: exitCode.
	self timedOut ifTrue: [ aStream nextPutAll: ' timedOut' ].
	aStream nextPutAll: ')'
]

{ #category : 'accessing' }
BashResult >> timedOut [
	^ timedOut
]

{ #category : 'accessing' }
BashResult >> timedOut: aBoolean [
	timedOut := aBoolean
]
