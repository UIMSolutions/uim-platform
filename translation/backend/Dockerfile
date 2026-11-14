# Multi-stage build for the Translation Hub service (REST + OData v4 + Fiori app)
# Compatible with Docker and Podman. Build from the uim-platform repository root,
# because the backend depends on uim-platform:service via a relative path:
#
#   podman build -f translation/backend/Containerfile -t uim-platform/cloud-translation .
#   docker build -f translation/backend/Dockerfile    -t uim-platform/cloud-translation .

# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /src
COPY . .

WORKDIR /src/translation/backend
RUN dub build --build=release --config=defaultRun && \
    dub build --build=release --config=cli

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --no-create-home appuser

WORKDIR /app

COPY --from=builder /src/translation/backend/build/uim-translation-platform-service .
COPY --from=builder /src/translation/backend/build/uim-translation-cli .
COPY --from=builder /src/translation/backend/config/default.json config/default.json
COPY --from=builder /src/translation/frontend frontend

RUN mkdir -p /app/data && chown appuser /app/data
USER appuser

EXPOSE 8096

ENV TRANSLATION_HOST=0.0.0.0 \
    TRANSLATION_PORT=8096 \
    TRANSLATION_DATA_DIR=/app/data \
    TRANSLATION_FRONTEND_DIR=/app/frontend

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8096/api/v1/health || exit 1

ENTRYPOINT ["./uim-translation-platform-service"]
