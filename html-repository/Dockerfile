# Multi-stage build for HTML5 Application Repository Service
# Works with both Docker and Podman

# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /app

# Copy dependency files first for layer caching
COPY dub.sdl dub.selections.json ./
COPY source/ source/

# Build release binary
RUN dub build --build=release --config=defaultRun

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --no-create-home appuser

WORKDIR /app

COPY --from=builder /app/build/uim-html-repository-platform-service .

USER appuser

EXPOSE 8097

ENV HTML_REPO_HOST=0.0.0.0
ENV HTML_REPO_PORT=8097

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8097/api/v1/health || exit 1

ENTRYPOINT ["./uim-html-repository-platform-service"]
