.PHONY: docs
docs:
	jazzy

.PHONY: clean-docs
clean-docs:
	-rm docs

.PHONY: format
format:
	./clang-check.sh fix
