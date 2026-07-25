.PHONY: check doctor test fmt ai-status ai-context stage0-fetch stage0-verify host-seed-capture host-seed-verify dev-image test-dev-image test-installer test-installed-image run-dev-image run-installed-image

check:
	./scripts/check

doctor:
	./scripts/doctor

test:
	cargo test --workspace

fmt:
	cargo fmt --all

ai-status:
	./scripts/ai-collab status

ai-context:
	./scripts/ai-collab context

stage0-fetch:
	./bootstrap/fetch-sources

stage0-verify:
	./bootstrap/verify-sources

host-seed-capture:
	./bootstrap/capture-host-seed

host-seed-verify:
	./bootstrap/verify-host-seed

dev-image:
	./scripts/build-dev-image

test-dev-image:
	./scripts/test-dev-image

test-installer:
	./scripts/test-installer

test-installed-image:
	./scripts/test-installed-image

run-dev-image:
	./scripts/run-dev-image

run-installed-image:
	./scripts/run-installed-image
