"
Signaled when the API returns HTTP 429 — rate limit exceeded. Check retryAfter for the Retry-After header value.

### Examples

```
(ClaudeApiError fromStatusCode: 429 json: '{}' requestId: 'r1') class
>>> ClaudeRateLimitError
```

"
Class {
	#name : 'ClaudeRateLimitError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
