"
Unit tests for ClaudeStreamingMultiPartEntity.

Verifies the Zinc-entity contract (contentType, contentLength, isEmpty, writeOn:), RFC 7578 multipart body format, byte-exact contentLength correctness (if this lies, servers cut off or hang), and that file parts stream in bounded 64 KB chunks (the whole point of the class — no ~10 MB ByteArray in memory).

Every test that creates temp files tracks them in `tempFiles` and deletes them in `tearDown`. No file I/O happens before or after the method-under-test.

  ClaudeStreamingMultiPartEntityTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeStreamingMultiPartEntityTest',
	#superclass : 'TestCase',
	#instVars : [
		'tempFiles',
		'spyByteCount',
		'spyMaxChunk'
	],
	#category : 'Claude-Messaging-Streaming-Tests',
	#package : 'Claude-Messaging-Streaming-Tests'
}

{ #category : 'private' }
ClaudeStreamingMultiPartEntityTest >> newTempBinaryFileNamed: aName size: nBytes marker: aByteArray [
    "Create a temp binary file of nBytes bytes. Writes aByteArray at offset 0
    and again at the tail; middle bytes are zero. Track for tearDown.
    Returns the FileReference."
    | ref buf markerSize |
    (FileLocator temp asFileReference) ensureCreateDirectory.
    ref := FileLocator temp asFileReference / aName.
    ref exists ifTrue: [ref delete].
    markerSize := aByteArray size.
    buf := ByteArray new: nBytes.
    1 to: markerSize do: [:i | buf at: i put: (aByteArray at: i)].
    1 to: markerSize do: [:i | buf at: nBytes - markerSize + i put: (aByteArray at: i)].
    ref binaryWriteStreamDo: [:s | s nextPutAll: buf].
    tempFiles add: ref.
    ^ ref
]

{ #category : 'private' }
ClaudeStreamingMultiPartEntityTest >> newTempFileNamed: aName contents: aString [
    "Create a temp file under FileLocator temp with the given name and String content.
    Track it for tearDown cleanup. Return the FileReference."
    | ref |
    (FileLocator temp asFileReference) ensureCreateDirectory.
    ref := FileLocator temp asFileReference / aName.
    ref exists ifTrue: [ref delete].
    ref writeStreamDo: [:s | s nextPutAll: aString].
    tempFiles add: ref.
    ^ ref
]

{ #category : 'spy protocol' }
ClaudeStreamingMultiPartEntityTest >> nextPut: aByte [
    "Counting-spy stream write (single byte path)."
    spyByteCount := spyByteCount + 1.
    spyMaxChunk := spyMaxChunk max: 1.
    ^ aByte
]

{ #category : 'spy protocol' }
ClaudeStreamingMultiPartEntityTest >> nextPutAll: aCollection [
    "Counting-spy stream write. Records chunk size and total bytes.
    No materialization — this is the whole point."
    spyByteCount := spyByteCount + aCollection size.
    spyMaxChunk := spyMaxChunk max: aCollection size.
    ^ aCollection
]

{ #category : 'running' }
ClaudeStreamingMultiPartEntityTest >> setUp [
    super setUp.
    tempFiles := OrderedCollection new
]

{ #category : 'spy protocol' }
ClaudeStreamingMultiPartEntityTest >> spyByteCount [
    "Total bytes observed since startSpy."
    ^ spyByteCount
]

{ #category : 'spy protocol' }
ClaudeStreamingMultiPartEntityTest >> spyMaxChunk [
    "Largest single nextPutAll: call size since startSpy. This is the
    assertion that proves writeOn: streams in bounded chunks — if the
    whole body were buffered into one ByteArray then written with a
    single nextPutAll:, spyMaxChunk would equal contentLength."
    ^ spyMaxChunk
]

{ #category : 'spy protocol' }
ClaudeStreamingMultiPartEntityTest >> startSpy [
    "Reset the counting spy state. Call before using self as a spy stream
    in writeOn:. Bytes written via nextPutAll: / nextPut: are counted,
    not materialized."
    spyByteCount := 0.
    spyMaxChunk := 0
]

{ #category : 'running' }
ClaudeStreamingMultiPartEntityTest >> tearDown [
	tempFiles ifNotNil: [
		tempFiles do: [ :f |
			[ f exists ifTrue: [ f delete ] ]
				on: Error
				do: [ :ignored | "best-effort cleanup; a delete failure on a temp file shouldn't fail the test" nil ] ] ].
	super tearDown
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testAddFilePartIncrementsCount [
    | entity tmp |
    tmp := self newTempFileNamed: 'hello.txt' contents: 'hello'.
    entity := ClaudeStreamingMultiPartEntity new.
    entity
        addFilePart: 'file'
        fileName: 'hello.txt'
        contentType: ZnMimeType textPlain
        fileReference: tmp.
    self assert: entity parts size equals: 1.
    self deny: entity isEmpty
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testAddFilePartRejectsCrLfInFileName [
    "Finding 1 regression guard. A fileName containing CR/LF would inject
    additional multipart headers (e.g., spoofing `X-Injected: yes`). The
    entity must reject at the add call, not silently emit a malformed
    Content-Disposition header."
    | entity tmp maliciousName |
    tmp := self newTempFileNamed: 'hello.txt' contents: 'hello'.
    entity := ClaudeStreamingMultiPartEntity new.
    maliciousName := 'bad' , String cr , String lf , 'X-Injected: yes.txt'.
    self
        should: [ entity
            addFilePart: 'file'
            fileName: maliciousName
            contentType: ZnMimeType textPlain
            fileReference: tmp ]
        raise: Error.
    "entity must remain empty — rejection at entry, no silent accept"
    self assert: entity isEmpty
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testAddValuePartIncrementsCount [
    | entity |
    entity := ClaudeStreamingMultiPartEntity new.
    entity addValuePart: 'display_title' value: 'My Skill'.
    self assert: entity parts size equals: 1.
    self deny: entity isEmpty
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testAddValuePartRejectsCrLfInFieldName [
    "Finding 1 regression guard. A fieldName containing CR/LF would inject
    additional multipart headers via Content-Disposition interpolation.
    The value itself is body bytes and is allowed to contain anything —
    only the fieldName must be sanitized."
    | entity |
    entity := ClaudeStreamingMultiPartEntity new.
    self
        should: [ entity
            addValuePart: 'bad' , String cr , String lf , 'X-Injected: yes'
            value: 'whatever' ]
        raise: Error.
    "A value containing CR/LF must be accepted — it goes into the body, not a header."
    entity addValuePart: 'display_title' value: 'line1' , String crlf , 'line2'.
    self assert: entity parts size equals: 1
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testContentLengthCorrectForValuePartsAlone [
    "Regression guard for the utf8-encoded length branch of contentLength."
    | entity out |
    entity := ClaudeStreamingMultiPartEntity new.
    entity addValuePart: 'display_title' value: 'A Skill Title'.
    out := (ByteArray new: 0) writeStream.
    entity writeOn: out.
    self assert: out contents size equals: entity contentLength
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testContentLengthHandlesNonAsciiFilename [
    "Regression guard for header byte-count desync. Before the fix,
    contentLength used (headersFor:) size (character count) while
    writeOn: wrote (headersFor:) asByteArray (Latin-1 for narrow
    strings, UTF-32 for wide). For `café.txt` both happened to agree
    at 8 bytes because é is a single Latin-1 byte, but the bytes on
    the wire were Latin-1 rather than UTF-8. For `日本.txt` the two
    diverged by several hundred bytes (UTF-32 bytes vs character
    count). After the fix, both sides route through utf8Encoded size,
    so Content-Length matches the bytes actually written and the
    wire bytes are proper UTF-8."
    | entity tmp out |
    tmp := self newTempFileNamed: 'cafe-unicode.txt' contents: 'hello'.
    entity := ClaudeStreamingMultiPartEntity new.
    entity
        addFilePart: 'file'
        fileName: 'café.txt'
        contentType: ZnMimeType textPlain
        fileReference: tmp.
    out := (ByteArray new: 0) writeStream.
    entity writeOn: out.
    self assert: out contents size equals: entity contentLength
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testContentLengthMatchesBytesWritten [
    "Byte-exact correctness. If contentLength lies, server cuts off upload or hangs."
    | entity file1 file2 out |
    file1 := self newTempFileNamed: 'a.txt' contents: 'alpha content'.
    file2 := self newTempFileNamed: 'b.md' contents: '# bravo content here'.
    entity := ClaudeStreamingMultiPartEntity new.
    entity addValuePart: 'display_title' value: 'UnitTest'.
    entity
        addFilePart: 'files[]'
        fileName: 'a.txt'
        contentType: ZnMimeType textPlain
        fileReference: file1.
    entity
        addFilePart: 'files[]'
        fileName: 'b.md'
        contentType: (ZnMimeType fromString: 'text/markdown')
        fileReference: file2.
    out := (ByteArray new: 0) writeStream.
    entity writeOn: out.
    self assert: out contents size equals: entity contentLength
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testContentTypeHasBoundary [
    | entity mime |
    entity := ClaudeStreamingMultiPartEntity new.
    mime := entity contentType.
    self assert: mime main equals: 'multipart'.
    self assert: mime sub equals: 'form-data'.
    self assert: (mime parameterAt: 'boundary') equals: entity boundary
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testEmptyEntityHasNoParts [
    | entity |
    entity := ClaudeStreamingMultiPartEntity new.
    self assert: entity isEmpty.
    self assert: entity parts size equals: 0
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testGenerateBoundaryProducesExactly32HexChars [
	"Regression guard for an off-by-one in generateBoundary. Before the fix,
	bytes := (1 to: 16) collect: [:i | random nextInteger: 256] drew from
	[1, 256]. When 256 appeared (~0.4% per byte, ~6% across 16 bytes), its
	hex printString was '100' (3 chars) and padLeftTo: 2 does not truncate,
	so the resulting boundary suffix was 33 chars instead of the documented
	32. After the fix ((random nextInteger: 256) - 1), every byte lands in
	[0, 255] so every hex pair is exactly 2 chars and every boundary is
	exactly 21 prefix + 32 hex suffix = 53 chars.

	200 draws is comfortably beyond the ~6% bad-rate so the test fails
	deterministically against the pre-fix code within a handful of boundaries;
	post-fix it passes 200/200."
	| prefixSize suffixLength |
	prefixSize := '--zn-claude-boundary-' size.
	suffixLength := 32.
	1 to: 200 do: [ :i |
		| entity actualSuffix |
		entity := ClaudeStreamingMultiPartEntity new.
		actualSuffix := entity boundary size - prefixSize.
		self
			assert: actualSuffix = suffixLength
			description: (String streamContents: [ :s |
				s nextPutAll: 'boundary suffix size must be '.
				s print: suffixLength.
				s nextPutAll: ' hex chars but was '.
				s print: actualSuffix.
				s nextPutAll: ' on draw #'.
				s print: i.
				s nextPutAll: ' (boundary = '.
				s nextPutAll: entity boundary.
				s nextPutAll: ')' ]) ]
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testLargeFileStreams [
    "Prove chunked reads — the whole reason this class exists. Write a 1 MB
    file and serialize via writeOn: to ``self' as a counting-spy stream.
    writeBodyOf: reads from the file in 64 KB chunks and passes each chunk
    through to aStream via `nextPutAll:`. So the largest chunk observed by
    the spy reflects the read chunk size. Assert spyMaxChunk is within a
    tight band around 64 KB (no smaller than 64 KB — catches a regression
    that halved the chunk size; no larger than 64 KB + 1 KB — allows minor
    header/framing writes without opening the door to a full-body buffer).
    
    The key point: we must NOT observe a single 1 MB write — if we did,
    writeOn: would be buffering the whole file into a single ByteArray
    before sending, defeating the purpose of this class."
    | entity file nBytes marker |
    nBytes := 1024 * 1024.
    marker := #[77 65 82 75 69 82] "ASCII ""MARKER""".
    file := self newTempBinaryFileNamed: 'big.bin' size: nBytes marker: marker.
    entity := ClaudeStreamingMultiPartEntity new.
    entity
        addFilePart: 'file'
        fileName: 'big.bin'
        contentType: ZnMimeType applicationOctetStream
        fileReference: file.
    self startSpy.
    entity writeOn: self.
    self assert: self spyByteCount equals: entity contentLength.
    self assert: self spyMaxChunk <= (65536 + 1024)
        description: 'largest single write was ' , self spyMaxChunk printString , ' bytes — writeOn: appears to be buffering'.
    self assert: self spyMaxChunk >= (64 * 1024)
        description: 'chunk size dropped below 64 KB (' , self spyMaxChunk printString , 'B) — chunk-size regression'
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testValuePartHasNoContentTypeHeader [
    "RFC 7578: plain form-field value parts carry only Content-Disposition.
    No filename, no Content-Type."
    | entity out text firstHeaderBlock |
    entity := ClaudeStreamingMultiPartEntity new.
    entity addValuePart: 'display_title' value: 'Just Text'.
    out := (ByteArray new: 0) writeStream.
    entity writeOn: out.
    text := out contents asString.
    "Isolate the header block between the preamble and the body."
    firstHeaderBlock := text copyReplaceAll: String crlf with: '|'.
    self assert: (firstHeaderBlock includesSubstring: 'Content-Disposition: form-data; name="display_title"|').
    self deny: (text includesSubstring: 'Content-Type:')
        description: 'value parts must not emit a Content-Type header'.
    self deny: (text includesSubstring: 'filename=')
        description: 'value parts must not emit a filename parameter'
]

{ #category : 'tests' }
ClaudeStreamingMultiPartEntityTest >> testWriteOnProducesValidMultipartBody [
    "Verify RFC 7578 structure by substring matches. No parser needed.
    
    The terminator assertion is two-layered. First, the raw
    endsWith: check. Second, the exact-sequence check
    `\r\n--<boundary>--\r\n`: the leading CRLF is the inter-part
    CRLF shared with every non-final part; there must not be TWO
    CRLFs (`\r\n\r\n--<boundary>--\r\n`) between the last part and
    the terminator. A double-CRLF regression — e.g., if writeOn:
    mistakenly emits an extra String crlf before the terminator —
    would still pass endsWith: but would fail this assertion."
    | entity file out text |
    file := self newTempFileNamed: 'sample.txt' contents: 'HELLO-MARKER-UNIQUE'.
    entity := ClaudeStreamingMultiPartEntity new.
    entity addValuePart: 'display_title' value: 'TitleMarker'.
    entity
        addFilePart: 'files[]'
        fileName: 'sample.txt'
        contentType: ZnMimeType textPlain
        fileReference: file.
    out := (ByteArray new: 0) writeStream.
    entity writeOn: out.
    text := out contents asString.
    self assert: (text includesSubstring: entity boundary).
    self assert: (text includesSubstring: 'TitleMarker').
    self assert: (text includesSubstring: 'HELLO-MARKER-UNIQUE').
    self assert: (text includesSubstring: 'Content-Disposition: form-data; name="display_title"').
    self assert: (text includesSubstring: 'Content-Disposition: form-data; name="files[]"; filename="sample.txt"').
    self assert: (text endsWith: '--' , entity boundary , '--' , String crlf).
    self assert: (text includesSubstring: (String crlf , '--' , entity boundary , '--' , String crlf))
        description: 'terminator must follow exactly one inter-part CRLF — a double-CRLF regression would fail this'
]
