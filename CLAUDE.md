# anthropic-sdk-pharo

The Claude SDK for Pharo — a Smalltalk client for Anthropic's
Messages API. This file is Claude Code's project instructions for the
new standalone repo; it covers architecture, engineering conventions,
and the contributor workflow.

## The Product

This repository ships one product: the **Claude SDK for Pharo**.
Public-facing description lives in [README.md](README.md).
The SDK wraps the [Anthropic Messages API](https://docs.anthropic.com/en/api/messages)
with first-class Smalltalk domain objects: messages, content blocks,
tools, files, MCP connectors, skills. It depends only on Pharo 12's
built-in Zinc HTTP and STONJSON.

The Agent SDK (`Claude-Agent-*`), the Agent Workbench, and the Pharo
Agent Bridge live in the separate `claude-agent-sdk-smalltalk` repo
and are NOT part of this repo. If a question is about tool-use loops,
Morphic presenters, or CLI plugins, it does not belong here.

## Architecture

- **Client**: `ClaudeClient` wraps `ZnClient` (Zinc HTTP). One
  `ZnClient` per request (no pooling). Headers: `x-api-key`,
  `anthropic-version: 2023-06-01`.
- **Types**: Class hierarchy, not dictionaries. `ClaudeMessage`,
  `ClaudeContentBlock` subclasses (text, tool_use, tool_result,
  thinking, image, PDF document, server tool results), `ClaudeTool`,
  `ClaudeMessageRequest`, `ClaudeCacheControl` (prompt caching),
  `ClaudeThinkingParams` (enabled/adaptive/disabled),
  `ClaudeBetaHeader` (typed beta-header catalog). JSON via `STONJSON`
  (built into Pharo 12).
- **Streaming**: Two modes. Buffered: `streamMessage:do:` reads full
  response, parses SSE, calls block per event. Real-time:
  `ClaudeStreamingSocket` opens raw TLS socket via
  `openStreamingSocket:`, reads SSE incrementally with chunked
  transfer-encoding support.
- **Errors**: `ClaudeApiError` hierarchy keyed on HTTP status. 9
  subclasses (401 AuthError through 529 OverloadedError). Retry with
  exponential backoff.
- **Server tools**: `ClaudeBashTool`, `ClaudeTextEditorTool`,
  `ClaudeWebSearchTool`, etc. Request-side definitions only — these
  are executed by Anthropic, not locally. Extension methods on
  `ClaudeMessageRequest` provide convenience accessors (`addBash`,
  `addWebSearch`).
- **Files API**: `ClaudeFileMetadata`, `ClaudeFilePage`,
  `ClaudeDeletedFile`, `ClaudeFileListParams`. Upload, list,
  download, delete.
- **MCP**: `ClaudeMCPServerDefinition`, `ClaudeMCPToolConfiguration`.
  Request-side connector definitions. Response content blocks
  (`ClaudeMCPToolUseBlock`, `ClaudeMCPToolResultBlock`) live in
  `Claude-Messaging-Types`.
- **Skills API**: `ClaudeSkill`, `ClaudeSkillVersion`,
  `ClaudeDeletedSkill`, page types and list params.
- **Keyring**: `PharoKeyring` — cross-platform OS keyring wrapper.
  Strategy pattern with `LinuxSecretToolBackend` and
  `MacOSSecurityBackend`. Used by `ClaudeSDKExampleSupport` for API
  key resolution.

## Threading — Critical

The SDK is synchronous (matching Go). All network I/O blocks the
calling thread.

**Never call `sendMessage:` or `streamMessage:do:` from the Morphic
UI thread.** Fork a `Process`. Use `WorldState defer:` for any
Morphic modifications from background processes.

```smalltalk
"Safe pattern"
[ | resp |
  resp := client sendMessage: params.
  WorldState defer: [ label contents: resp textContent ]
] forkAt: Processor userBackgroundPriority named: 'API call'.
```

## Packages

Code is in **Tonel format** under `src/`. One layer — the Messaging
SDK — plus the standalone PharoKeyring.

### Production packages

| Package | Contents |
|---------|----------|
| `Claude-Messaging-Types` | `ClaudeMessage`, `ClaudeContentBlock` hierarchy, `ClaudeTool`, `ClaudeToolInputSchema`, `ClaudeMessageRequest`, `ClaudeModel`, `ClaudeUsage`, `ClaudeCacheControl`, `ClaudeRequestOptions`, `ClaudeSamplingParams`, `ClaudeThinkingParams`, `ClaudeToolParams`, `ClaudeBetaHeader`, response content blocks including `ClaudeServerToolUseBlock`, `ClaudeMCPToolUseBlock`, `ClaudeMCPToolResultBlock` |
| `Claude-Messaging-Errors` | `ClaudeApiError` hierarchy (Auth, Billing, InvalidRequest, NotFound, Overloaded, Permission, RateLimit, Server, Timeout) |
| `Claude-Messaging-Streaming` | `ClaudeSSEDecoder`, `ClaudeStreamingSocket` (raw TLS socket with chunked transfer-encoding), `ClaudeStreamingMultiPartEntity` |
| `Claude-Messaging-Client` | `ClaudeClient` (factory, config, `sendMessage:`, `countTokens:`, `listModels`, `getModel:`, `streamMessage:do:`, `openStreamingSocket:`, retry with backoff) |
| `Claude-Messaging-Tools` | Request-side server tool definitions (`ClaudeBashTool`, `ClaudeTextEditorTool`, `ClaudeWebSearchTool`, etc.) and extension methods on `ClaudeMessageRequest` |
| `Claude-Messaging-Files` | `ClaudeFileMetadata`, `ClaudeFilePage`, `ClaudeDeletedFile`, `ClaudeFileListParams` |
| `Claude-Messaging-MCP` | `ClaudeMCPServerDefinition`, `ClaudeMCPToolConfiguration` |
| `Claude-Messaging-Skills` | `ClaudeSkill`, `ClaudeSkillVersion`, `ClaudeDeletedSkill`, `ClaudeDeletedSkillVersion`, page types, list params |
| `Claude-Messaging-Examples` | Runnable usage examples + `ClaudeSDKExampleSupport` |

### Test packages

Each production package has a matching `-Tests` package.
`Claude-Messaging-Client-Tests` contains the shared
`ClaudeAbstractTestSuite`, the per-product `ClaudeMessagingTestSuite`,
and `ClaudeMockServer`.

### Standalone

| Package | Contents |
|---------|----------|
| `PharoKeyring` | `PharoKeyring` (facade), `PharoKeyringBackend` (abstract), `LinuxSecretToolBackend`, `MacOSSecurityBackend`, `PharoKeyringError`, `KeyringCommandError` |
| `PharoKeyring-Tests` | `PharoKeyringTest`, `PharoKeyringIntegrationTest`, `LinuxSecretToolBackendTest`, `MockKeyringBackend` |

Dependency order (per `BaselineOfClaudeMessaging`): PharoKeyring is
standalone; Types loads before everything else; Errors, Streaming,
Files, MCP, Skills depend on Types; Client depends on Types, Errors,
Streaming, Files, MCP, Skills; Tools depends on Types and Client
(Tools adds extension methods to `ClaudeMessageRequest`, a Types
class — the host class must exist before extensions compile);
Examples depends on Client, Tools, and PharoKeyring.

Package naming follows the Pharo idiom `Family-SubFamily-Module`.

## Development Model

All development happens inside the Pharo VM via the eval server. The
eval server (from the [Postern](https://github.com/punt-labs/postern)
repo, loaded as a bootstrap dependency) provides interactive class
definition, method compilation, testing, and full introspection — far
superior to file-in.

- **Define classes** — via eval server using Pharo 12 fluid syntax
- **Compile methods** — via eval server using `compile:classified:`
- **Test** — via eval server or `make test`
- **Lint** — `make lint` from CLI (Bash tool). NEVER use per-method
  `m critiques` as the gate — it misses class-level rules. See the
  Lint section.
- **Tonel** — Iceberg (inside VM) writes `.class.st` files to `src/`
- **Git** — Iceberg (inside VM) handles commit, push, fetch, branch
- **Git merge** — only operation done from Claude Code CLI (Iceberg
  can't merge)

```bash
make setup      # download Pharo 12 + load all Tonel packages
make start      # launch Pharo GUI with eval server on :${EVAL_PORT:-8422}
EVAL_PORT=8423 make start  # second image on a different port
make stop       # kill (no save — image is disposable)
make rebuild    # fresh image from scratch (proves code is complete)
make filein     # reload all Tonel packages into running image
make test       # run Messaging SDK tests via ClaudeMessagingTestSuite
make test-fast  # Messaging tests without slow/integration
make test-full  # all Messaging tests including live-API integration
make lint       # Renraku lint via ReCriticEngine on all classes
make drift      # compare in-image methods vs on-disk Tonel (detect drift)
make status     # health check — packages loaded count
make transcript # read Pharo Transcript
make eval       # interactive Smalltalk eval (stdin → eval server)
make spec       # build claude-sdk-specification PDFs (requires pdflatex)
```

## Image Discipline

- All code lives in `src/` (Tonel format). The image is disposable,
  not precious.
- `make rebuild` must always work. If it fails, the source files are
  incomplete.
- `make stop` does NOT save the image — saving captures socket state
  that causes errors on restore. `make rebuild` is the recovery path.
- Never commit the Pharo image or VM (`pharo/` is gitignored).
- Test `make rebuild` before pushing.

## Eval Server

Default port 8422 (override: set `EVAL_PORT` env var, or pass
`make PORT=8423 start` on the command line). `BootstrapEvalServer`
starts `ZnServer` with `BootstrapEvalDelegate` (subclass of
`ZnReadEvalPrintDelegate` that normalizes LF→CR on input).
Content-Type must be `text/plain`. Each port gets its own PID file
(`.pharo-<port>.pid`) and log file (`.pharo-<port>.log`), so multiple
images can run simultaneously. `make start` probes the target port
before launching and fails if another eval server is already
responding — preventing silent data races between agents.

```bash
# Evaluate Smalltalk
curl -s -X POST http://localhost:${EVAL_PORT:-8422}/repl -H "Content-Type: text/plain" -d "3 + 4"

# Browse a class
curl -s -X POST http://localhost:${EVAL_PORT:-8422}/repl -H "Content-Type: text/plain" \
  -d "BootstrapImageBrowser browseClass: 'ClaudeClient'"

# Read Transcript
curl -s -X POST http://localhost:${EVAL_PORT:-8422}/repl -H "Content-Type: text/plain" \
  -d "Transcript contents"
```

### LibC Safety — Critical

**Never run `make`, `curl localhost`, or any command that contacts
the eval server via `LibC resultOfCommand:` from inside the VM.**
This creates a circular dependency: the subprocess curls the eval
server port, the server can't respond because the VM is blocked
waiting for LibC to return, and the VM hangs. If the VM is then
killed, the subprocess survives as an orphan holding the port,
preventing restart.

Safe uses of LibC from inside the VM:

- `LibC resultOfCommand: 'git status'` — doesn't contact eval server
- `LibC resultOfCommand: 'git add ...'` — doesn't contact eval server
- `LibC resultOfCommand: 'git commit ...'` — doesn't contact eval server

Unsafe (will hang the VM):

- `LibC resultOfCommand: 'make lint'` — curls eval server
- `LibC resultOfCommand: 'make test'` — curls eval server
- `LibC resultOfCommand: 'curl localhost:<eval-port>/repl ...'` — directly contacts eval server

For lint and test from INSIDE the VM, use the Smalltalk APIs
directly (`MyTest buildSuite run`), not `make` targets via LibC.
**From the Bash tool (CLI, not LibC), `make lint` and `make test`
are correct and required** — see the Lint section for the
discipline. The rule is "no LibC subprocess to anything that calls
back into the VM," not "never run make."

### EVAL_PORT — Multi-Agent Port Routing

When running multiple Pharo images for parallel agent dispatch,
each image needs its own port. The `EVAL_PORT` environment variable
controls which port all eval server interactions target. If unset,
defaults to `8422`.

The Makefile reads `EVAL_PORT` via `PORT := $(or $(EVAL_PORT),8422)`.
Every target that uses `$(PORT)` — `start`, `stop`, `test`, `lint`,
`check`, `status`, `eval`, `transcript`, `filein` — inherits the
override. The explicit `make PORT=8423 start` override still works
(command-line variables take precedence).

## Pharo 12 Standards

### Class Definition (fluid syntax — mandatory)

```smalltalk
(Object << #MyClass
  slots: { #instVar1. #instVar2 };
  package: 'MyPackage') install.
```

The old
`subclass:instanceVariableNames:classVariableNames:package:` is
DEPRECATED and must not be used.

### Method Compilation

Always `compile:classified:` — never bare `compile:`.

```smalltalk
MyClass compile: 'myMethod ^ 42' classified: 'accessing'.
```

### JSON Serialization

No reflection (`instVarNamed:`, `allInstVarNames`). Each class
implements `asJson`/`fromJson:` with explicit accessors.
`jsonKeyMap` documents the camelCase → snake_case mapping. Use
collecting parameter pattern for classes with many fields.

### Class Comments

Every class must have a comment. Comments must include at least one
executable example showing how to use the class. Use the `>>>` doc
comment convention:

```smalltalk
"A client for the Claude Messages API.

  ClaudeClient apiKey: 'sk-ant-...'
  >>> a ClaudeClient(https://api.anthropic.com)

  | client params |
  client := ClaudeClient apiKey: 'sk-ant-...'.
  params := ClaudeMessageRequest new
    model: ClaudeModel sonnet45;
    maxTokens: 1024;
    addUserMessage: 'Hello'.
  (client sendMessage: params) textContent
  >>> 'Hello! How can I help you today?'
"
```

This is a core Pharo value: "Examples to learn from." A class
without a runnable example in its comment is incomplete.

### Lint — `make lint` is the only gate

**`make lint` from CLI is the canonical lint check.** Use the Bash
tool to invoke it. Zero non-`clean` lines required before any
commit, before any merge, before claiming "lint clean."

```bash
make lint 2>&1 | grep -v ': clean$' | grep -v '^$'
# expected output: nothing
```

**Why `make lint` and not `m critiques`**: Renraku has two layers
of rules. Per-method rules fire on individual methods
(`m critiques`). Class-level and package-level rules fire on the
class as a whole — `Unused instance variable`, `Instance variable
not read or not written`, `Excessive number of variables`,
`Excessive number of methods`, `Class not referenced`, etc.
**`m critiques` does NOT see class-level rules.** `make lint` runs
the full Renraku rule set via the project's lint task.

A per-method probe like
`(cls methods, cls class methods) do: [:m | m critiques]` is a
debugging tool for diving into a specific finding. **It is not the
gate.** Treating it as the gate has historically caused entire
classes of findings to slip past every "lint zero" claim.

**Lint discipline before any commit**:

1. Run `make lint` from the Bash tool (CLI, not from inside the VM
   via LibC — that hangs).
2. Pipe through `grep -v ': clean$' | grep -v '^$'` so you only see
   actual findings.
3. If any line remains, the lint is dirty. Fix every finding
   (class-level too) before commit. No "pre-existing excuse." No
   "out of scope."
4. Re-run `make lint` to confirm empty.
5. Only then commit.

### Test Runs

Only run our package tests. NEVER the full Pharo test suite.

```smalltalk
MyClassTest buildSuite run
```

For the whole Messaging suite, use `ClaudeMessagingTestSuite suite
run` (via eval server) or `make test` (from CLI).

### Deprecated APIs

| Old (deprecated) | New |
|-------------------|-----|
| `cls organization categories` | `cls protocolNames` |
| `cls organization listAtCategoryNamed:` | `cls selectorsInProtocol:` |
| `ref actualClass` | `ref methodClass` |
| `FileStream fileIn:` | `CodeImporter evaluateFileNamed:` |
| `Compiler evaluate:` | `self class compiler evaluate:` |
| `subclass:instanceVariableNames:...` | `<< #Name slots: {...}; package: '...'` |
| `compile:` | `compile:classified:` |
| `rule check: m` (swallows errors) | `m critiques` |

## Delegation with Missions

The COO (Claude Agento) does not write code. Work is delegated to
specialists scoped by ethos mission contracts.

| Specialist | Agent | When to use |
|-----------|-------|-------------|
| Kent B | `kwb` | Smalltalk implementation, tests, Iceberg/Tonel |
| Dan B | `djb` | Security review, threat models (auth, TLS, API-key handling) |
| Brian K | `bwk` | Cross-language evaluator — verifies Smalltalk types match the Go SDK wire format |
| Ada B | `adb` | Infrastructure, CI/CD, cross-repo tooling |

### Mission pipelines

This project uses ethos mission pipelines for all delegation.
Pipelines are multi-stage workflows with typed stages, dependency
wiring, and template variables. Each stage produces a mission
contract automatically.

**Available pipelines:**

| Pipeline | Stages | When to use |
|----------|--------|-------------|
| `standard` | 5 | Default feature lifecycle: design → implement → test → review → document |
| `quick` | 2 | Well-understood bugs/tasks: implement → review |
| `product` | 6 | New features needing product validation |
| `coe` | 5 | Incident investigation: recurring bugs, data corruption |
| `formal` | 7 | Complex stateful systems: Z spec before implementation |
| `docs` | 2 | Documentation-only changes |
| `coverage` | 3 | Targeted test coverage improvement |

**Choosing a pipeline:**

- T1 work (design ambiguity, multi-layer, security) → `standard` or
  `product`
- T2 work (features, clear goal) → `standard`
- T3 work (bugs, obvious fix) → `quick`

**Instantiating:**

```bash
ethos mission pipeline instantiate standard \
  --leader claude \
  --worker kwb \
  --evaluator djb \
  --var feature=beta-header-catalog \
  --var target='Claude-Messaging-Types Claude-Messaging-Types-Tests'
```

### Spec review — required before every dispatch

The COO cannot grade their own specs. Every implementation dispatch
must be preceded by a spec review:

1. COO writes spec → `.tmp/missions/<bead>-spec.yaml`
2. Dispatch `feature-dev:code-architect` as spec reviewer
3. Architect reviews for: completeness, correct selectors/APIs,
   clear acceptance criteria, write-set accuracy, evaluator
   appropriateness
4. Architect returns **APPROVE**, **ITERATE** (with specific
   fixes), or **REJECT** (with reason)
5. Only APPROVED specs go to the worker

A spec mission is not a design mission. Design produces
architecture; spec review validates that the contract is complete
and unambiguous enough for the worker to implement without wasted
rounds.

### Design phase — T1 work only

For T1-shaped tasks (security boundaries like auth and API-key
handling, multi-package features, competing design approaches), add
a design phase before implementation:

1. Dispatch `feature-dev:code-architect` with a threat model
   requirement and explicit list of attacker-controlled inputs
2. Run `feature-dev:code-reviewer` against the DESIGN document, not
   code
3. Iterate the design until reviewers are clean against the threat
   model
4. Only then proceed to implementation

The design document lives in `.tmp/missions/<bead>-design.md` and
is referenced from the implementation mission contract's `context`
field.

### Dispatching a stage

```bash
ethos mission dispatch --worker kwb --evaluator djb \
  --write-set <paths> --criteria <criteria> \
  --file .tmp/missions/<bead-id>.yaml
```

Then spawn the worker:
`Agent(subagent_type="kwb", run_in_background=true)` with prompt:
"Read your mission contract: `ethos mission show <id>`. Execute it.
Submit your result: `ethos mission result <id> --file <path>`."

### Mission contract must include

- **`write_set`** — which Tonel files (and only those files) the
  worker may touch.
- **`success_criteria`** — specific, verifiable outcomes. Must
  include:
  - `make lint` clean (Bash tool, not per-method probe)
  - Specific `MyTest buildSuite run` invocations for touched
    classes
  - Iceberg ref sync after commit
  - Any probe results with expected values
- **`budget`** — rounds (1-10). Design missions default to 2,
  implement to 3.
- **`context`** — design guidance, threat model (for security
  work), constraints, stop conditions.
- **`evaluator`** — who reviews the result. Smalltalk self-review
  is not allowed: use `djb` (security), `bwk` (wire-format/Go
  parity), or `adb` (infra/CI) as evaluator.

### YAML gotcha

The mission contract YAML rejects unknown fields via strict
unmarshal. Also: `>>` in YAML has special meaning (merge
indicator). Quote any success criterion containing Smalltalk's
`>>` selector separator:
`"Method ClaudeClient>>sendMessage: exists"`.

### kwb agent identity

kwb's agent definition (`.claude/agents/kwb.md`) carries
Smalltalk-specific safety rules that no mission contract replaces:
Iceberg discipline, Renraku lint gates, LibC deadlock avoidance,
eval server patterns, fluid class syntax, `compile:classified:`,
`>>>` doc-test conventions. The mission contract scopes *what* to
do; `kwb.md` defines *how* to do it safely in Pharo.

**Before dispatching:** verify `.claude/agents/kwb.md` is intact.
Run `git diff .claude/agents/kwb.md`. If modified unexpectedly,
restore from HEAD before dispatching.

**Branch first.** Create the feature branch before creating the
mission. Iceberg commits to whatever branch is current in the
image — if you forget, Kent commits directly to main. No
exceptions.

### Testing rule for kwb dispatches

kwb must ONLY run named test classes via eval server:
`MyNewTest buildSuite run`, `ExistingTest buildSuite run`. Never
run `make test`, `TestRunner`, `Smalltalk tests`, or any broad
test command from inside the image or via eval server. Running the
full Pharo test suite opens/closes hundreds of Morphic windows,
destroys the taskbar, and disrupts the live image. `make test` and
`make lint` are COO-only gates run from the CLI after kwb reports
back.

### "Fix it now" — qualified

**In bug triage and review cycles:** When a reviewer flags a
finding or you notice adjacent drift while working, fix it in the
current PR. Don't defer. No "pre-existing" excuses.

**In feature design:** For T1 work with a threat model, resist the
urge to fix the first thing you see. Dispatch `code-architect` and
enumerate EVERY class of failure before touching code.

### After kwb reports back

1. **Cross-check with `make lint` from CLI.** Do not trust the
   worker's own probe. Run the canonical gate.
2. **Read the diff.** `git diff <prior>..<new>` end-to-end. Spot
   anything kwb did outside the write-set.
3. **Verify Iceberg ref sync** if any CLI git ops happened on the
   branch.
4. **Review the result artifact.** `ethos mission results <id>` —
   verify the artifact exists and matches the success criteria.
5. **Close or advance.** `ethos mission close <id>` if clean.
   Otherwise `ethos mission reflect <id> --file <path>` with
   findings, then `ethos mission advance <id>` for another round.

## Pharo Values

This project follows the Pharo Zen values. These are not
aspirational — they are engineering standards enforced in every
review:

- **Examples to learn from** — every class comment includes
  runnable `>>>` examples
- **There is no unimportant fix** — no "pre-existing issue," no
  "out of scope," no deferral
- **Objects all the way down** — domain objects, not dictionaries
  or raw strings
- **Explicit is better than implicit** — `asJson`/`fromJson:` with
  explicit accessors, not reflection
- **Better a set of small polymorphic classes than a large ugly
  one** — `ClaudeContentBlock` hierarchy,
  `ClaudeApiError` hierarchy
- **Polymorphism is our Esperanto** — `isTextBlock`,
  `isToolUseBlock`, `applyDelta:` replace type-checking
  conditionals
- **Beauty in the code, beauty in the comments** — class comments
  document intent; method names reveal intention

## Naming Conventions

### Package naming

Package naming follows the Pharo idiom `Family-SubFamily-Module`.
This repo ships **two package families**, both addressable from
the same Metacello baseline:

- **`Claude-Messaging-*`** — Messages API surface and the
  resources that attach to a Messages request. Existing today.
  Examples: `Claude-Messaging-Types`, `Claude-Messaging-Client`,
  `Claude-Messaging-Streaming`, `Claude-Messaging-Files`,
  `Claude-Messaging-MCP`, `Claude-Messaging-Skills`,
  `Claude-Messaging-Tools`, `Claude-Messaging-Errors`,
  `Claude-Messaging-Examples`.
- **`Claude-ManagedAgents-*`** — Anthropic's Managed Agents API
  beta resources. New in v0.7+. Examples (planned):
  `Claude-ManagedAgents-Sessions`,
  `Claude-ManagedAgents-MemoryStores`,
  `Claude-ManagedAgents-Agents`,
  `Claude-ManagedAgents-Environments`,
  `Claude-ManagedAgents-UserProfiles`,
  `Claude-ManagedAgents-Vaults`. See ADR-40 in `DESIGN.md`.

Anthropic uses "Managed Agents" in its API documentation; we use
the same term in prose and `ManagedAgents` (single CamelCase
token) in package names and code identifiers. See ADR-41.

The local in-image agent runtime in the monorepo
`claude-agent-sdk-smalltalk` uses a different prefix —
`Claude-Agent-*` (singular, no `-s`) — for an unrelated concept
(tool runner, exchange loop, commands). The two prefixes are
deliberately distinct.

### `ClaudeClient` extension methods

`ClaudeClient` lives in `Claude-Messaging-Client` and is the
single gateway for every API call. Methods that target Managed
Agents resources are defined as Pharo extension methods in the
relevant `Claude-ManagedAgents-*` package, not in the Messaging
client package itself. See ADR-42.

Extension method category names follow the standard Pharo
convention: prefix the host package's method category with `*`
and the defining package name. For example, a `createSession:`
method added to `ClaudeClient` from the
`Claude-ManagedAgents-Sessions` package goes in the category
`*Claude-ManagedAgents-Sessions`. The asterisk-prefix tells the
System Browser (and any reader) that the method's defining
package differs from the host class's package.

```smalltalk
"Defined in Claude-ManagedAgents-Sessions, on the host class
 ClaudeClient (which lives in Claude-Messaging-Client):"
ClaudeClient
  compile: 'createSession: aSessionRequest
    ^ self post: ''/v1/sessions'' with: aSessionRequest asJson'
  classified: '*Claude-ManagedAgents-Sessions'.
```

Selective loading via Metacello groups still works: a consumer
who loads only the `messaging` group gets `ClaudeClient` with
only Messages methods; loading `managed-agents` adds the agent
methods on top.

### Other naming conventions

- Class names: `Claude` prefix for all SDK types.
- Method names: intention-revealing per Beck. `sendMessage:` not
  `postToMessagesEndpoint:`. `textContent` not
  `collectTextBlocksAndJoin`.
- JSON keys: snake_case on wire (`max_tokens`), camelCase in
  Smalltalk (`maxTokens`). Each class implements `jsonKeyMap` for
  the mapping.
- Protocols: `accessing`, `json`, `tests`, `printing`, `models`,
  `instance creation`, `converting`, `private`. No
  `as yet unclassified`.

## Reference SDK

The Go SDK is the porting reference: `.tmp/anthropic-sdk-go/`
(gitignored). Code-generated (Stainless). We distill the Go
Messaging types into Smalltalk classes organized by role, using
class hierarchy and polymorphic dispatch over conditionals.

## Specification

- [`docs/specifications/claude-sdk-specification.pdf`](docs/specifications/claude-sdk-specification.pdf)
  — the full Messaging API specification for this SDK.
- [`docs/specifications/claude-sdk-specification-pharo-notes.pdf`](docs/specifications/claude-sdk-specification-pharo-notes.pdf)
  — Pharo-specific implementation notes (LF/CR, STONJSON
  conventions, Metacello baseline).
- [`docs/specifications/bootstrapping-pharo.pdf`](docs/specifications/bootstrapping-pharo.pdf)
  — how a Pharo 12 image loads the SDK from a clean slate.

Build the PDFs locally with `make spec` (requires `pdflatex`).

## Git Integration

Iceberg (libgit2) is configured for this repo. SSH via ed25519
key. Iceberg handles commit, push, fetch, branch. Merge is done
from CLI.
