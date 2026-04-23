"
Live end-to-end integration test for the Skills API. Uploads a scratch
skill via `ClaudeMessagingSkillsExample uploadOn:`, round-trips it
through `getSkill:`, enumerates its versions via `listVersionsFor:`,
and then deletes every version and the skill itself. This is the first
live-API test for Skills -- it exists because PR #103 shipped with 96
mock-green tests and 3 production bugs that the mocks could not have
caught.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present, every test in this class
skips via `self skip` -- tests do not fail on a key-less image. The
default suite (`ClaudeMessagingTestSuite suite`) excludes this class
by protocol; only `integrationSuite` includes it.

**Server-computed assertions.** Every assertion here targets a value
the server produces. The client cannot fake these:

- `skill id` -- server-generated skill identifier (accessor is `id`,
  not `skillId`; `skillId` lives on `ClaudeSkillVersion` as a
  back-pointer to its parent skill). Nil-guarded before content check.
- `skill createdAt` -- server-assigned ISO 8601 timestamp
- `skill latestVersion` -- server-assigned version id populated after
  a successful upload
- `getSkill: id` -- round-trips the uploaded skill, returning a
  `ClaudeSkill` (not a `ClaudeSkillVersion`)
- `listVersionsFor: id` -- server must report at least one version
  after a successful upload

`listSkills` is deliberately NOT asserted. It only returns the first
page (server default 20 items); on an account with >20 existing skills
the just-uploaded skill may land on a later page and produce a false
failure. `getSkill:` above already proves server-side persistence.

Client-constructed properties (e.g. `displayTitle`) are not asserted
here; asserting them would be tautological. Mock tests in
`ClaudeMockServerSkillsTest` cover those.

**Cleanup contract.** The Skills API rejects `deleteSkill:` when any
version still exists. The `ensure:` block re-lists versions rather
than reusing any outer binding -- if an assertion raises before the
outer `versions` variable is assigned, reusing it would silently skip
the delete loop and leak the skill in the real Anthropic account.
Re-listing inside `ensure:` makes the cleanup idempotent and complete.
The inner scratch directory created by `buildSkillUploadDirectory` is
cleaned up by `uploadOn:` itself, so we do not track it here.

  ClaudeSkillsIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeSkillsIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Skills-Tests',
	#package : 'Claude-Messaging-Skills-Tests'
}

{ #category : 'tests-integration' }
ClaudeSkillsIntegrationTest >> testSkillRoundTripAgainstAnthropic [
	"Upload a scratch skill, round-trip it through getSkill:, enumerate
	 versions, then delete every version and the skill. All assertions
	 target server-computed values. Cleanup runs even when an assertion
	 raises.

	 Note on listSkills: deliberately NOT asserted here. listSkills only
	 returns the first page (server default 20 items) and on accounts
	 with more than 20 existing skills the just-uploaded skill may land
	 on a later page, producing a false failure. The getSkill: round-trip
	 below already proves server-side persistence of the upload."

	| client skill roundTripped versions |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	skill := ClaudeMessagingSkillsExample uploadOn: client.
	[
		"Nil-guard first, then content. An unexpected nil id would otherwise
		 raise MessageNotUnderstood from isNotEmpty and obscure the real
		 fault (server handed back an unpopulated response)."
		self
			assert: skill id isNotNil
			description: 'server-generated skill id must be present'.
		self
			assert: skill id isNotEmpty
			description: 'server-generated skill id must be non-empty'.
		self
			assert: skill createdAt isNotNil
			description: 'server-assigned createdAt timestamp must be populated'.
		self
			assert: skill latestVersion isNotNil
			description: 'server-assigned latestVersion id must be populated after upload'.
		roundTripped := client getSkill: skill id.
		self
			assert: roundTripped class == ClaudeSkill
			description: 'getSkill: must return a ClaudeSkill (not a ClaudeSkillVersion)'.
		self
			assert: roundTripped id isNotNil
			description: 'getSkill: response must carry a non-nil skill id'.
		self
			assert: roundTripped id = skill id
			description: 'getSkill: must round-trip the uploaded skill id'.
		versions := client listVersionsFor: skill id.
		self
			assert: versions data isNotEmpty
			description: 'listVersionsFor: must report at least one server-side version'
	] ensure: [
		"Paginate through every page of listVersionsFor: before deleting
		 the skill. The Skills API rejects deleteSkill: when any version
		 still exists, so a single-page cleanup would leak versions (and
		 then the skill itself) on any account that has more than the
		 server default page size. First-page-outside-loop with
		 whileTrue: [hasMore] is the correct Smalltalk idiom:
		 whileNotNil: with a pre-nil page token terminates before the
		 first fetch and never deletes anything.

		 Cascade ` ; yourself` on the next-page params is mandatory.
		 ClaudeSkillVersionListParams >> #page: is a plain setter
		 (`page := aString`) with no explicit ^self, so the keyword-
		 message expression `ClaudeSkillVersionListParams new page: t`
		 evaluates to the String t -- not the fresh params instance --
		 and the next listVersionsFor:params: call would DNU
		 #asQueryParams on a String, silently never advancing past the
		 first page. The cascade pins the value to the receiver.

		 The per-version handler narrows the swallow to ClaudeNotFoundError
		 (a partial prior cleanup may have removed the resource already);
		 any other ClaudeApiError is logged to Transcript so unexpected
		 failures stay visible on triage. Pharo's BlockClosure has only
		 #on:do: -- a chained on:do:on:do: does not exist -- so we
		 dispatch by `e class` inside a single handler. The same
		 discipline applies to the final deleteSkill:."
		skill ifNotNil: [
			| listParams page |
			[ listParams := ClaudeSkillVersionListParams new.
			  page := client listVersionsFor: skill id params: listParams.
			  [ page data do: [ :v |
				  [ client deleteVersion: v version for: skill id ]
					on: ClaudeApiError do: [ :e |
						e class = ClaudeNotFoundError
							ifFalse: [
								Transcript
									nextPutAll: 'unexpected cleanup error deleting version ';
									nextPutAll: v version;
									nextPutAll: ': ';
									print: e;
									cr ] ] ].
			    page hasMore ] whileTrue: [
				listParams := ClaudeSkillVersionListParams new
					page: page nextPage;
					yourself.
				page := client listVersionsFor: skill id params: listParams ] ]
				on: ClaudeApiError do: [ :e |
					Transcript
						nextPutAll: 'unexpected cleanup error listing versions: ';
						print: e;
						cr ].
			[ client deleteSkill: skill id ]
				on: ClaudeApiError do: [ :e |
					e class = ClaudeNotFoundError
						ifFalse: [
							Transcript
								nextPutAll: 'unexpected cleanup error deleting skill: ';
								print: e;
								cr ] ] ] ]
]
