"
A streaming `multipart/form-data` request entity for Claude API uploads.

This class exists because Pharo Zinc's `ZnMultiPartFormDataEntity>>writeOn:` materializes the entire multipart body into a `ByteArray` (via `computeRepresentation`) before the first byte hits the socket. For the 25 MB-per-file / 100 MB-total skill uploads, that means the whole body lives in memory twice (once as the collection of per-part ByteArray entities, once as the concatenated body). Mirrors the precedent of `ClaudeStreamingSocket` — that class is the project's existing answer to Zinc buffering responses; this one is the mirror answer for request bodies.

**How it differs from `ZnMultiPartFormDataEntity`.** The standard class buffers every part into a single `ByteArray` before writing. This class holds file parts as `{fieldName, fileName, contentType, fileReference}` records and opens each file's read stream only during `writeOn:`, streaming 64 KB chunks from disk straight to the socket. `contentLength` is computed analytically — boundary framing + header bytes + file size (from `FileReference size`, one stat call) + terminator — so Zinc sends a correct Content-Length header without reading a byte of body.

**Part shapes.** Two kinds:

- *File parts*: from `addFilePart:fileName:contentType:fileReference:`. Carries `Content-Disposition: form-data; name=""...""; filename=""...""` + `Content-Type: ...`, body is raw file bytes.
- *Value parts*: from `addValuePart:value:`. Carries `Content-Disposition: form-data; name=""...""` only (no filename, no Content-Type per RFC 7578), body is UTF-8 encoded String.

**Usage.**

```
ClaudeStreamingMultiPartEntity new isEmpty
>>> true

| entity |
entity := ClaudeStreamingMultiPartEntity new.
entity addValuePart: 'display_title' value: 'My skill'.
entity isEmpty
>>> false
```

**Zinc contract.** Subclass of `ZnEntity`. Implements the four methods Zinc's HTTP client calls on any body entity: `contentType` (set in `initialize`, returns `multipart/form-data;boundary=...`), `contentLength` (computed on demand from multipart framing, header bytes, and current part/file sizes, without reading body bytes into memory), `writeOn:` (streams from disk), `isEmpty` (parts empty?). Also implements `designatedMimeType` class-side so the dispatch loop in `ZnEntity class>>concreteSubclassForType:binary:` does not raise `subclassResponsibility` when Pharo parses an incoming request with ANY content type.

**Header injection.** `addFilePart:...` and `addValuePart:...` reject CR, LF, or NUL in the identifier fields (fieldName, fileName, mimeType printString). Any of those bytes would allow a caller to inject additional headers via interpolation into `Content-Disposition` / `Content-Type`. Value bodies are unrestricted — they go into the body, not a header.

**Boundary.** Random 32-char hex prefixed with `--zn-claude-boundary-`. 2^128 space — multipart spec allows probabilistic collision; no file scanning for collision.

**RFC 7578 terminator note.** The sequence after the last part's body is `\r\n` (inter-part CRLF) then `--<boundary>--\r\n` (terminator). The leading `\r\n` on the terminator is that same inter-part CRLF — do not emit an additional one.

See `ClaudeFileIntegrationTest>>testUploadStreamsLargeFileWithBoundedMemory` for the end-to-end 10 MB upload test.

"
Class {
	#name : 'ClaudeStreamingMultiPartEntity',
	#superclass : 'ZnEntity',
	#instVars : [
		'parts',
		'boundary'
	],
	#category : 'Claude-Messaging-Streaming',
	#package : 'Claude-Messaging-Streaming'
}

