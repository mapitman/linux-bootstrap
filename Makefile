.PHONY: help test test-auto test-interactive test-all test-syntax lint clean build-test-images docker-clean shellcheck

# Default target
.DEFAULT_GOAL := help

# Ubuntu versions to test
UBUNTU_VERSIONS := 20.04 22.04 24.04

help: ## Show this help message
	@echo "Linux Bootstrap Testing Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: test-auto ## Run automated tests (default: Ubuntu 22.04)

test-auto: ## Run automated tests on Ubuntu 22.04
	@./test/run-tests.sh auto

test-interactive: ## Start interactive Docker container for manual testing
	@./test/run-tests.sh interactive

test-all: ## Run tests on all Ubuntu versions (20.04, 22.04, 24.04)
	@./test/run-tests.sh all

test-syntax: ## Run syntax checks on all bash scripts
	@./test/run-tests.sh syntax

lint: shellcheck ## Run all linting tools

shellcheck: ## Run shellcheck on all scripts
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck bootstrap || true; \
		shellcheck ubuntu/bootstrap || true; \
		find ubuntu/ -type f -name 'install-*' -exec shellcheck {} \; || true; \
		find generic/ -type f -exec shellcheck {} \; || true; \
	else \
		echo "shellcheck not installed. Install with: sudo apt-get install shellcheck"; \
		exit 1; \
	fi

build-test-images: ## Build Docker test images for all Ubuntu versions
	@echo "Building test images for Ubuntu versions: $(UBUNTU_VERSIONS)"
	@for version in $(UBUNTU_VERSIONS); do \
		echo "Building Ubuntu $$version..."; \
		docker build \
			--build-arg UBUNTU_VERSION=$$version \
			-f test/docker/Dockerfile.ubuntu-noninteractive \
			-t ubuntu-bootstrap-test:$$version \
			.; \
	done

clean: docker-clean ## Clean up all test artifacts

docker-clean: ## Remove all test Docker images
	@echo "Cleaning up Docker test images..."
	@docker images | grep ubuntu-bootstrap-test | awk '{print $$3}' | xargs -r docker rmi || true
	@echo "Cleanup complete"

ci: test-syntax test-all ## Run full CI test suite (syntax + all versions)

quick: test-syntax test-auto ## Quick check: syntax + single version test
