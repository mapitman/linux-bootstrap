.PHONY: help test test-auto test-interactive test-all test-debian test-debian-all test-syntax lint clean build-test-images build-test-images-debian docker-clean shellcheck

# Default target
.DEFAULT_GOAL := help

# Ubuntu versions to test
UBUNTU_VERSIONS := 24.04 25.10
DEBIAN_VERSIONS := bookworm trixie

help: ## Show this help message
	@echo "Linux Bootstrap Testing Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

test: test-auto ## Run automated tests (default: Ubuntu 24.04)

test-auto: ## Run automated tests on Ubuntu 24.04
	@./test/run-tests.sh auto

test-interactive: ## Start interactive Docker container for manual testing
	@./test/run-tests.sh interactive

test-all: ## Run tests on all Ubuntu versions (24.04, 25.10)
	@./test/run-tests.sh all

test-debian: ## Run automated tests on Debian bookworm
	@./test/run-tests.sh debian

test-debian-all: ## Run tests on all Debian versions (bookworm, trixie)
	@./test/run-tests.sh debian-all

test-syntax: ## Run syntax checks on all bash scripts
	@./test/run-tests.sh syntax

lint: shellcheck ## Run all linting tools

shellcheck: ## Run shellcheck on all scripts
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -x --severity=error bootstrap; \
		find debian/ -type f -exec shellcheck -x --severity=error {} \+; \
		shellcheck -x --severity=error ubuntu/bootstrap; \
		find ubuntu/ -type f -name 'install-*' -exec shellcheck -x --severity=error {} \+; \
		find generic/ -type f -exec shellcheck -x --severity=error {} \+; \
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

build-test-images-debian: ## Build Docker test images for all Debian versions
	@echo "Building test images for Debian versions: $(DEBIAN_VERSIONS)"
	@for version in $(DEBIAN_VERSIONS); do \
		echo "Building Debian $$version..."; \
		docker build \
			--build-arg DEBIAN_VERSION=$$version \
			-f test/docker/Dockerfile.debian-noninteractive \
			-t debian-bootstrap-test:$$version \
			.; \
	done

clean: docker-clean ## Clean up all test artifacts

docker-clean: ## Remove all test Docker images
	@echo "Cleaning up Docker test images..."
	@docker images | grep -E 'ubuntu-bootstrap-test|debian-bootstrap-test' | awk '{print $$3}' | xargs -r docker rmi || true
	@echo "Cleanup complete"

ci: test-syntax test-all test-debian-all ## Run full CI test suite (syntax + all versions)

quick: test-syntax test-auto test-debian ## Quick check: syntax + single-version Ubuntu and Debian tests
