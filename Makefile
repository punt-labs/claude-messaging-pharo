# claude-messaging-pharo — Claude Messaging SDK for Pharo
#
# Image lifecycle:
#   make setup      — download Pharo VM + image, load all packages
#   make start      — launch Pharo with eval server on :$(PORT) (default 8422)
#   make stop       — stop the image on :$(PORT)
#   EVAL_PORT=8423 make start — second image on a different port
#   make rebuild    — fresh image from scratch
#
# Development:
#   make filein     — reload all Tonel packages into running image
#   make eval       — interactive Smalltalk eval
#   make test       — run Messaging SDK tests (ClaudeMessagingTestSuite)
#   make lint       — lint all SDK classes
#   make check      — verify all packages loaded + Iceberg working copy clean
#   make drift      — compare in-image methods vs on-disk Tonel
#   make status     — health check
#   make transcript — read Pharo Transcript
#   make spec       — build messaging-specification PDFs (requires pdflatex)

PHARO_VERSION := 120
PORT := $(or $(EVAL_PORT),8422)
IMAGE_DIR := $(CURDIR)/pharo
IMAGE := $(IMAGE_DIR)/Pharo.image
CHANGES := $(IMAGE_DIR)/Pharo.changes
VM := $(IMAGE_DIR)/pharo          # headless eval path (get.pharo.org installer symlink)
VM_UI := $(IMAGE_DIR)/pharo-ui   # GUI launcher (not used in this repo)
PID_FILE := $(CURDIR)/.pharo-$(PORT).pid
LOG_FILE := $(CURDIR)/.pharo-$(PORT).log
SRC_DIR := $(CURDIR)/src
URL := http://localhost:$(PORT)/repl
CURL := curl -s -X POST $(URL) -H "Content-Type: text/plain"

# Tonel packages — auto-discovered from src/ directories containing package.st.
# Dependency priority (lower number loads first): PharoKeyring=10, Types=20,
# Errors/Streaming=30, Files/MCP/Skills=39, Client=40, Tools=42, Examples=43,
# *-Tests=100.
# Client loads before Tools (Client=40, Tools=42) — Tools adds extension methods
# to ClaudeMessageRequest; the host class must exist before extensions compile.
# This matches the production claude-agent-sdk-smalltalk Makefile exactly.
LOAD_PACKAGES_EXPR := | dir allPkgs priority sorted lfCount | dir := '$(SRC_DIR)' asFileReference. IceRepository registry detect: [ :r | r name = 'claude-messaging-pharo' ] ifNone: [ | r | r := IceRepositoryCreator new location: '$(CURDIR)' asFileReference; createRepository. r register. r ]. allPkgs := (dir children select: [ :d | d isDirectory and: [ (d / 'package.st') exists ] ]) collect: [ :d | d basename ]. priority := Dictionary new. priority at: 'PharoKeyring' put: 10. priority at: 'Claude-Messaging-Types' put: 20. priority at: 'Claude-Messaging-Errors' put: 30. priority at: 'Claude-Messaging-Streaming' put: 30. priority at: 'Claude-Messaging-Files' put: 39. priority at: 'Claude-Messaging-MCP' put: 39. priority at: 'Claude-Messaging-Skills' put: 39. priority at: 'Claude-Messaging-Client' put: 40. priority at: 'Claude-Messaging-Tools' put: 42. priority at: 'Claude-Messaging-Examples' put: 43. sorted := allPkgs sorted: [ :a :b | | pa pb | pa := priority at: a ifAbsent: [ (a endsWith: '-Tests') ifTrue: [ 100 ] ifFalse: [ 50 ] ]. pb := priority at: b ifAbsent: [ (b endsWith: '-Tests') ifTrue: [ 100 ] ifFalse: [ 50 ] ]. pa = pb ifTrue: [ a < b ] ifFalse: [ pa < pb ] ]. sorted do: [ :name | | reader version | Transcript show: 'Loading package: ', name; cr. reader := TonelReader on: dir fileName: name. version := reader version. MCPackageLoader installSnapshot: version snapshot ]. lfCount := 0. Smalltalk globals allClasses do: [ :cls | ((cls package name beginsWith: 'Claude') or: [ cls package name beginsWith: 'PharoKeyring' ]) ifTrue: [ (cls methods, cls class methods) do: [ :m | | src | src := m sourceCode. (src includesSubstring: String lf) ifTrue: [ cls compile: (src copyReplaceAll: String lf with: String cr) classified: m protocolName. lfCount := lfCount + 1 ] ] ] ]. 'Loaded ', sorted size printString, ' packages, normalized ', lfCount printString, ' methods'

