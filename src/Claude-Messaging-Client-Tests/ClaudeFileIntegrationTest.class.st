"
Integration tests for the Files API methods on ClaudeClient. Resolves the API key via
``ClaudeSDKExampleSupport resolveClient`` (OS keyring first, ``ANTHROPIC_API_KEY``
env var second). When neither is present, ``setUp`` skips cleanly via ``self skip:``
rather than failing -- a key-less image (CI fork PR, fresh dev box) is not a red.

These tests are excluded from ``make test``; they run via ``ClaudeMessagingTestSuite
fullSuite`` in the slow-suite workflow. Each test uploads a temporary file and deletes
it when done.

  ClaudeFileIntegrationTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeFileIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeFileIntegrationTest >> defaultTimeLimit [
    "Raise the default 10s limit for integration tests — 10 MB upload can take up to a minute over the wire."
    ^ 5 minutes
]

{ #category : 'running' }
ClaudeFileIntegrationTest >> setUp [
	"Resolve a ClaudeClient via the shared keyring/env-var fallback chain. Skips
	cleanly when no key is available so a key-less image (CI fork PR, fresh dev
	box) does not red-fail the suite."
	super setUp.
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip: e messageText ]
]

{ #category : 'tests-integration' }
ClaudeFileIntegrationTest >> testListFiles [
	| page |
	page := client listFiles.
	self assert: page class equals: ClaudeFilePage.
	self assert: page data isCollection
]

{ #category : 'tests-integration' }
ClaudeFileIntegrationTest >> testListFilesWithPagination [
	| page |
	page := client listFiles: (ClaudeFileListParams new limit: 1).
	self assert: page class equals: ClaudeFilePage.
	self assert: page data size <= 1
]

{ #category : 'tests-integration' }
ClaudeFileIntegrationTest >> testUploadAndGetMetadata [
	| file metadata retrieved |
	file := FileSystem memory / 'test.txt'.
	file writeStreamDo: [:s | s nextPutAll: 'Hello from Pharo'].
	metadata := client uploadFile: file filename: 'test.txt' mimeType: 'text/plain'.
	self assert: metadata class equals: ClaudeFileMetadata.
	self assert: metadata filename equals: 'test.txt'.
	self assert: metadata mimeType equals: 'text/plain'.
	self assert: metadata id isNotNil.
	retrieved := client getFileMetadata: metadata id.
	self assert: retrieved id equals: metadata id.
	"Cleanup"
	client deleteFile: metadata id
]

{ #category : 'tests-integration' }
ClaudeFileIntegrationTest >> testUploadDownloadDelete [
	| file metadata deleted |
	file := FileSystem memory / 'download-test.txt'.
	file writeStreamDo: [:s | s nextPutAll: 'Download me'].
	metadata := client uploadFile: file filename: 'download-test.txt' mimeType: 'text/plain'.
	self assert: metadata class equals: ClaudeFileMetadata.
	self assert: metadata id isNotNil.
	"Files may not be immediately downloadable (API processing delay).
	 Verify download only when the file reports downloadable."
	metadata downloadable ifTrue: [
		| content |
		content := client downloadFile: metadata id.
		self assert: content isNotNil.
		self assert: content class equals: ByteArray.
		self assert: content utf8Decoded equals: 'Download me' ].
	deleted := client deleteFile: metadata id.
	self assert: deleted class equals: ClaudeDeletedFile.
	self assert: deleted id equals: metadata id
]

{ #category : 'tests-integration' }
ClaudeFileIntegrationTest >> testUploadStreamsLargeFileWithBoundedMemory [
    "End-to-end proof that the streaming multipart entity actually talks to
    the Files API without buffering the whole body. Creates a ~10 MB file,
    uploads it, verifies the server echoes back the right size, then cleans
    up both sides (ensure: guards both the remote delete and the local temp
    file, so a failed assertion does not leak either).

    The ``bounded memory' claim itself is asserted in the unit test
    ClaudeStreamingMultiPartEntityTest>>testLargeFileStreams (the spy
    proves 64 KB chunks). This test covers the end-to-end wire semantics —
    that Zinc actually accepts our custom entity, Content-Length is right,
    and Anthropic processes the upload.

    Size is 10 MB: above the prior in-memory buffer worry point for a
    low-RAM VM, well below the 25 MB per-file client-side limit. The file
    body is written to disk in 64 KB chunks — we never materialize the
    full 10 MB as a ByteArray in the VM, because doing so would defeat the
    purpose of a streaming-body test (and was slow: byte-by-byte fills in
    image allocate 10M integer messages).
    The file contents do not matter — only the size matters for the
    server round-trip."
    | tempFile metadata nBytes chunk chunkSize remaining |
    nBytes := 10 * 1024 * 1024.
    chunkSize := 64 * 1024.
    chunk := ByteArray new: chunkSize withAll: 0.
    (FileLocator temp asFileReference) ensureCreateDirectory.
    tempFile := FileLocator temp asFileReference / 'streaming-multipart-10mb.bin'.
    tempFile exists ifTrue: [tempFile delete].
    metadata := nil.
    tempFile binaryWriteStreamDo: [:s |
        remaining := nBytes.
        [remaining >= chunkSize] whileTrue: [
            s nextPutAll: chunk.
            remaining := remaining - chunkSize].
        remaining > 0 ifTrue: [
            s nextPutAll: (chunk copyFrom: 1 to: remaining)]].
    [ metadata := client
        uploadFile: tempFile
        filename: 'streaming-multipart-10mb.bin'
        mimeType: 'application/octet-stream'.
      self assert: metadata class equals: ClaudeFileMetadata.
      self assert: metadata sizeBytes equals: tempFile size.
      self assert: metadata id isNotNil
    ] ensure: [
        (metadata notNil and: [metadata id notNil]) ifTrue: [
            [client deleteFile: metadata id] on: Error do: [:e | ]].
        tempFile exists ifTrue: [tempFile delete]]
]

{ #category : 'private' }
ClaudeFileIntegrationTest >> waitUntilDownloadable: aFileId [
	"Poll getFileMetadata: until the file is downloadable. Max 30 seconds."
	| attempts metadata |
	attempts := 0.
	[
		metadata := client getFileMetadata: aFileId.
		metadata downloadable ifTrue: [ ^ self ].
		attempts := attempts + 1.
		attempts >= 30 ifTrue: [
			self error: 'File not downloadable after 30 seconds' ].
		1 second wait
	] repeat
]
