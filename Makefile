.PHONY: check doctor test fmt

check:
	./scripts/check

doctor:
	./scripts/doctor

test:
	cargo test --workspace

fmt:
	cargo fmt --all
