# Docker ARM64 Build - Correct Solution

## Current Status: Enhanced Retry Configuration for ports.ubuntu.com

### Root Cause Analysis:
- **Problem**: ARM64 packages require `ports.ubuntu.com/ubuntu-ports/` (not main archive)
- **Arizona mirror failed**: Only mirrors amd64 packages
- **Cloudflare certificate issues**: Certificate verification failures
- **Kernel.org redirect issue**: Redirects to CDN edge nodes that don't serve ubuntu-ports correctly
- **archive.ubuntu.com failed**: Main archive doesn't serve ARM64 packages (404 for binary-arm64)

### Correct Solution Applied:
1. **Keep original ports.ubuntu.com** - the only correct source for ARM64:
   ```dockerfile
   # No sed replacement needed - ports.ubuntu.com is already correct for ARM64
   ```

2. **Enhanced retry configuration for reliability**:
   ```dockerfile
   RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries && \
       echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/80-timeout && \
       echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/90-pipeline && \
       echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90-assumeyes
   ```

3. **Thorough cache cleaning** to avoid sync issues:
   ```dockerfile
   RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
       apt-get clean && apt-get update && \
       # ... install packages ... && \
       rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
   ```

### Test Commands:

#### Primary Test:
```bash
docker build --no-cache -t csv-test . 2>&1 | tee build.log
```

#### Full Validation:
```bash
./validate-docker.sh
```

### Expected Outcome:
- Stable ARM64 package installation from correct source
- Enhanced retry logic handles transient network issues
- No mirror redirects or CDN edge node problems

### Fallback Strategy:
- **Only if ports.ubuntu.com consistently fails**: Try Ubuntu 20.04 base image
- **Command**: `cp Dockerfile.ubuntu20 Dockerfile && docker build -t csv-test .`

### Why This Approach Works:
- **Correct source**: ports.ubuntu.com is the official ARM64 package repository
- **No mirror confusion**: Direct connection to the right endpoint
- **Enhanced reliability**: 10 retries, 60s timeout, disabled pipelining
- **Clean cache**: Prevents stale package index problems
