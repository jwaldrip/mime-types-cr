docs:
	@crystal doc
	@rm -rf ./docs
	@mv ./doc ./docs

.PHONY: docs
