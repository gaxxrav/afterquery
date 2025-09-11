FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Keep original ports.ubuntu.com - it's the correct source for ARM64
# No sed replacement needed - ports.ubuntu.com is already correct for ARM64

# Configure apt for maximum reliability with ARM64
RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/80-timeout && \
    echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/90-pipeline && \
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90-assumeyes

# Clean apt cache thoroughly and install system dependencies
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    gawk \
    sed \
    grep \
    coreutils \
    findutils \
    python3 \
    python3-pip \
    python3-pytest \
    tzdata \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace/

# Make scripts executable
RUN chmod +x solution.sh run-tests.sh scripts/generate_sample_data.sh

# Install Python test dependencies inside container
RUN python3 -m pip install --no-cache-dir pandas pytest

# Create reports directory
RUN mkdir -p reports test_results

# Set default command to run the solution
CMD ["./solution.sh"]
