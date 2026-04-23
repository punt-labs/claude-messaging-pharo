"
Signaled when a network-level failure occurs that is NOT a timeout. This includes connection refusals (server down or port closed), closed sockets (peer reset), TLS handshake failures, and DNS resolution errors. Unlike timeouts these failures are not transient — a refused connection will stay refused until the upstream condition changes — so isRetryable returns false and the error propagates to the caller on the first occurrence.

Status code 599 is a non-standard code used by HAProxy, Nginx, and curl for client-side network errors that are NOT true HTTP timeouts. We adopt it to distinguish these errors from 408 (which is retryable) in printOn: output and log lines.

### Examples

```
ClaudeNetworkError new isRetryable
>>> false

ClaudeNetworkError new statusCode: 599; yourself
>>> ClaudeNetworkError(599 )

ClaudeNetworkError superclass
>>> ClaudeApiError
```

"
Class {
	#name : 'ClaudeNetworkError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}

{ #category : 'testing' }
ClaudeNetworkError >> isRetryable [
	"Network connect errors (refused, closed, TLS handshake) are not transient.
	 Retrying will hit the same condition. Return false so the retry machinery
	 propagates the error to the caller on first occurrence."

	^ false
]