{ #category : 'testing' }
ClaudeStreamingMultiPartEntity class >> designatedMimeType [
    "Designated MIME type for concreteSubclassForType:binary: lookup. Matches ZnMultiPartFormDataEntity."
    ^ ZnMimeType multiPartFormData
]

{ #category : 'accessing' }
ClaudeStreamingMultiPartEntity >> addFilePart: fieldName fileName: fileName contentType: mimeType fileReference: aFileRef [
    "Add a file part that will be streamed from disk during writeOn:.
    The file is NOT opened or read here — only at writeOn: time. Size is
    computed from the FileReference (one stat call per file, no body I/O).
    Caller is responsible for ensuring aFileRef exists and is readable at
    writeOn: time.

    Rejects CR, LF, or NUL in fieldName, fileName, or the printed mimeType
    — any of which would allow a caller to inject additional multipart
    headers via Content-Disposition / Content-Type interpolation."
    self rejectCrLfOrNul: fieldName in: 'fieldName'.
    self rejectCrLfOrNul: fileName in: 'fileName'.
    self rejectCrLfOrNul: mimeType printString in: 'contentType'.
    parts add: (Dictionary new
        at: #kind put: #file;
        at: #fieldName put: fieldName;
        at: #fileName put: fileName;
        at: #contentType put: mimeType;
        at: #fileReference put: aFileRef;
        yourself).
    ^ self
]

{ #category : 'accessing' }
ClaudeStreamingMultiPartEntity >> addValuePart: fieldName value: aString [
    "Add a plain form-field value part (e.g., `display_title`). The value is
    UTF-8 encoded at writeOn: time. No Content-Type header is emitted for
    value parts per RFC 7578.

    Rejects CR, LF, or NUL in fieldName — any of which would allow a caller
    to inject additional multipart headers via Content-Disposition
    interpolation. The value itself is unrestricted; it goes into the body,
    not a header."
    self rejectCrLfOrNul: fieldName in: 'fieldName'.
    parts add: (Dictionary new
        at: #kind put: #value;
        at: #fieldName put: fieldName;
        at: #value put: aString;
        yourself).
    ^ self
]

{ #category : 'accessing' }
ClaudeStreamingMultiPartEntity >> boundary [
    "The multipart boundary string. Generated in initialize."
    ^ boundary
]

{ #category : 'accessing' }
ClaudeStreamingMultiPartEntity >> contentLength [
    "Compute the byte-exact length of the serialized multipart body.
    This is what Zinc sends as the Content-Length header — if it lies,
    the server either truncates the upload or hangs waiting for more
    bytes. Must match writeOn: byte-for-byte.
    
    All framing math goes through utf8Encoded size so the count
    matches the bytes written (which also go through utf8Encoded).
    CRLF and ASCII boundaries are 1 byte/char regardless of encoder,
    but routing through the same encoder keeps the invariant obvious
    and catches any future non-ASCII slip (e.g., a filename with é).
    
    Structure per part: `--<boundary>\r\n` + headers + body + `\r\n`.
    Plus the final terminator `--<boundary>--\r\n`."
    | total boundaryLine terminator |
    boundaryLine := '--' , boundary , String crlf.
    terminator := '--' , boundary , '--' , String crlf.
    total := 0.
    parts do: [:part |
        total := total + boundaryLine utf8Encoded size.
        total := total + (self headersFor: part) utf8Encoded size.
        total := total + (self partBodyLengthOf: part).
        total := total + String crlf utf8Encoded size ].
    total := total + terminator utf8Encoded size.
    ^ total
]

{ #category : 'initialization' }
ClaudeStreamingMultiPartEntity >> generateBoundary [
    "Generate a random 32-char hex boundary prefixed with --zn-claude-boundary-.
    Uses Random new for a simple non-cryptographic multipart boundary.
    Subtracts 1 from nextInteger: 256 so bytes land in [0, 255] — the correct
    byte space. Without the subtraction, nextInteger: 256 returns [1, 256] and
    a 256 draw (~0.4% per byte, ~6% across 16 bytes) encodes as '100' (3 hex
    chars), breaking the 32-char hex claim."
    | random bytes hex |
    random := Random new.
    bytes := (1 to: 16) collect: [:i | (random nextInteger: 256) - 1].
    hex := String streamContents: [:s |
        bytes do: [:b | s nextPutAll: ((b printStringBase: 16) padLeftTo: 2 with: $0) asLowercase]].
    ^ '--zn-claude-boundary-' , hex
]

{ #category : 'private' }
ClaudeStreamingMultiPartEntity >> headersFor: aPart [
    "Build the header block for a single part. Returns a String ending in
    the double CRLF that separates headers from body; the String is
    intended to be UTF-8 encoded when written, so header values are not
    necessarily ASCII-only.
    Two shapes: file parts carry filename + Content-Type; value parts
    carry only Content-Disposition."
    | quotedFileName |
    ^ String streamContents: [:s |
        s nextPutAll: 'Content-Disposition: form-data; name="'.
        s nextPutAll: (aPart at: #fieldName).
        s nextPut: $".
        (aPart at: #kind) = #file ifTrue: [
            quotedFileName := (aPart at: #fileName) copyReplaceAll: '"' with: '\"'.
            s nextPutAll: '; filename="'.
            s nextPutAll: quotedFileName.
            s nextPut: $".
            s nextPutAll: String crlf.
            s nextPutAll: 'Content-Type: '.
            s nextPutAll: (aPart at: #contentType) printString ].
        s nextPutAll: String crlf; nextPutAll: String crlf]
]

{ #category : 'initialization' }
ClaudeStreamingMultiPartEntity >> initialize [
    super initialize.
    parts := OrderedCollection new.
    boundary := self generateBoundary.
    contentType := (ZnMimeType main: 'multipart' sub: 'form-data') parameterAt: 'boundary' put: boundary; yourself
]

{ #category : 'testing' }
ClaudeStreamingMultiPartEntity >> isEmpty [
    "True when no parts have been added. Required override of ZnEntity subclassResponsibility."
    ^ parts isEmpty
]

{ #category : 'private' }
ClaudeStreamingMultiPartEntity >> partBodyLengthOf: aPart [
    "Return the byte length of a single part's body (excluding headers
    and framing). For file parts this is the on-disk file size. For value
    parts this is the UTF-8 encoded String length."
    (aPart at: #kind) = #file
        ifTrue: [ ^ (aPart at: #fileReference) size ].
    ^ (aPart at: #value) utf8Encoded size
]

{ #category : 'accessing' }
ClaudeStreamingMultiPartEntity >> parts [
    "Answer the collection of parts added to this entity. Each part is a
    Dictionary tagged with #kind (#file or #value) and the corresponding
    shape-specific keys. Exposed for testing and inspection only — callers
    should use addFilePart:... and addValuePart:... to construct the entity."
    ^ parts
]

{ #category : 'private' }
ClaudeStreamingMultiPartEntity >> rejectCrLfOrNul: aString in: fieldLabel [
    "Reject header-plane strings containing CR, LF, or NUL — any of which
    would inject or truncate additional multipart headers when interpolated
    into Content-Disposition / Content-Type. Defence in depth: in-SDK
    callers (Files API basename, Skills POSIX names, display_title) do not
    typically carry these bytes, but the class lives in
    Claude-Messaging-Streaming and may be reused. Raise immediately so a
    caller bug surfaces at the add call, not as a malformed wire shape."
    (aString includes: Character cr) ifTrue: [
        Error signal: 'CRLF or NUL in multipart part header: ' , fieldLabel ].
    (aString includes: Character lf) ifTrue: [
        Error signal: 'CRLF or NUL in multipart part header: ' , fieldLabel ].
    (aString includes: (Character value: 0)) ifTrue: [
        Error signal: 'CRLF or NUL in multipart part header: ' , fieldLabel ]
]

{ #category : 'private' }
ClaudeStreamingMultiPartEntity >> writeBodyOf: aPart on: aStream [
    "Write a single part's body bytes to aStream. File parts stream from
    disk in chunks. Value parts write their UTF-8 encoded bytes directly.
    No encoding or line-ending conversion — bytes go out verbatim."
    (aPart at: #kind) = #file ifTrue: [
        (aPart at: #fileReference) binaryReadStreamDo: [:in |
            [in atEnd] whileFalse: [
                aStream nextPutAll: (in next: 64 * 1024) ] ].
        ^ self ].
    aStream nextPutAll: (aPart at: #value) utf8Encoded
]

{ #category : 'writing' }
ClaudeStreamingMultiPartEntity >> writeOn: aStream [
    "Serialize the multipart body to aStream. File parts stream from disk
    in 64 KB chunks — the whole reason this class exists. Value parts
    write their UTF-8 encoded bytes directly.
    
    All String segments (boundary framing, per-part headers, inter-part
    CRLF, terminator) pass through utf8Encoded so non-ASCII characters
    in a filename, fieldName, or contentType printString emit proper
    UTF-8 bytes — matching contentLength, which sums the same encoder's
    byte counts. asByteArray was wrong here: on Latin-1 Strings it
    answers 1 byte per char (not the 2 UTF-8 bytes servers expect), and
    on wide Strings it answers 4 bytes per char (UTF-32), so the wire
    bytes would neither match Content-Length nor decode as UTF-8.
    
    Byte sequence per part: `--<boundary>\r\n` + headers + body + `\r\n`.
    After the last part, emit `--<boundary>--\r\n` to terminate. The `\r\n`
    after each part body IS the inter-part CRLF; the terminator carries
    its own leading `--`, so do not emit an extra CRLF before it."
    | boundaryLine terminator |
    boundaryLine := '--' , boundary , String crlf.
    terminator := '--' , boundary , '--' , String crlf.
    parts do: [:part |
        aStream nextPutAll: boundaryLine utf8Encoded.
        aStream nextPutAll: (self headersFor: part) utf8Encoded.
        self writeBodyOf: part on: aStream.
        aStream nextPutAll: String crlf utf8Encoded ].
    aStream nextPutAll: terminator utf8Encoded
]
