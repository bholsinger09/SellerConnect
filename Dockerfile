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
WORKDIR /build

# Copy backend files
COPY SellerConnectBackend .

# Build the application
RUN swift build -c release -v

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
COPY --from=build --chown=vapor:vapor /build/.build/release/SellerConnectBackend /app/SellerConnectBackend

# Copy resources if they exist
COPY --from=build --chown=vapor:vapor /build/Public /app/Public 2>/dev/null || true
COPY --from=build --chown=vapor:vapor /build/Resources /app/Resources 2>/dev/null || true

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["/app/SellerConnectBackend"]
