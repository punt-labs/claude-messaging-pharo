"
A ``container_upload`` content block -- the confirmation that Claude uploaded a file into the code-execution container during generation.

### When you see it

When a request enables code execution (``betas: #('code-execution-2025-08-25')`` plus ``container`` config on ``ClaudeContainerParams``) and Claude produces a file as part of its work (a chart it rendered, a CSV it computed, a PDF it generated), the response content stream includes a ``ClaudeContainerUploadBlock`` so your client can retrieve the file via the Files API. Sibling of ``ClaudeCodeExecutionResultBlock`` (the code-interpreter output) -- containers carry the runtime, upload blocks carry the artifacts.

### Accessors

- ``type`` -- always ``'container_upload'``
- ``fileId`` -- the Files API id of the uploaded artifact; hand this to ``ClaudeClient >> downloadFile:`` or ``ClaudeClient >> getFileMetadata:`` to retrieve or inspect it
- ``rawJson`` -- the full server payload

### Example

```
ClaudeContainerUploadBlock new type
>>> 'container_upload'
```

```
| block |
block := ClaudeContainerUploadBlock fromJson: (Dictionary newFromPairs: {
    'type'. 'container_upload'.
    'file_id'. 'file-abc' }).
block fileId
>>> 'file-abc'
```

### See also

``ClaudeCodeExecutionExample`` -- runnable demonstration of code execution; the returned message's ``content`` holds the container-upload blocks. ``ClaudeFileMetadata`` -- the response object returned by ``getFileMetadata:`` after you pick up ``fileId`` from here.

"
Class {
	#name : 'ClaudeContainerUploadBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeContainerUploadBlock class >> fromJson: aDictionary [
  ^ self new
    type: (aDictionary at: 'type' ifAbsent: [ 'container_upload' ]);
    rawJson: aDictionary copy;
    yourself
]

{ #category : 'persistence' }
ClaudeContainerUploadBlock class >> fromSton: stonReader [
  | dict raw |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
  ^ self fromJson: raw
]

{ #category : 'json' }
ClaudeContainerUploadBlock >> asJson [
  ^ rawJson ifNil: [
    OrderedDictionary new
      at: 'type' put: 'container_upload';
      yourself ]
]

{ #category : 'accessing' }
ClaudeContainerUploadBlock >> fileId [
  ^ rawJson at: 'file_id' ifAbsent: [ nil ]
]

{ #category : 'initialization' }
ClaudeContainerUploadBlock >> initialize [
  super initialize.
  type := 'container_upload'
]

{ #category : 'persistence' }
ClaudeContainerUploadBlock >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawJson put: rawJson ]
]
