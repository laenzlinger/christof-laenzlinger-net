.PHONY: help build clean serve

help:
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the site with Hugo
	hugo

clean: ## Clean the public directory
	rm -rf public

serve: ## Serve the site locally
	hugo server -D --navigateToChanged

check: build ## Check internal links in the built site
	htmltest
