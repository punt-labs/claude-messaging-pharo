"
Signaled when the API returns HTTP 401 — invalid or missing API key.

### Examples

```
(ClaudeApiError fromStatusCode: 401 json: '{}' requestId: 'r1') class
>>> ClaudeAuthError
```

"
Class {
	#name : 'ClaudeAuthError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
