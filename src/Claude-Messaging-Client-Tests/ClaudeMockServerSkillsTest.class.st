"
End-to-end mock-server tests for the Skills API. Verifies the eight endpoint URLs (each with ?beta=true), the skills-2025-10-02 beta header, multipart upload with multiple files parts, the SKILL.md client-side validation guard, and decoding of all response shapes.

  ClaudeMockServerSkillsTest buildSuite run
  >>> a TestResult

"
Class {
	#name : 'ClaudeMockServerSkillsTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client',
		'fixtureDirs'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> deletedSkillResponseJson [
	^ '{"id":"sk_abc","type":"skill_deleted"}'
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> deletedVersionResponseJson [
	^ '{"id":"1759178010641129","type":"skill_version_deleted"}'
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> newFixtureDirectoryWithMismatchedName [
	"Fixture whose directory basename deliberately disagrees with the
	 name: field in SKILL.md. Used to exercise the directory-name
	 guard in buildStreamingSkillPartsInto:fromDirectory:."
	| dir lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-skill-fixture-mismatch-' , 100000 atRandom printString).
	dir createDirectory.
	(dir / 'SKILL.md') writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name: intentionally-different-name'; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# Body' ].
	(dir / 'helper.py') writeStreamDo: [ :s | s nextPutAll: 'print(1)' ].
	fixtureDirs add: dir.
	^ dir
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> newFixtureDirectoryWithNestedFile [
	"Fixture with SKILL.md at root plus a file in a nested subdirectory.
	 Used to verify that multipart fileNames use POSIX (forward-slash)
	 separators regardless of host platform. SKILL.md includes a YAML
	 frontmatter name: field matching the directory basename so the
	 directory-name guard in buildStreamingSkillPartsInto:fromDirectory:
	 does not fire."
	| dir lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-skill-fixture-nested-' , 100000 atRandom printString).
	dir createDirectory.
	(dir / 'SKILL.md') writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name: '; nextPutAll: dir basename; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# My Skill' ].
	(dir / 'helpers') createDirectory.
	(dir / 'helpers' / 'util.py') writeStreamDo: [ :s | s nextPutAll: 'print(2)' ].
	fixtureDirs add: dir.
	^ dir
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> newFixtureDirectoryWithOversizedFile [
	"Fixture with SKILL.md plus a single 26 MB binary file (1 MB above
	 the per-file limit). Used to verify the per-file size guard fires
	 before the multipart body is built. SKILL.md includes a YAML
	 frontmatter name: field matching the directory basename so the
	 directory-name guard does not fire first."
	| dir bytes lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-skill-fixture-oversized-' , 100000 atRandom printString).
	dir createDirectory.
	(dir / 'SKILL.md') writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name: '; nextPutAll: dir basename; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# My Skill' ].
	bytes := ByteArray new: 26 * 1024 * 1024 withAll: 65.
	(dir / 'huge.bin') binaryWriteStreamDo: [ :s | s nextPutAll: bytes ].
	fixtureDirs add: dir.
	^ dir
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> newFixtureDirectoryWithSkillMd [
	"Fixture with SKILL.md at root and a helper.py file. SKILL.md
	 includes a YAML frontmatter name: field matching the directory
	 basename so the directory-name guard in
	 buildStreamingSkillPartsInto:fromDirectory: does not fire."
	| dir lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-skill-fixture-' , 100000 atRandom printString).
	dir createDirectory.
	(dir / 'SKILL.md') writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name: '; nextPutAll: dir basename; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# My Skill' ].
	(dir / 'helper.py') writeStreamDo: [ :s | s nextPutAll: 'print(1)' ].
	fixtureDirs add: dir.
	^ dir
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> newFixtureDirectoryWithoutSkillMd [
	| dir |
	dir := FileLocator temp / ('ism8-skill-fixture-bad-', 100000 atRandom printString).
	dir createDirectory.
	(dir / 'helper.py') writeStreamDo: [ :s | s nextPutAll: 'print(1)' ].
	fixtureDirs add: dir.
	^ dir
]

{ #category : 'running' }
ClaudeMockServerSkillsTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5.
	fixtureDirs := OrderedCollection new
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> skillPageResponseJson [
	^ '{"data":[{"id":"sk_abc","created_at":"2026-04-19T12:00:00Z","display_title":"S1","latest_version":"v1","source":"custom","type":"skill","updated_at":"2026-04-19T12:00:00Z"}],"next_page":"tok_xyz"}'
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> skillResponseJson [
	^ '{"id":"sk_abc","created_at":"2026-04-19T12:00:00Z","display_title":"My Skill","latest_version":"1759178010641129","source":"custom","type":"skill","updated_at":"2026-04-19T12:00:00Z"}'
]

{ #category : 'running' }
ClaudeMockServerSkillsTest >> tearDown [
	fixtureDirs ifNotNil: [
		fixtureDirs do: [ :d | d exists ifTrue: [ d deleteAll ] ] ].
	mockServer ifNotNil: [ mockServer stop ].
	super tearDown
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testDeleteSkillReturnsClaudeDeletedSkill [
	| del |
	mockServer respondTo: '/v1/skills/sk_abc' with: self deletedSkillResponseJson.
	del := client deleteSkill: 'sk_abc'.
	self assert: (del isKindOf: ClaudeDeletedSkill).
	self assert: del id equals: 'sk_abc'.
	self assert: del type equals: 'skill_deleted'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testDeleteVersionReturnsClaudeDeletedSkillVersion [
	| del |
	mockServer respondTo: '/v1/skills/sk_abc/versions/1759178010641129' with: self deletedVersionResponseJson.
	del := client deleteVersion: '1759178010641129' for: 'sk_abc'.
	self assert: (del isKindOf: ClaudeDeletedSkillVersion).
	self assert: del id equals: '1759178010641129'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testGetSkillHitsExactPath [
	mockServer respondTo: '/v1/skills/sk_abc' with: self skillResponseJson.
	client getSkill: 'sk_abc'.
	self assert: mockServer lastRequestPath equals: 'v1/skills/sk_abc'.
	self assert: (mockServer lastRequest uri queryAt: 'beta') equals: 'true'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testGetSkillReturnsClaudeSkill [
	| skill |
	mockServer respondTo: '/v1/skills/sk_abc' with: self skillResponseJson.
	skill := client getSkill: 'sk_abc'.
	self assert: (skill isKindOf: ClaudeSkill).
	self assert: skill id equals: 'sk_abc'.
	self assert: skill displayTitle equals: 'My Skill'.
	self assert: skill source equals: 'custom'.
	self assert: skill type equals: 'skill'.
	self assert: skill latestVersion equals: '1759178010641129'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testGetSkillSendsBetaHeader [
	| header |
	mockServer respondTo: '/v1/skills/sk_abc' with: self skillResponseJson.
	client getSkill: 'sk_abc'.
	header := mockServer lastRequestHeaders at: 'anthropic-beta'.
	self assert: header equals: 'skills-2025-10-02'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testGetVersionHitsExactPath [
	mockServer respondTo: '/v1/skills/sk_abc/versions/1759178010641129' with: self versionResponseJson.
	client getVersion: '1759178010641129' for: 'sk_abc'.
	self assert: mockServer lastRequestPath equals: 'v1/skills/sk_abc/versions/1759178010641129'.
	self assert: (mockServer lastRequest uri queryAt: 'beta') equals: 'true'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testGetVersionReturnsClaudeSkillVersion [
	| v |
	mockServer respondTo: '/v1/skills/sk_abc/versions/1759178010641129' with: self versionResponseJson.
	v := client getVersion: '1759178010641129' for: 'sk_abc'.
	self assert: (v isKindOf: ClaudeSkillVersion).
	self assert: v skillId equals: 'sk_abc'.
	self assert: v version equals: '1759178010641129'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testListSkillsEncodesPageToken [
	"Page tokens may contain reserved characters like = + /. The query string
	 builder must percent-encode reserved characters so the server sees the
	 token bytes intact. The mock server URI parser then decodes them back
	 so queryAt: returns the original token. Regression for a Copilot finding
	 on the original raw concat that would have left = unescaped."
	| uri uriString rawToken |
	rawToken := 'tok=plus+slash/end'.
	mockServer respondTo: '/v1/skills' with: self skillPageResponseJson.
	client listSkills: (ClaudeSkillListParams new page: rawToken; limit: 50; yourself).
	uri := mockServer lastRequest uri.
	uriString := uri printString.
	"= and + are query-reserved and MUST be encoded on the wire so the server
	 does not parse a stray 'page=tok=...' as page=tok with a second value."
	self assert: (uriString includesSubstring: '%3D').
	self assert: (uriString includesSubstring: '%2B').
	"After parsing the request URI back to a ZnUrl, the value round-trips
	 to the original token, proving the encoding/decoding pair is sound."
	self assert: (uri queryAt: 'page') equals: rawToken.
	self assert: (uri queryAt: 'limit') equals: '50'.
	self assert: (uri queryAt: 'beta') equals: 'true'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testListSkillsHitsBaseSkillsPath [
	mockServer respondTo: '/v1/skills' with: self skillPageResponseJson.
	client listSkills.
	self assert: mockServer lastRequestPath equals: 'v1/skills'.
	self assert: (mockServer lastRequest uri queryAt: 'beta') equals: 'true'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testListSkillsReturnsClaudeSkillPage [
	| page |
	mockServer respondTo: '/v1/skills' with: self skillPageResponseJson.
	page := client listSkills.
	self assert: (page isKindOf: ClaudeSkillPage).
	self assert: page data size equals: 1.
	self assert: page nextPage equals: 'tok_xyz'.
	self assert: page hasMore
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testListSkillsWithParamsAppendsQuery [
	| uri uriString |
	mockServer respondTo: '/v1/skills' with: self skillPageResponseJson.
	client listSkills: (ClaudeSkillListParams new page: 'tok_xyz'; limit: 50; yourself).
	uri := mockServer lastRequest uri.
	uriString := uri printString.
	self assert: (uriString includesSubstring: 'beta=true').
	self assert: (uriString includesSubstring: 'page=tok_xyz').
	self assert: (uriString includesSubstring: 'limit=50').
	self assert: (uri queryAt: 'beta') equals: 'true'.
	self assert: (uri queryAt: 'page') equals: 'tok_xyz'.
	self assert: (uri queryAt: 'limit') equals: '50'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testListVersionsForSkillReturnsPage [
	| page |
	mockServer respondTo: '/v1/skills/sk_abc/versions' with: self versionPageResponseJson.
	page := client listVersionsFor: 'sk_abc'.
	self assert: (page isKindOf: ClaudeSkillVersionPage).
	self assert: page data size equals: 1.
	self assert: page nextPage isNil
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testSkillNameFrontmatterColonOnlyLineReturnsNil [
	"A 'name:' line with no value at all (just 5 characters, below the
	 6-character minimum for copyFrom: 6 to: size) must return nil
	 instead of slicing past the end of the string. Regression for a
	 Copilot finding on unguarded copyFrom: when the line is shorter
	 than the 'name: ' prefix."
	| dir ref result lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-frontmatter-colon-' , 100000 atRandom printString).
	fixtureDirs add: dir.
	dir createDirectory.
	ref := dir / 'SKILL.md'.
	ref writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name:'; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# Body' ].
	result := client skillNameFromFrontmatterAt: ref.
	self assert: result isNil
		description: 'name: with no value (5-char line) must return nil, not crash'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testSkillNameFrontmatterEmptyValueReturnsNil [
	"A 'name:   ' line whose value is only whitespace must return nil
	 rather than the empty string. An empty name is never a valid
	 skill name and would defeat the directory-name guard."
	| dir ref result lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-frontmatter-empty-' , 100000 atRandom printString).
	fixtureDirs add: dir.
	dir createDirectory.
	ref := dir / 'SKILL.md'.
	ref writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name:    '; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# Body' ].
	result := client skillNameFromFrontmatterAt: ref.
	self assert: result isNil
		description: 'name: with only whitespace value must return nil'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testSkillNameFrontmatterLoneQuoteDoesNotCrash [
	"A 'name: ""' line with a single unmatched quote must not crash the
	 scanner. The implementation only strips matched quote pairs; a
	 lone quote is preserved as content so the caller sees the raw
	 oddity rather than a silently truncated name. Regression for a
	 Copilot finding on unguarded quote stripping with value size < 2."
	| dir ref result lf |
	lf := String lf.
	dir := FileLocator temp / ('ism8-frontmatter-lone-quote-' , 100000 atRandom printString).
	fixtureDirs add: dir.
	dir createDirectory.
	ref := dir / 'SKILL.md'.
	ref writeStreamDo: [ :s |
		s
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: 'name: "'; nextPutAll: lf;
			nextPutAll: '---'; nextPutAll: lf;
			nextPutAll: '# Body' ].
	result := client skillNameFromFrontmatterAt: ref.
	self
		assert: result = '"'
		description: (String streamContents: [ :s |
			s nextPutAll: 'lone quote must be preserved as content (size 1), not stripped to empty; got: '.
			s nextPutAll: result printString ])
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryIncludesDisplayTitleFormField [
	| dir parts displayTitlePart |
	dir := self newFixtureDirectoryWithSkillMd.
	mockServer respondTo: '/v1/skills' with: self skillResponseJson.
	client uploadDirectory: dir displayTitle: 'My Skill'.
	parts := mockServer lastRequest entity contents.
	displayTitlePart := parts detect: [ :p | p fieldName = 'display_title' ] ifNone: [ nil ].
	self assert: displayTitlePart notNil description: 'multipart body should contain a display_title field'.
	self assert: displayTitlePart entity contents asString equals: 'My Skill'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryNormalizesPathsToPosix [
	"Multipart fileName values must use POSIX forward-slash separators
	 so the server interprets nested paths correctly on every host
	 platform. Filenames are prefixed with the upload directory
	 basename so the server sees files under a single top-level
	 folder. The field name is the literal 'files[]' string
	 (brackets required by the Skills API)."
	| dir parts filesParts names |
	dir := self newFixtureDirectoryWithNestedFile.
	mockServer respondTo: '/v1/skills' with: self skillResponseJson.
	client uploadDirectory: dir displayTitle: nil.
	parts := mockServer lastRequest entity contents.
	filesParts := parts select: [ :p | p fieldName = 'files[]' ].
	names := (filesParts collect: [ :p | p fileName ]) asArray.
	self assert: (names includes: dir basename, '/SKILL.md')
		description: 'SKILL.md at root must serialize as <basename>/SKILL.md'.
	self assert: (names includes: dir basename, '/helpers/util.py')
		description: 'nested fileName must use POSIX / separator, not backslash, under the basename prefix'.
	self deny: (names anySatisfy: [ :n | n includes: $\ ])
		description: 'no fileName may contain a backslash on any platform'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryRaisesErrorWhenSkillMdMissing [
	| dir |
	dir := self newFixtureDirectoryWithoutSkillMd.
	self
		should: [ client uploadDirectory: dir displayTitle: nil ]
		raise: Error
		whoseDescriptionIncludes: 'SKILL.md not found at directory root: ', dir fullName
		description: 'expected the SKILL.md guard to fire with the LD-5 message format'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryRejectsMismatchedFolderName [
	"When the upload directory's basename disagrees with the name:
	 field in SKILL.md's YAML frontmatter, the upload must fail
	 client-side with a clear error naming both values. The server
	 enforces the same rule (400 with 'folder name must match skill
	 name'); failing fast avoids the round-trip.

	 Fixture uses 'ism8-skill-fixture-mismatch-<N>' as the directory
	 name and writes 'name: intentionally-different-name' into
	 SKILL.md. The error message must include both names so callers
	 can see which side to fix."
	| dir |
	dir := self newFixtureDirectoryWithMismatchedName.
	self
		should: [ client uploadDirectory: dir displayTitle: nil ]
		raise: Error
		whoseDescriptionIncludes: 'does not match name:'
		description: 'directory-name mismatch must raise with a pinned message mentioning the mismatch'.
	self
		should: [ client uploadDirectory: dir displayTitle: nil ]
		raise: Error
		whoseDescriptionIncludes: dir basename
		description: 'error message must include the actual directory basename'.
	self
		should: [ client uploadDirectory: dir displayTitle: nil ]
		raise: Error
		whoseDescriptionIncludes: 'intentionally-different-name'
		description: 'error message must include the SKILL.md name: value'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryRejectsOversizedFile [
	"The per-file 25 MB guard must fire before the multipart body is
	 constructed. Uses a real 26 MB binary fixture (1 MB above the
	 limit) so the path goes through allFiles + size as in production."
	| dir |
	dir := self newFixtureDirectoryWithOversizedFile.
	self
		should: [ client uploadDirectory: dir displayTitle: nil ]
		raise: Error
		whoseDescriptionIncludes: 'Skill file exceeds 25MB limit: huge.bin'
		description: 'per-file size guard must fire with the offending file basename'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectoryReturnsClaudeSkill [
	| dir result |
	dir := self newFixtureDirectoryWithSkillMd.
	mockServer respondTo: '/v1/skills' with: self skillResponseJson.
	result := client uploadDirectory: dir displayTitle: nil.
	self assert: (result isKindOf: ClaudeSkill).
	self assert: result id equals: 'sk_abc'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadDirectorySendsMultipart [
	"Verifies the multipart envelope, the literal 'files[]' field
	 name, and that every filename is prefixed with the upload
	 directory basename followed by /. The server requires that
	 uploaded files live under a single top-level folder named
	 after the skill."
	| dir entityType parts filesParts names dirName prefix firstPart skillMdName helperName |
	dir := self newFixtureDirectoryWithSkillMd.
	dirName := dir basename.
	prefix := dirName , '/'.
	skillMdName := prefix , 'SKILL.md'.
	helperName := prefix , 'helper.py'.
	mockServer respondTo: '/v1/skills' with: self skillResponseJson.
	client uploadDirectory: dir displayTitle: nil.
	entityType := mockServer lastRequest entity contentType printString.
	self assert: (entityType includesSubstring: 'multipart/form-data').
	self assert: mockServer lastRequest method equals: 'POST'.
	parts := mockServer lastRequest entity contents.
	filesParts := parts select: [ :p | p fieldName = 'files[]' ].
	self assert: filesParts size equals: 2.
	names := (filesParts collect: [ :p | p fileName ]) asArray.
	self assert: (names includes: skillMdName)
		description: 'SKILL.md must be sent as <dir>/SKILL.md (server requires top-level folder)'.
	self assert: (names includes: helperName)
		description: 'helper.py must be sent as <dir>/helper.py under the basename prefix'.
	self assert: (names allSatisfy: [ :n | n beginsWith: prefix ])
		description: 'every filename MUST be prefixed with the upload directory basename followed by /'.
	firstPart := filesParts first.
	self
		assert: firstPart fieldName = 'files[]'
		description: (String streamContents: [ :s |
			s nextPutAll: 'multipart field name is the literal string files[] (brackets required by Skills API); got: '.
			s nextPutAll: firstPart fieldName printString ])
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadVersionRaisesErrorWhenSkillMdMissing [
	| dir |
	dir := self newFixtureDirectoryWithoutSkillMd.
	self
		should: [ client uploadVersionFor: 'sk_abc' fromDirectory: dir ]
		raise: Error
		whoseDescriptionIncludes: 'SKILL.md not found at directory root: ', dir fullName
		description: 'expected SKILL.md guard for the version upload path'
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testUploadVersionSendsMultipart [
	"Verifies the multipart envelope plus the literal 'files[]' field
	 name and the basename-prefixed filenames, same contract as
	 testUploadDirectorySendsMultipart."
	| dir entityType parts filesParts names dirName prefix firstPart skillMdName helperName |
	dir := self newFixtureDirectoryWithSkillMd.
	dirName := dir basename.
	prefix := dirName , '/'.
	skillMdName := prefix , 'SKILL.md'.
	helperName := prefix , 'helper.py'.
	mockServer respondTo: '/v1/skills/sk_abc/versions' with: self versionResponseJson.
	client uploadVersionFor: 'sk_abc' fromDirectory: dir.
	entityType := mockServer lastRequest entity contentType printString.
	self assert: (entityType includesSubstring: 'multipart/form-data').
	self assert: mockServer lastRequest method equals: 'POST'.
	parts := mockServer lastRequest entity contents.
	filesParts := parts select: [ :p | p fieldName = 'files[]' ].
	self assert: filesParts size equals: 2.
	names := (filesParts collect: [ :p | p fileName ]) asArray.
	self assert: (names includes: skillMdName)
		description: 'SKILL.md must be sent as <dir>/SKILL.md (server requires top-level folder)'.
	self assert: (names includes: helperName)
		description: 'helper.py must be sent as <dir>/helper.py under the basename prefix'.
	self assert: (names allSatisfy: [ :n | n beginsWith: prefix ])
		description: 'every filename MUST be prefixed with the upload directory basename followed by /'.
	firstPart := filesParts first.
	self
		assert: firstPart fieldName = 'files[]'
		description: (String streamContents: [ :s |
			s nextPutAll: 'multipart field name is the literal string files[] (brackets required by Skills API); got: '.
			s nextPutAll: firstPart fieldName printString ])
]

{ #category : 'tests' }
ClaudeMockServerSkillsTest >> testValidateSkillUploadSizeRejectsOversizedTotal [
	"The total 100 MB guard must fire when the sum of file sizes exceeds
	 the limit, even if no single file exceeds the per-file limit. Uses
	 ClaudeMockSkillFile stubs (#basename + #size only) so we do not have
	 to write 100+ MB of fixture data to disk.

	 The fixture sizes are deliberately NOT aligned to whole megabytes:
	 5 stubs at 22544384 bytes each (21.5 MB) sum to 112721920 bytes,
	 which formats as 107.50 MB. This guards against a regression where
	 the error message used Smalltalk integer division and printed a
	 Fraction (e.g. '(112721920/1048576)MB') instead of a human-
	 readable decimal."
	| stubs perStubBytes totalBytes |
	perStubBytes := (21.5 * 1024 * 1024) truncated.
	totalBytes := 5 * perStubBytes.
	stubs := (1 to: 5) collect: [ :i |
		ClaudeMockSkillFile basename: i printString, '.bin' size: perStubBytes ].
	self
		should: [ client validateSkillUploadSize: stubs ]
		raise: Error
		whoseDescriptionIncludes: 'Skill upload exceeds 100MB total limit (got 107.50MB)'
		description: 'total size guard must fire with the float-formatted MB count, not a Fraction printString'.
	"Sanity: each file alone is under the per-file limit, so failure
	 is exclusively from the total-bytes branch."
	stubs do: [ :stub |
		self assert: stub size <= ClaudeClient maxSkillFileBytes ].
	"Sanity: total exceeds the limit, confirming the test exercises the guard."
	self assert: totalBytes > ClaudeClient maxSkillUploadBytes
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> versionPageResponseJson [
	^ '{"data":[{"id":"1759178010641129","created_at":"2026-04-19T12:00:00Z","description":"d","directory":"my-skill","name":"my-skill","skill_id":"sk_abc","type":"skill_version","version":"1759178010641129"}],"next_page":null}'
]

{ #category : 'fixtures' }
ClaudeMockServerSkillsTest >> versionResponseJson [
	^ '{"id":"1759178010641129","created_at":"2026-04-19T12:00:00Z","description":"...","directory":"my-skill","name":"my-skill","skill_id":"sk_abc","type":"skill_version","version":"1759178010641129"}'
]
