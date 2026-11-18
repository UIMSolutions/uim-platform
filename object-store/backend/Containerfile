# Multi-stage build for the Object Store service (REST + content API + OData v4 + Fiori app)
# Compatible with Docker and Podman. Build from the uim-platform repository root,
# because the backend depends on the "service" package via a relative path:
#
#   podman build -f object-store/backend/Containerfile -t uim-platform/cloud-object-store .
#   docker build -f object-store/backend/Dockerfile    -t uim-platform/cloud-object-store .

# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /src
COPY service service
COPY object-store object-store

WORKDIR /src/object-store/backend
RUN dub build --build=release --config=defaultRun && \
    dub build --build=release --config=cli

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --no-create-home appuser

WORKDIR /app

COPY --from=builder /src/object-store/backend/build/uim-object-store-platform-service .
COPY --from=builder /src/object-store/backend/build/uim-object-store-cli .
COPY --from=builder /src/object-store/backend/config/default.json config/default.json
COPY --from=builder /src/object-store/frontend frontend

RUN mkdir -p /app/data && chown appuser /app/data
USER appuser

EXPOSE 8092

ENV OBJSTORE_HOST=0.0.0.0 \
    OBJSTORE_PORT=8092 \
    OBJSTORE_DATA_DIR=/app/data \
    OBJSTORE_FRONTEND_DIR=/app/frontend

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8092/api/v1/health || exit 1

ENTRYPOINT ["./uim-object-store-platform-service"]