.PHONY: setup start stop save rebuild filein eval test test-fast test-full status lint drift check check-packages transcript spec clean clean-image

# ── Setup ──────────────────────────────────────────────

$(IMAGE_DIR):
	mkdir -p $(IMAGE_DIR)

$(VM): | $(IMAGE_DIR)
	@echo ">> Downloading Pharo $(PHARO_VERSION)..."
	cd $(IMAGE_DIR) && curl -fsSL https://get.pharo.org/64/$(PHARO_VERSION)+vm | bash
	@echo "  ok Pharo downloaded"

$(IMAGE): $(VM)
	@echo ">> Downloading fresh Pharo $(PHARO_VERSION) image..."
	cd $(IMAGE_DIR) && curl -fsSL http://files.pharo.org/get-files/$(PHARO_VERSION)/pharoImage-x86_64.zip -o image.zip \
		&& rm -f Pharo.image Pharo.changes \
		&& unzip -o image.zip \
		&& mv Pharo*.image Pharo.image \
		&& mv Pharo*.changes Pharo.changes \
		&& rm -f image.zip
	@echo "  ok Fresh image ready"

setup: $(IMAGE)
	@echo ">> Loading Postern (eval server) via Metacello..."
	$(VM) --headless $(IMAGE) eval --save "Metacello new baseline: 'Postern'; repository: 'github://punt-labs/postern:main/src'; load"
	@echo "  ok Postern loaded"
	@echo ">> Loading Tonel packages into image..."
	$(VM) --headless $(IMAGE) eval --save "$(LOAD_PACKAGES_EXPR)"
	@echo "  ok All packages loaded and image saved"

# ── Run ────────────────────────────────────────────────

start: $(IMAGE)
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "Pharo already running (PID $$(cat $(PID_FILE)))"; \
	else \
		if $(CURL) -f -d "'ping'" >/dev/null 2>&1; then \
			echo "FAIL: port $(PORT) already in use"; \
			exit 1; \
		fi; \
		echo ">> Starting Pharo on port $(PORT)..."; \
		DISPLAY=$${DISPLAY:-:1} $(IMAGE_DIR)/pharo-vm/pharo $(IMAGE) eval --no-quit \
			"PosternServer startOn: $(PORT)" \
			> $(LOG_FILE) 2>&1 & \
		echo $$! > $(PID_FILE); \
		for i in $$(seq 1 30); do \
			if $(CURL) -d "'ready'" >/dev/null 2>&1; then \
				echo "  ok Eval server ready on port $(PORT)"; \
				exit 0; \
			fi; \
			sleep 1; \
		done; \
		echo "  FAIL Server did not start. Check $(LOG_FILE)"; \
		exit 1; \
	fi

stop:
	@if [ -f $(PID_FILE) ]; then \
		PID=$$(cat $(PID_FILE)); \
		if kill -0 $$PID 2>/dev/null; then \
			echo ">> Stopping Pharo on port $(PORT) (PID $$PID)..."; \
			kill $$PID 2>/dev/null || true; \
			sleep 2; \
			kill -0 $$PID 2>/dev/null && kill -9 $$PID 2>/dev/null || true; \
		fi; \
		rm -f $(PID_FILE); \
		echo "  ok Stopped (port $(PORT))"; \
	else \
		echo "  No PID file for port $(PORT) — nothing to stop"; \
	fi

save:
	@$(CURL) -d "Smalltalk snapshot: true andQuit: false" >/dev/null
	@echo "  ok Image saved"

rebuild: stop clean-image setup
	@echo "  ok Fresh image rebuilt"

# ── Development ────────────────────────────────────────

filein:
	@echo ">> Reloading Tonel packages..."
	@$(CURL) -d "$(LOAD_PACKAGES_EXPR)"
	@echo ""

eval:
	@if [ -t 0 ]; then echo "Type Smalltalk, Ctrl-D to send:"; fi
	@$(CURL) -d @- || echo "Error: is the server running? (make start)"

test:
	@echo ">> Running Messaging SDK tests..."
	@RESULT=$$($(CURL) -d \
		"| result | \
		result := ClaudeMessagingTestSuite suite run. \
		'Tests: ', result runCount printString, \
		'  Passed: ', result passedCount printString, \
		'  Failures: ', result failureCount printString, \
		'  Errors: ', result errorCount printString") \
		&& echo "$${RESULT#\'}" | sed "s/'$$//" \
		|| echo "Error: is the server running? (make start)"

