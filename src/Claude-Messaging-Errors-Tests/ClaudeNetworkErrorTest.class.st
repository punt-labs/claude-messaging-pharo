"
Tests for ClaudeNetworkError — the non-timeout network error wrapper signaled for connection refusals, closed sockets, TLS failures, and other non-transient network failures. See bead i7uc.

  ClaudeNetworkErrorTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeNetworkErrorTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Errors-Tests',
	#package : 'Claude-Messaging-Errors-Tests'
}

{ #category : 'tests' }
ClaudeNetworkErrorTest >> testClaudeNetworkErrorIsAClaudeApiError [
	"ClaudeNetworkError must be catchable via on: ClaudeApiError do: so the
	 retry loop and any caller-level catch-alls handle it uniformly with
	 every other API error. Asserts the behavioral relationship rather than
	 the direct superclass — this stays correct if a future refactoring
	 inserts an intermediate class (e.g., ClaudeTransportError) between
	 ClaudeApiError and ClaudeNetworkError."

	self assert: (ClaudeNetworkError includesBehavior: ClaudeApiError)
]

{ #category : 'tests' }
ClaudeNetworkErrorTest >> testClaudeNetworkErrorIsNotRetryable [
	"Connection refusals and closed sockets are not transient — retrying
	 will hit the same condition. ClaudeNetworkError must report as
	 non-retryable so executeWithRetry: short-circuits and propagates
	 the error to the caller on the first occurrence."

	self deny: ClaudeNetworkError new isRetryable.
	self deny: (ClaudeNetworkError new statusCode: 599; yourself) isRetryable
]
