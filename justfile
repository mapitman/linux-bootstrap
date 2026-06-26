# Variables
ubuntu_versions := "24.04 25.10"
debian_versions := "trixie"

# Show available recipes and help information
default:
    @just --list

# Run automated tests (default: Ubuntu 24.04)
test: test-auto

# Run automated tests on Ubuntu 24.04
test-auto:
    ./test/run-tests.sh auto

# Start interactive Docker container for manual testing
test-interactive:
    ./test/run-tests.sh interactive

# Run tests on all Ubuntu versions (24.04, 25.10)
test-all:
    ./test/run-tests.sh all

# Run automated tests on Debian trixie
test-debian:
    ./test/run-tests.sh debian

# Run tests on all Debian versions (trixie)
test-debian-all:
    ./test/run-tests.sh debian-all

# Run syntax checks on all bash scripts
test-syntax:
    ./test/run-tests.sh syntax

# Run all linting tools
lint: shellcheck

# Run shellcheck on all scripts
shellcheck:
    #!/usr/bin/env bash
    echo "Running shellcheck..."
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck -x --severity=error bootstrap
        find debian/ -type f -exec shellcheck -x --severity=error {} \+
        shellcheck -x --severity=error ubuntu/bootstrap
        find ubuntu/ -type f -name 'install-*' -exec shellcheck -x --severity=error {} \+
        find generic/ -type f -exec shellcheck -x --severity=error {} \+
    else
        echo "shellcheck not installed. Install with: sudo apt-get install shellcheck"
        exit 1
    fi

# Build Docker test images for all Ubuntu versions
build-test-images:
    #!/usr/bin/env bash
    echo "Building test images for Ubuntu versions: {{ubuntu_versions}}"
    for version in {{ubuntu_versions}}; do
        echo "Building Ubuntu $version..."
        docker build \
            --build-arg UBUNTU_VERSION=$version \
            -f test/docker/Dockerfile.ubuntu-noninteractive \
            -t ubuntu-bootstrap-test:$version \
            .
    done

# Build Docker test images for all Debian versions
build-test-images-debian:
    #!/usr/bin/env bash
    echo "Building test images for Debian versions: {{debian_versions}}"
    for version in {{debian_versions}}; do
        echo "Building Debian $version..."
        docker build \
            --build-arg DEBIAN_VERSION=$version \
            -f test/docker/Dockerfile.debian-noninteractive \
            -t debian-bootstrap-test:$version \
            .
    done

# Clean up all test artifacts
clean: docker-clean

# Remove all test Docker images
docker-clean:
    #!/usr/bin/env bash
    echo "Cleaning up Docker test images..."
    docker images | grep -E 'ubuntu-bootstrap-test|debian-bootstrap-test' | awk '{print $3}' | xargs -r docker rmi || true
    echo "Cleanup complete"

# Run full CI test suite (syntax + all versions)
ci: test-syntax test-all test-debian-all

# Quick check: syntax + single-version Ubuntu and Debian tests
quick: test-syntax test-auto test-debian