test-fast:
	@echo ">> Running fast Messaging SDK tests (no slow, no integration)..."
	@RESULT=$$($(CURL) -d \
		"| result | \
		result := ClaudeMessagingTestSuite fastSuite run. \
		'Tests: ', result runCount printString, \
		'  Passed: ', result passedCount printString, \
		'  Failures: ', result failureCount printString, \
		'  Errors: ', result errorCount printString") \
		&& echo "$${RESULT#\'}" | sed "s/'$$//" \
		|| echo "Error: is the server running? (make start)"

test-full:
	@echo ">> Running all Messaging SDK tests (including integration)..."
	@RESULT=$$($(CURL) -d \
		"| result | \
		result := ClaudeMessagingTestSuite fullSuite run. \
		'Tests: ', result runCount printString, \
		'  Passed: ', result passedCount printString, \
		'  Failures: ', result failureCount printString, \
		'  Errors: ', result errorCount printString") \
		&& echo "$${RESULT#\'}" | sed "s/'$$//" \
		|| echo "Error: is the server running? (make start)"

status:
	@echo ">> Checking eval server on port $(PORT)..."
	@RESULT=$$($(CURL) -d \
		"| classes | \
		classes := Smalltalk globals allClasses select: [ :c | \
			(c package name beginsWith: 'Claude-Messaging-') or: [ \
				c package name beginsWith: 'PharoKeyring' ] ]. \
		'alive -- ', classes size printString, ' SDK classes loaded'" 2>/dev/null) \
		&& echo "$${RESULT#\'}" | sed "s/'$$//" \
		|| echo "Not responding on port $(PORT)."

lint:
	@echo ">> Linting SDK classes..."
	@RESULT=$$($(CURL) -d \
		"| classes results | \
		classes := Smalltalk globals allClasses select: [ :c | \
			(c package name beginsWith: 'Claude-Messaging-') or: [ \
				c package name beginsWith: 'PharoKeyring' ] ]. \
		results := OrderedCollection new. \
		classes do: [ :cls | \
			| findings | \
			findings := OrderedCollection new. \
			[ (ReCriticEngine critiquesOf: cls) do: [ :c | \
				| entity | \
				entity := c sourceAnchor entity. \
				(entity isKindOf: CompiledMethod) \
					ifTrue: [ findings add: (entity methodClass instanceSide name, ' >> #', entity selector, ': ', c rule name) ] \
					ifFalse: [ findings add: (cls name, ': ', c rule name) ] ] ] \
				on: Error do: [ :e | findings add: (cls name, ': ERROR ', e messageText) ]. \
			findings ifEmpty: [ results add: cls name, ': clean' ] \
				ifNotEmpty: [ results addAll: findings ] ]. \
		results ifEmpty: [ 'No SDK classes found' ] \
			ifNotEmpty: [ String cr join: results ]") \
		&& LINT_OUTPUT="$${RESULT#\'}" \
		&& LINT_OUTPUT="$$(echo "$$LINT_OUTPUT" | sed "s/'$$//")" \
		&& echo "$$LINT_OUTPUT" \
		&& DIRTY=$$(echo "$$LINT_OUTPUT" | grep -v ': clean$$' | grep -v '^$$') \
		&& if [ -n "$$DIRTY" ]; then echo "  FAIL lint findings present (see above)"; exit 1; fi \
		&& echo "  ok lint clean" \
		|| echo "Error: is the server running? (make start)"

