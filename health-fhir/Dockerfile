# Multi-stage build for UIM Health FHIR Service
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

RUN mkdir -p /app/data && chown appuser:appuser /app/data

COPY --from=builder /app/build/uim-health-fhir-platform-service .

USER appuser

EXPOSE 8097

ENV HEALTHFHIR_HOST=0.0.0.0
ENV HEALTHFHIR_PORT=8097
ENV HEALTHFHIR_STORAGE=memory
ENV HEALTHFHIR_DATA_PATH=/app/data
ENV HEALTHFHIR_MONGO_URI=

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8097/api/v1/health || exit 1

ENTRYPOINT ["./uim-health-fhir-platform-service"]
