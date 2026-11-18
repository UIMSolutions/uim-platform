# Multi-stage build for the Identity Provisioning service (REST + OData v4 + Fiori app)
# Compatible with Docker and Podman. Build from the uim-platform repository root,
# because the backend depends on uim-platform:service via a relative path:
#
#   podman build -f identity-provisioning/backend/Containerfile -t uim-platform/identity-provisioning .
#   docker build -f identity-provisioning/backend/Dockerfile    -t uim-platform/identity-provisioning .

# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /src
COPY . .

WORKDIR /src/identity-provisioning/backend
RUN dub build --build=release --config=defaultRun && \
    dub build --build=release --config=cli

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --system --no-create-home appuser

WORKDIR /app

COPY --from=builder /src/identity-provisioning/backend/build/uim-identity-provisioning-platform-service .
COPY --from=builder /src/identity-provisioning/backend/build/uim-ips-cli .
COPY --from=builder /src/identity-provisioning/backend/config/default.json config/default.json
COPY --from=builder /src/identity-provisioning/frontend frontend

RUN mkdir -p /app/data && chown appuser /app/data
USER appuser

EXPOSE 8093

ENV IPS_HOST=0.0.0.0 \
    IPS_PORT=8093 \
    IPS_DATA_DIR=/app/data \
    IPS_FRONTEND_DIR=/app/frontend

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8093/api/v1/health || exit 1

ENTRYPOINT ["./uim-identity-provisioning-platform-service"]
