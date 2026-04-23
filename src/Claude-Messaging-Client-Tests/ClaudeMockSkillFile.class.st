"
Stub of FileReference for skill-upload size-guard tests.
Exposes only the two selectors validateSkillUploadSize: invokes
(#size and #basename). Used by the total-size test to avoid
creating 100+ MB of real disk fixtures.

  ClaudeMockSkillFile basename: 'huge.bin' size: 26 * 1024 * 1024
  >>> a ClaudeMockSkillFile

"
Class {
	#name : 'ClaudeMockSkillFile',
	#superclass : 'Object',
	#instVars : [
		'basename',
		'size'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'instance creation' }
ClaudeMockSkillFile class >> basename: aString size: anInteger [
	"Stub of FileReference exposing only #basename and #size, the two
	 selectors validateSkillUploadSize: invokes. Used by the total-size
	 guard test to avoid creating 100+ MB of real disk fixtures.

	  ClaudeMockSkillFile basename: 'huge.bin' size: 26 * 1024 * 1024
	  >>> a ClaudeMockSkillFile
	"
	^ self new basename: aString; size: anInteger; yourself
]

{ #category : 'accessing' }
ClaudeMockSkillFile >> basename [ ^ basename
]

{ #category : 'accessing' }
ClaudeMockSkillFile >> basename: aString [ basename := aString
]

{ #category : 'accessing' }
ClaudeMockSkillFile >> size [ ^ size
]

{ #category : 'accessing' }
ClaudeMockSkillFile >> size: anInteger [ size := anInteger
]
