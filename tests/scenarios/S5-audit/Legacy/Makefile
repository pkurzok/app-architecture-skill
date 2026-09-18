.PHONY: generate clean test lint build-app verify all

generate:
	xcodegen generate

# Wipe every package's SwiftPM build directory. Reach for this when `make test` fails with
# phantom "cannot find type" / "no such module" errors right after a lower-layer package's
# sources or Package.swift changed: the dependants' caches are stale, not the code.
clean:
	rm -rf Packages/*/.build

test:
	bash scripts/test-all.sh

lint:
	swiftlint lint --strict

build-app:
	xcodebuild -quiet -project Legacy.xcodeproj -scheme Legacy \
		-destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

# The backpressure a task must pass before it is complete: unit + architecture tests, then a
# zero-warning lint.
verify: test lint

all: generate test lint build-app
