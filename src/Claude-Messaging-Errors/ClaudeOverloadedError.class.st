"
Signaled when the API returns HTTP 529 — the API is temporarily overloaded.

### Examples

```
(ClaudeApiError fromStatusCode: 529 json: '{}' requestId: 'r1') class
>>> ClaudeOverloadedError
```

"
Class {
	#name : 'ClaudeOverloadedError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
