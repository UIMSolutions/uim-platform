# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /app

COPY dub.sdl dub.selections.json* ./
COPY source ./source

RUN dub build --compiler=ldc2 --build=release --config=executable 2>&1

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    libgcc-s1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/build/uim-hana-spatial-platform-service .

ENV HANA_SPATIAL_HOST=0.0.0.0
ENV HANA_SPATIAL_PORT=8098

EXPOSE 8098

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8098/api/v1/health || exit 1

ENTRYPOINT ["/app/uim-hana-spatial-platform-service"]
