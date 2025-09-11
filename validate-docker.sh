#!/bin/bash

# Docker validation script - Enhanced retry configuration for ARM64
set -euo pipefail

echo "🐳 Testing Docker build with enhanced retry configuration for ARM64..."

# Clean up any existing images and build cache
echo "Cleaning up existing images and build cache..."
docker rmi csv-pipeline 2>/dev/null || true
docker builder prune -f 2>/dev/null || true

# Build with no cache to test the enhanced retry configuration
echo "Building Docker image with ports.ubuntu.com and enhanced retries..."
echo "This may take 2-3 minutes due to package downloads..."

if docker build --no-cache --progress=plain -t csv-pipeline .; then
    echo "✅ Docker build successful with enhanced retry configuration!"
else
    echo "❌ Docker build failed"
    echo "💡 If ports.ubuntu.com still fails, try Ubuntu 20.04 fallback:"
    echo "   cp Dockerfile.ubuntu20 Dockerfile && docker build -t csv-pipeline ."
    exit 1
fi

# Test container startup
echo "Testing container startup..."
if docker run --rm csv-pipeline echo "Container startup test successful"; then
    echo "✅ Container startup successful!"
else
    echo "❌ Container startup failed"
    exit 1
fi

# Test running the solution in container
echo "Testing solution execution in container..."
if timeout 30 docker run --rm -v $(pwd):/workspace -w /workspace csv-pipeline ./solution.sh; then
    echo "✅ Solution execution successful!"
else
    echo "❌ Solution execution failed or timed out"
    exit 1
fi

# Test pytest availability in container
echo "Testing pytest availability in container..."
if docker run --rm csv-pipeline python3 -c "import pytest; print('✅ pytest version:', pytest.__version__)"; then
    echo "✅ pytest available in container!"
else
    echo "❌ pytest not available in container"
    exit 1
fi

# Test full test suite execution
echo "Testing full test suite in container..."
if timeout 60 docker run --rm -v $(pwd):/workspace -w /workspace csv-pipeline ./run-tests.sh; then
    echo "✅ Full test suite successful!"
else
    echo "❌ Test suite failed or timed out"
    exit 1
fi

echo ""
echo "🎉 All Docker validation tests passed!"
echo "✅ Archive issues resolved"
echo "✅ Container builds and runs successfully"
echo "✅ Solution and tests execute properly"
echo ""
echo "Ready for AfterQuery submission! 🚀"
