"
Tests for `ClaudeMessagingTestSuite` — the per-product factory for Messaging SDK tests.

	ClaudeMessagingTestSuiteTest buildSuite run
	>>> 10 run, 10 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 unexpected passes

"
Class {
	#name : 'ClaudeMessagingTestSuiteTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildFastSuiteExcludesSlow [
	| suite excluded |
	suite := ClaudeMessagingTestSuite fastSuite.
	excluded := suite tests select: [ :t |
		| proto |
		proto := t class protocolNameOfSelector: t selector.
		proto = 'tests-slow' or: [ proto = 'tests-integration' ] ].
	self assert: excluded isEmpty
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildFullSuiteIncludesAll [
	| suite integrationTests |
	suite := ClaudeMessagingTestSuite fullSuite.
	integrationTests := suite tests select: [ :t |
		(t class protocolNameOfSelector: t selector) = 'tests-integration' ].
	self assert: integrationTests isNotEmpty
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildIntegrationSuite [
	| suite nonIntegration |
	suite := ClaudeMessagingTestSuite integrationSuite.
	self assert: (suite isKindOf: TestSuite).
	nonIntegration := suite tests reject: [ :t |
		(t class protocolNameOfSelector: t selector) = 'tests-integration' ].
	self assert: nonIntegration isEmpty description: 'integrationSuite must contain only tests-integration methods'
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildSuiteIncludingFiltersToNamedProtocol [
	| suite outside |
	suite := ClaudeMessagingTestSuite suiteIncluding: #('tests').
	self assert: (suite isKindOf: TestSuite).
	self assert: suite tests isNotEmpty description: 'Expected at least one test in the tests protocol'.
	outside := suite tests reject: [ :t |
		(t class protocolNameOfSelector: t selector) = 'tests' ].
	self assert: outside isEmpty description: 'suiteIncluding: #(''tests'') must contain only tests-protocol methods'
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildSuiteNotEmpty [
	| suite |
	suite := ClaudeMessagingTestSuite suite.
	self assert: suite tests isNotEmpty
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testBuildSuiteReturnsTestSuite [
	self assert: ClaudeMessagingTestSuite suite class equals: TestSuite
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testExcludesIntegrationTests [
	| suite integrationTests |
	suite := ClaudeMessagingTestSuite suite.
	integrationTests := suite tests select: [ :t |
		(t class protocolNameOfSelector: t selector) = 'tests-integration' ].
	self assert: integrationTests isEmpty
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testIncludesAllPackages [
	"Every package listed in ClaudeMessagingTestSuite packageNames should contribute at least one test class."
	| representedPackages |
	representedPackages := (ClaudeMessagingTestSuite testClasses collect: [ :c | c package name ]) asSet.
	ClaudeMessagingTestSuite packageNames do: [ :pn |
		self assert: (representedPackages includes: pn) description: 'Missing package: ', pn ]
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testIsNotTestCase [
	"ClaudeMessagingTestSuite is a factory Object subclass, not a TestCase."
	self deny: (ClaudeMessagingTestSuite includesBehavior: TestCase)
]

{ #category : 'tests' }
ClaudeMessagingTestSuiteTest >> testNoAgentPackagesListed [
	"ClaudeMessagingTestSuite must not aggregate any Agent-layer test package."
	ClaudeMessagingTestSuite packageNames do: [ :pn |
		self deny: (pn beginsWith: 'Claude-Agent-') description: 'Agent package leaked into Messaging suite: ', pn.
		self deny: (pn beginsWith: 'Claude-Workbench') description: 'Workbench package leaked into Messaging suite: ', pn ]
]