drift:
	@echo ">> Checking image-vs-disk method drift..."
	@RESULT=$$($(CURL) -d \
		"| dir pkgNames diskSels imageSels results sdkFilter | \
		dir := '$(SRC_DIR)' asFileReference. \
		pkgNames := ((dir children select: [ :d | d isDirectory and: [ (d / 'package.st') exists ] ]) collect: [ :d | d basename ]) \
			select: [ :n | (n beginsWith: 'Claude-Messaging-') or: [ n beginsWith: 'PharoKeyring' ] ]. \
		sdkFilter := [ :cls | (cls package name beginsWith: 'Claude-Messaging-') or: [ cls package name beginsWith: 'PharoKeyring' ] ]. \
		diskSels := Dictionary new. \
		results := OrderedCollection new. \
		pkgNames do: [ :pkg | \
			[ | reader version snapshot | \
			reader := TonelReader on: dir fileName: pkg. \
			version := reader version. \
			snapshot := version snapshot. \
			(snapshot definitions select: [ :d | d isMethodDefinition ]) do: [ :d | \
				| key sideKey entry | \
				key := d className. \
				sideKey := d classIsMeta ifTrue: [ #meta ] ifFalse: [ #inst ]. \
				entry := diskSels at: key ifAbsentPut: [ Dictionary new ]. \
				(entry at: sideKey ifAbsentPut: [ Set new ]) add: d selector ] ] \
			on: Error do: [ :e | results add: (pkg, ': ERROR ', e messageText) ] ]. \
		imageSels := Dictionary new. \
		(Smalltalk globals allClasses select: sdkFilter) do: [ :cls | \
			| entry | \
			entry := imageSels at: cls name ifAbsentPut: [ Dictionary new ]. \
			entry at: #inst put: cls methodDict keys asSet. \
			entry at: #meta put: cls class methodDict keys asSet ]. \
		(diskSels keys asSet union: imageSels keys) sorted do: [ :clsName | \
			| dEntry iEntry | \
			dEntry := diskSels at: clsName ifAbsent: [ Dictionary new ]. \
			iEntry := imageSels at: clsName ifAbsent: [ Dictionary new ]. \
			iEntry notEmpty \
				ifTrue: [ \
					{ #inst. #meta } do: [ :side | \
						| dSet iSet imageOnly diskOnly sideName | \
						dSet := dEntry at: side ifAbsent: [ Set new ]. \
						iSet := iEntry at: side ifAbsent: [ Set new ]. \
						sideName := side = #meta ifTrue: [ clsName, ' class' ] ifFalse: [ clsName ]. \
						imageOnly := iSet difference: dSet. \
						diskOnly := dSet difference: iSet. \
						(imageOnly isEmpty and: [ diskOnly isEmpty ]) \
							ifTrue: [ results add: sideName, ': clean' ] \
							ifFalse: [ results add: sideName, ': +', imageOnly size printString, '/-', diskOnly size printString, ' drift' ] ] ] \
				ifFalse: [ \
					| cls | \
					cls := Smalltalk globals at: clsName asSymbol ifAbsent: [ nil ]. \
					cls ifNotNil: [ results add: clsName, ' (ext): present in image, not found as SDK class' ] \
						ifNil: [ results add: clsName, ' (ext): not in image' ] ] ]. \
		String cr join: results") \
		&& echo "$${RESULT#\'}" | sed "s/'$$//" \
		|| echo "Error: is the server running? (make start)"
	@DRIFT=$$($(CURL) -d \
		"| dir pkgNames diskSels imageSels sdkFilter driftCount | \
		dir := '$(SRC_DIR)' asFileReference. \
		pkgNames := ((dir children select: [ :d | d isDirectory and: [ (d / 'package.st') exists ] ]) collect: [ :d | d basename ]) \
			select: [ :n | (n beginsWith: 'Claude-Messaging-') or: [ n beginsWith: 'PharoKeyring' ] ]. \
		sdkFilter := [ :cls | (cls package name beginsWith: 'Claude-Messaging-') or: [ cls package name beginsWith: 'PharoKeyring' ] ]. \
		diskSels := Dictionary new. \
		driftCount := 0. \
		pkgNames do: [ :pkg | \
			[ | reader version snapshot | \
			reader := TonelReader on: dir fileName: pkg. \
			version := reader version. \
			snapshot := version snapshot. \
			(snapshot definitions select: [ :d | d isMethodDefinition ]) do: [ :d | \
				| key sideKey entry | \
				key := d className. \
				sideKey := d classIsMeta ifTrue: [ #meta ] ifFalse: [ #inst ]. \
				entry := diskSels at: key ifAbsentPut: [ Dictionary new ]. \
				(entry at: sideKey ifAbsentPut: [ Set new ]) add: d selector ] ] \
			on: Error do: [:e | ] ]. \
		imageSels := Dictionary new. \
		(Smalltalk globals allClasses select: sdkFilter) do: [ :cls | \
			| entry | \
			entry := imageSels at: cls name ifAbsentPut: [ Dictionary new ]. \
			entry at: #inst put: cls methodDict keys asSet. \
			entry at: #meta put: cls class methodDict keys asSet ]. \
		(diskSels keys asSet union: imageSels keys) do: [ :clsName | \
			| dEntry iEntry | \
			dEntry := diskSels at: clsName ifAbsent: [ Dictionary new ]. \
			iEntry := imageSels at: clsName ifAbsent: [ Dictionary new ]. \
			iEntry notEmpty \
				ifTrue: [ \
					{ #inst. #meta } do: [ :side | \
						| dSet iSet | \
						dSet := dEntry at: side ifAbsent: [ Set new ]. \
						iSet := iEntry at: side ifAbsent: [ Set new ]. \
						((iSet difference: dSet) isEmpty and: [ (dSet difference: iSet) isEmpty ]) \
							ifFalse: [ driftCount := driftCount + 1 ] ] ] ]. \
		driftCount printString"); \
	case "$$DRIFT" in \
		"'0'") echo "  ok No drift detected" ;; \
		*) echo "  FAIL drift detected ($$DRIFT classes)"; exit 1 ;; \
	esac

