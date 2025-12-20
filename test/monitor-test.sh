#!/bin/bash
# Monitor and log the test output for debugging
# Usage: ./test/monitor-test.sh [output-file]

OUTPUT_FILE="${1:-test-output-$(date +%Y%m%d-%H%M%S).log}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Running interactive test and logging to: $OUTPUT_FILE"
echo "Press Ctrl+C to stop the test"
echo ""

cd "$PROJECT_ROOT"

# Build the image
echo "Building test image..."
docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test . 2>&1 | tee "$OUTPUT_FILE"

# Run the container and execute the bootstrap automatically
echo ""
echo "Running bootstrap in container..."
echo "(Answering 'n' to all prompts automatically)"
echo ""

{
    echo "Container started at: $(date)"
    echo "========================================"
    echo ""
    # Run bootstrap with automatic "no" answers
    docker run --rm ubuntu-bootstrap-test bash -c "
        cd linux-bootstrap
        echo 'Testing bootstrap with automatic no responses...'
        echo -e '\n\n\n\n' | bash bootstrap 2>&1
        EXIT_CODE=\$?
        echo ''
        echo '========================================'
        echo 'Bootstrap completed with exit code:' \$EXIT_CODE
        exit \$EXIT_CODE
    "
} 2>&1 | tee -a "$OUTPUT_FILE"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "========================================"
echo "Test completed with exit code: $EXIT_CODE"
echo "Full output saved to: $OUTPUT_FILE"
echo ""

if [ $EXIT_CODE -ne 0 ]; then
    echo "FAILURES DETECTED - Review the log file for details"
    exit 1
else
    echo "All tests passed!"
    exit 0
fi
