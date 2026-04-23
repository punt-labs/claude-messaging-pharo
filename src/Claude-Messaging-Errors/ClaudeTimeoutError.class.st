"
Signaled when the API returns HTTP 408 (request timeout) or 504 (gateway timeout).

### Examples

```
(ClaudeApiError fromStatusCode: 408 json: '{}' requestId: 'r1') class
>>> ClaudeTimeoutError
```

"
Class {
	#name : 'ClaudeTimeoutError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
