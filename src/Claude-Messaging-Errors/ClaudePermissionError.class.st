"
Signaled when the API returns HTTP 403 — insufficient permissions for the requested resource.

### Examples

```
(ClaudeApiError fromStatusCode: 403 json: '{}' requestId: 'r1') class
>>> ClaudePermissionError
```

"
Class {
	#name : 'ClaudePermissionError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
