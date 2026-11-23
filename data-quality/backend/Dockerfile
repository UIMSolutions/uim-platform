# Build context: the uim-platform repository root (the backend depends on
# the shared "service" package via a path dependency):
#   docker build -f data-quality/backend/Dockerfile -t uim-platform/data-quality .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/data-quality/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/data-quality/backend/build/uim-data-quality-platform-service /build/data-quality/backend/build/uim-data-quality-cli ./
COPY --from=build /build/data-quality/backend/config ./config
COPY --from=build /build/data-quality/frontend ./frontend
USER appuser

EXPOSE 8086
# Built-in login: set DQ_JWT_SECRET (>= 32 characters) and DQ_ADMIN_PASSWORD,
# e.g. from a Kubernetes secret (see k8s/secret.example.yaml).
ENV DQ_HOST=0.0.0.0 \
    DQ_PORT=8086 \
    DQ_STORAGE=file \
    DQ_DATA_FILE=/data/data-quality.json \
    DQ_FRONTEND_DIR=/app/frontend \
    DQ_AUTH_MODE=jwt
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8086/health || exit 1

CMD ["./uim-data-quality-platform-service"]
