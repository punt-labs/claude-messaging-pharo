"
Tests for ClaudeBatchNotEndedError — pins ClaudeApiError parentage, signal, and default message.

  ClaudeBatchNotEndedErrorTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchNotEndedErrorTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchNotEndedErrorTest >> testIsClaudeApiErrorSubclass [
	self assert: (ClaudeBatchNotEndedError inheritsFrom: ClaudeApiError)
]

{ #category : 'tests' }
ClaudeBatchNotEndedErrorTest >> testSignalCarriesMessage [
	"signal sets a default message describing the cause."
	| caught |
	caught := [ ClaudeBatchNotEndedError signal ]
		on: ClaudeApiError do: [ :e | e message ].
	self assert: (caught includesSubstring: 'ended')
]

{ #category : 'tests' }
ClaudeBatchNotEndedErrorTest >> testSignalRaisesAsClaudeApiError [
	"Catching the base class catches this subclass — the design promise."
	| caught |
	caught := [ ClaudeBatchNotEndedError signal ]
		on: ClaudeApiError do: [ :e | e class ].
	self assert: caught equals: ClaudeBatchNotEndedError
]
