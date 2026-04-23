"
Suite factory for the Claude Messaging SDK — the API client layer. Aggregates the 9 `Claude-Messaging-*-Tests` packages: Types, Errors, Streaming, Client, Files, MCP, Skills, Tools, Examples. Has no dependency on any Agent-layer test package.

Use this factory when you only need the Messaging SDK tests. For the combined cross-product suite, see `ClaudeTestSuite`.

## Example

	ClaudeMessagingTestSuite packageNames size
	>>> 9

	ClaudeMessagingTestSuite suite class
	>>> TestSuite

	ClaudeMessagingTestSuite fastSuite run  ""a TestResult (N tests, 0 failures, 0 errors)""

"
Class {
	#name : 'ClaudeMessagingTestSuite',
	#superclass : 'ClaudeAbstractTestSuite',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeMessagingTestSuite class >> packageNames [
	"Answer the 9 Messaging SDK test package names."
	^ #(
		'Claude-Messaging-Types-Tests'
		'Claude-Messaging-Errors-Tests'
		'Claude-Messaging-Streaming-Tests'
		'Claude-Messaging-Client-Tests'
		'Claude-Messaging-Files-Tests'
		'Claude-Messaging-MCP-Tests'
		'Claude-Messaging-Skills-Tests'
		'Claude-Messaging-Tools-Tests'
		'Claude-Messaging-Examples-Tests'
	)
]

{ #category : 'accessing' }
ClaudeMessagingTestSuite class >> suiteLabel [
	^ 'Claude Messaging SDK Tests'
]
