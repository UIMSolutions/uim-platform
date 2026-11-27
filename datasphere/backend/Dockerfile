# Build context: the uim-platform repository root (the backend depends on
# the shared "service" package via a path dependency):
#   docker build -f datasphere/backend/Dockerfile -t uim-platform/datasphere .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/datasphere/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/datasphere/backend/build/uim-datasphere-platform-service /build/datasphere/backend/build/uim-datasphere-cli ./
COPY --from=build /build/datasphere/backend/config ./config
COPY --from=build /build/datasphere/frontend ./frontend
USER appuser

EXPOSE 8095
# Built-in login: set DATASPHERE_JWT_SECRET (>= 32 characters) and DATASPHERE_ADMIN_PASSWORD,
# e.g. from a Kubernetes secret (see k8s/secret.example.yaml).
ENV DATASPHERE_HOST=0.0.0.0 \
    DATASPHERE_PORT=8095 \
    DATASPHERE_STORAGE=file \
    DATASPHERE_DATA_FILE=/data/datasphere.json \
    DATASPHERE_FRONTEND_DIR=/app/frontend \
    DATASPHERE_AUTH_MODE=jwt
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8095/health || exit 1

CMD ["./uim-datasphere-platform-service"]
