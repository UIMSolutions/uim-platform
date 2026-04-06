# Multi-stage build for Situation Automation Service
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
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --no-create-home appuser

WORKDIR /app

COPY --from=builder /app/build/uim-situation-automation-platform-service .

USER appuser

EXPOSE 8100

ENV SITUATION_AUTOMATION_HOST=0.0.0.0
ENV SITUATION_AUTOMATION_PORT=8100

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8100/api/v1/health || exit 1

ENTRYPOINT ["./uim-situation-automation-platform-service"]
