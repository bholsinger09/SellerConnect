# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

RUN apt-get update && apt-get install -y libjemalloc-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy the backend - verbose output
COPY SellerConnectBackend . 

# Build without extra checks
RUN swift build -c release

# ================================
# Run image
# ================================
FROM ubuntu:noble

RUN apt-get update && apt-get install -y ca-certificates libjemalloc2 && rm -rf /var/lib/apt/lists/*

RUN useradd -m vapor
WORKDIR /app

COPY --from=build /build/.build/release/SellerConnectBackend /app/app
RUN chmod +x /app/app

USER vapor
EXPOSE 8080
CMD ["/app/app"]
