"
Demonstrate the Skills API: upload a directory as a skill, list skills, attach a skill to a code-execution container. The upload and list methods take a ClaudeClient (network call) but the build helpers are pure and doctestable.

Each call to buildSkillUploadDirectory creates a fresh scratch tree: the inner directory is always named 'example-skill' (matching SKILL.md's name: field, as the Skills API requires), and it lives inside a per-call unique parent so two consecutive invocations produce distinct paths. Callers must delete the PARENT, not the inner directory, to clean up the whole tree — uploadOn: already does this.

  ClaudeMessagingSkillsExample buildSkillUploadDirectory basename
  >>> 'example-skill'

  ClaudeMessagingSkillsExample buildContainerWithSkills skills first skillId
  >>> 'sk_example'

  ClaudeMessagingSkillsExample buildContainerWithSkills skills first type
  >>> 'custom'

  ""Each build gets a distinct parent directory, so two consecutive
   calls produce two different paths. Cleanup is wrapped in ensure:
   so the scratch parents are removed even if the assertion raises.""
  | a b |
  a := ClaudeMessagingSkillsExample buildSkillUploadDirectory.
  b := ClaudeMessagingSkillsExample buildSkillUploadDirectory.
  [ a parent = b parent ] ensure: [
    a parent exists ifTrue: [ a parent deleteAll ].
    b parent exists ifTrue: [ b parent deleteAll ] ]
  >>> false


"
Class {
	#name : 'ClaudeMessagingSkillsExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingSkillsExample class >> buildContainerWithSkills [
	"Build a container params instance that loads a custom skill into a code-execution container."
	| params |
	params := ClaudeContainerParams new.
	params skills: { ClaudeSkillSpec skillId: 'sk_example' type: 'custom' }.
	^ params
]

{ #category : 'building' }
ClaudeMessagingSkillsExample class >> buildSkillUploadDirectory [
	"Build a sample skill directory under FileLocator temp. The directory
	 is named 'example-skill' (matching the name: field in its SKILL.md
	 frontmatter, as required by the Skills API directory-name guard)
	 and lives inside a per-call unique parent so two consecutive
	 invocations produce distinct paths without leaking stale files.

	 Returns the FileReference to the inner 'example-skill' directory.
	 Callers must clean up the PARENT (dir parent) in an ensure: block
	 so the entire nested structure is removed -- uploadOn: does this
	 for you."

	| parent dir |
	parent := FileLocator temp
		/ ('claude-example-skill-' , UUID new asString36).
	parent createDirectory.
	dir := parent / 'example-skill'.
	dir createDirectory.
	dir / 'SKILL.md' writeStreamDo: [ :s |
		s nextPutAll: '---' , String lf
			, 'name: example-skill' , String lf
			, 'description: Demonstrates skill upload via the Claude Messaging SDK.' , String lf
			, '---' , String lf , String lf
			, '# Example Skill' , String lf , String lf
			, 'Demonstrates skill upload via the Claude Messaging SDK.' ].
	dir / 'helper.py' writeStreamDo: [ :s |
		s nextPutAll: 'def add(a, b):' , String lf , '    return a + b' ].
	^ dir
]

{ #category : 'examples' }
ClaudeMessagingSkillsExample class >> listOn: aClient [
	"List skills for the account."
	^ aClient listSkills
]

{ #category : 'examples' }
ClaudeMessagingSkillsExample class >> uploadOn: aClient [
	"Upload the example skill directory and return the resulting ClaudeSkill.
	 Wraps the upload in ensure: so the per-call parent directory is
	 deleted even when the network call raises. Deletes the parent, not
	 the inner 'example-skill' directory, so the whole scratch tree
	 is cleaned up."
	| dir parent |
	dir := self buildSkillUploadDirectory.
	parent := dir parent.
	^ [ aClient uploadDirectory: dir displayTitle: 'Example Skill' ]
		ensure: [ parent exists ifTrue: [ parent deleteAll ] ]
]
