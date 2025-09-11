# Keep original ports.ubuntu.com - correct source for ARM64
# No sed replacement needed - ports.ubuntu.com is correct for ARM64

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/80-timeout && \
    echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/90-pipeline && \
    echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90-assumeyes

# install system dependencies
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

WORKDIR /workspace
COPY . /workspace/
RUN chmod +x solution.sh run-tests.sh scripts/generate_sample_data.sh
RUN python3 -m pip install --no-cache-dir pandas pytest
RUN mkdir -p reports test_results
CMD ["./solution.sh"]