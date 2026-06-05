# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up a build area
WORKDIR /app

# Copy entire backend directory
COPY SellerConnectBackend/ .

# Resolve dependencies and build
RUN swift package resolve && \
    swift build -c release -v

# ================================
# Run image
# ================================
FROM ubuntu:noble

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Create a vapor user
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

# Copy built executable from builder
COPY --from=build --chown=vapor:vapor /app/.build/release/SellerConnectBackend /app/bin/SellerConnectBackend

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["/app/bin/SellerConnectBackend"]
