# Build context: the uim-platform repository root (the backend depends on
# the shared "service" package via a path dependency):
#   docker build -f data-retention/backend/Dockerfile -t uim-platform/data-retention .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/data-retention/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/data-retention/backend/build/uim-data-retention-platform-service /build/data-retention/backend/build/uim-data-retention-cli ./
COPY --from=build /build/data-retention/backend/config ./config
COPY --from=build /build/data-retention/frontend ./frontend
USER appuser

EXPOSE 8112
# Built-in login: set DR_JWT_SECRET (>= 32 characters) and DR_ADMIN_PASSWORD,
# e.g. from a Kubernetes secret (see k8s/secret.example.yaml).
ENV DR_HOST=0.0.0.0 \
    DR_PORT=8112 \
    DR_STORAGE=file \
    DR_DATA_FILE=/data/data-retention.json \
    DR_FRONTEND_DIR=/app/frontend \
    DR_AUTH_MODE=jwt
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8112/health || exit 1

CMD ["./uim-data-retention-platform-service"]
