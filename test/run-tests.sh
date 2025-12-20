#!/bin/bash
# Quick test runner for Ubuntu bootstrap scripts
# Usage: ./test/run-tests.sh [interactive|auto|all|syntax|clean]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${GREEN}===================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}===================================${NC}\n"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

MODE="${1:-auto}"

case "$MODE" in
    interactive|i)
        print_header "Building Interactive Test Container"
        docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test .
        
        print_header "Starting Interactive Test Session"
        echo "You can now test scripts manually. Try:"
        echo "  cd linux-bootstrap"
        echo "  bash ubuntu/install-essential-packages"
        echo ""
        docker run -it --rm ubuntu-bootstrap-test
        ;;
    
    auto|a)
        print_header "Running Automated Tests"
        
        # Test Ubuntu 24.04
        print_header "Testing Ubuntu 24.04 LTS"
        docker build \
            --build-arg UBUNTU_VERSION=24.04 \
            -f test/docker/Dockerfile.ubuntu-noninteractive \
            -t ubuntu-bootstrap-test:24.04 \
            .
        docker run --rm ubuntu-bootstrap-test:24.04
        
        echo -e "\n${GREEN}✓ Ubuntu 24.04 tests passed${NC}\n"
        ;;
    
    all)
        print_header "Running Comprehensive Tests"
        
        VERSIONS=("24.04" "25.10")
        FAILED=()
        
        for VERSION in "${VERSIONS[@]}"; do
            print_header "Testing Ubuntu $VERSION"
            
            if docker build \
                --build-arg UBUNTU_VERSION="$VERSION" \
                -f test/docker/Dockerfile.ubuntu-noninteractive \
                -t ubuntu-bootstrap-test:"$VERSION" \
                . && \
               docker run --rm ubuntu-bootstrap-test:"$VERSION"; then
                echo -e "\n${GREEN}✓ Ubuntu $VERSION tests passed${NC}\n"
            else
                print_error "Ubuntu $VERSION tests failed"
                FAILED+=("$VERSION")
            fi
        done
        
        # Summary
        print_header "Test Summary"
        if [ ${#FAILED[@]} -eq 0 ]; then
            echo -e "${GREEN}All tests passed!${NC}"
        else
            echo -e "${RED}Failed versions: ${FAILED[*]}${NC}"
            exit 1
        fi
        ;;
    
    syntax)
        print_header "Running Syntax Checks"
        
        echo "Checking bootstrap scripts..."
        bash -n bootstrap
        bash -n ubuntu/bootstrap
        
        echo "Checking ubuntu scripts..."
        for script in ubuntu/install-*; do
            echo "  Checking $script"
            bash -n "$script"
        done
        
        echo "Checking generic scripts..."
        for script in generic/*; do
            echo "  Checking $script"
            bash -n "$script"
        done
        
        echo -e "\n${GREEN}✓ All syntax checks passed${NC}\n"
        
        if command -v shellcheck &> /dev/null; then
            print_header "Running ShellCheck"
            # ShellCheck is treated as advisory linting here; syntax errors still fail via set -e
            shellcheck bootstrap ubuntu/bootstrap || print_warning "ShellCheck found issues"
        else
            print_warning "shellcheck not installed, skipping advanced linting"
            echo "Install with: sudo apt-get install shellcheck"
        fi
        ;;
    
    clean)
        print_header "Cleaning Up Test Images"
        docker images | grep ubuntu-bootstrap-test | awk '{print $3}' | xargs -r docker rmi
        echo -e "${GREEN}Cleanup complete${NC}"
        ;;
    
    *)
        echo "Usage: ./test/run-tests.sh [interactive|auto|all|syntax|clean]"
        echo ""
        echo "Modes:"
        echo "  interactive (i) - Start interactive Docker container for manual testing"
        echo "  auto (a)       - Run automated tests on Ubuntu 24.04 (default)"
        echo "  all            - Run tests on Ubuntu 24.04 and 25.10"
        echo "  syntax         - Run syntax checks and linting only"
        echo "  clean          - Remove all test Docker images"
        echo ""
        echo "Examples:"
        echo "  ./test/run-tests.sh auto          # Quick automated test"
        echo "  ./test/run-tests.sh interactive   # Manual testing"
        echo "  ./test/run-tests.sh all           # Full test suite"
        exit 1
        ;;
esac
