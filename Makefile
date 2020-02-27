.PHONY: pretty

pretty:
	docker run --rm -v "$(shell pwd):/app" slashmo/swiftformat:0.44.0