check: check-packages lint
	@RESULT=$$($(CURL) -d \
		"| repo diff | \
		repo := IceRepository registry detect: [ :r | r name = 'claude-messaging-pharo' ] ifNone: [ nil ]. \
		repo ifNil: [ 'ERROR: no repo registered' ] ifNotNil: [ \
			diff := repo workingCopyDiff. \
			diff isEmpty ifTrue: [ 'clean' ] ifFalse: [ 'DIRTY' ] ]" \
		2>/dev/null) || RESULT="UNREACHABLE"; \
	case "$$RESULT" in \
		*clean*) echo "  ok Iceberg working copy clean" ;; \
		*DIRTY*) echo "  FAIL Iceberg has uncommitted image changes"; exit 1 ;; \
		UNREACHABLE) echo "  FAIL eval server not responding"; exit 1 ;; \
		*) echo "  FAIL unexpected: $$RESULT"; exit 1 ;; \
	esac

check-packages:
	@echo ">> Checking package completeness..."
	@RESULT=$$($(CURL) -d \
		"| dir expected loaded missing | \
		dir := '$(SRC_DIR)' asFileReference. \
		expected := ((dir children select: [ :d | d isDirectory and: [ (d / 'package.st') exists ] ]) collect: [ :d | d basename ]) asSet. \
		loaded := ((Smalltalk globals allClasses select: [ :c | \
			(c package name beginsWith: 'Claude-Messaging-') or: [ \
				(c package name beginsWith: 'PharoKeyring') or: [ \
					c package name = 'BaselineOfClaudeMessaging' ] ] ]) \
			collect: [ :c | c package name ]) asSet. \
		missing := expected difference: loaded. \
		missing isEmpty \
			ifTrue: [ 'OK:', expected size printString, ' packages on disk, all loaded' ] \
			ifFalse: [ 'MISSING:', (', ' join: missing sorted) ]" \
		2>/dev/null) || RESULT="UNREACHABLE"; \
	case "$$RESULT" in \
		*OK*) echo "  ok $$RESULT" ;; \
		*MISSING*) echo "  FAIL Packages not loaded: $$RESULT"; exit 1 ;; \
		UNREACHABLE) echo "  FAIL eval server not responding"; exit 1 ;; \
		*) echo "  FAIL unexpected: $$RESULT"; exit 1 ;; \
	esac

transcript:
	@$(CURL) -d "Transcript contents" || echo "Error: is the server running? (make start)"

spec:
	@echo ">> Building messaging-specification PDFs (two-pass)..."
	cd docs/specifications && pdflatex -interaction=nonstopmode messaging-specification.tex
	cd docs/specifications && pdflatex -interaction=nonstopmode messaging-specification.tex
	cd docs/specifications && pdflatex -interaction=nonstopmode messaging-specification-pharo-notes.tex
	cd docs/specifications && pdflatex -interaction=nonstopmode messaging-specification-pharo-notes.tex
	@echo "  ok PDFs built: messaging-specification.pdf, messaging-specification-pharo-notes.pdf"

# ── Clean ──────────────────────────────────────────────

clean-image:
	rm -f $(IMAGE) $(CHANGES) $(CURDIR)/.pharo-*.pid $(CURDIR)/.pharo-*.log
	rm -f $(IMAGE_DIR)/PharoDebug.log
	@echo "  ok Image removed"

clean:
	$(MAKE) stop 2>/dev/null || true
	rm -rf $(IMAGE_DIR) $(CURDIR)/.pharo-*.pid $(CURDIR)/.pharo-*.log
	rm -f PharoDebug.log
	@echo "  ok Clean"
