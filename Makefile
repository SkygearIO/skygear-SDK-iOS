.PHONY: docs
docs:
	jazzy

.PHONY: clean-docs
clean-docs:
	-rm docs

.PHONY: format
format:
	./clang-check.sh fix
	swiftlint autocorrect

.PHONY: lint
lint:
	./clang-check.sh
	swiftlint lint

