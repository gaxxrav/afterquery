#!/bin/bash

# Quick Docker build test for ARM64 mirror fix
set -euo pipefail

echo "🔧 Testing Docker build with Cloudflare mirror..."

# Clean up
docker rmi csv-pipeline 2>/dev/null || true

# Test build
echo "Building with Cloudflare mirror (this may take 2-3 minutes)..."
if timeout 300 docker build --no-cache -t csv-pipeline . 2>&1 | tee build.log; then
    echo "Build successful!"
    
    # Quick container test
    if docker run --rm csv-pipeline echo "Container works!"; then
        echo "Container execution successful!"
        echo "ARM64 mirror fix appears to be working!"
    else
        echo "Container execution failed"
    fi
else
    echo "Build failed. Checking build log for errors..."
    if grep -i "hash sum mismatch\|404\|failed to fetch" build.log; then
        echo "Mirror issues detected. Consider trying Ubuntu 20.04:"
        echo "cp Dockerfile.ubuntu20 Dockerfile"
    fi
fi
