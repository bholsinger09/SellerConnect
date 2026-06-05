# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

# Install dependencies
RUN apt-get update && apt-get install -y libjemalloc-dev && rm -rf /var/lib/apt/lists/*

# Set up build area
WORKDIR /build

# Debug: List what we're copying
RUN echo "Starting build..." && pwd && ls -la

# Copy the backend
COPY SellerConnectBackend . 

# Debug: Check if Package.swift is there
RUN ls -la . && test -f Package.swift && echo "Package.swift found!"

# Build
RUN swift build -c release

# ================================
# Run image
# ================================
FROM ubuntu:noble

RUN apt-get update && apt-get install -y ca-certificates libjemalloc2 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash vapor
WORKDIR /app

COPY --from=build /build/.build/release/SellerConnectBackend /app/app
RUN chmod +x /app/app

USER vapor
EXPOSE 8080
CMD ["/app/app"]
