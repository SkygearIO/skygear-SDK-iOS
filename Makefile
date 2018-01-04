VERSION := v$(shell git describe --always)
DOCS_AWS_BUCKET := docs.skygear.io
DOCS_AWS_DISTRIBUTION := E31J8XF8IPV2V
DOCS_PREFIX = /ios/reference
GIT_REF_NAME := master

ifeq ($(VERSION),)
$(error VERSION is empty)
endif

.PHONY: vendor
vendor:
	cd Example; pod install

.PHONY: release-commit
release-commit:
	./scripts/release-commit.sh

.PHONY: doc
doc:
	jazzy --github-file-prefix https://github.com/SkygearIO/skygear-SDK-iOS/tree/$(GIT_REF_NAME)
	cp -rf .github docs/

.PHONY: doc-clean
doc-clean:
	-rm docs

.PHONY: doc-upload
doc-upload:
	aws s3 sync docs s3://$(DOCS_AWS_BUCKET)$(DOCS_PREFIX)/$(VERSION) --delete

.PHONY: doc-invalidate
doc-invalidate:
	aws cloudfront create-invalidation --distribution-id $(DOCS_AWS_DISTRIBUTION) --paths "$(DOCS_PREFIX)/$(VERSION)/*"

.PHONY: doc-deploy
doc-deploy: doc-clean doc doc-upload doc-invalidate

.PHONY: format
format:
	./clang-check.sh fix
	swiftlint autocorrect

.PHONY: lint
lint:
	./clang-check.sh
	swiftlint lint
