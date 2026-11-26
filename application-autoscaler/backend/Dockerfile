# Build context: the uim-platform repository root (the backend depends on
# the shared "service" package via a path dependency):
#   docker build -f application-autoscaler/backend/Dockerfile -t uim-platform/application-autoscaler .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/application-autoscaler/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/application-autoscaler/backend/build/uim-application-autoscaler-platform-service /build/application-autoscaler/backend/build/uim-application-autoscaler-cli ./
COPY --from=build /build/application-autoscaler/backend/config ./config
COPY --from=build /build/application-autoscaler/frontend ./frontend
USER appuser

EXPOSE 8097
# Built-in login: set AUTOSCALER_JWT_SECRET (>= 32 characters) and AUTOSCALER_ADMIN_PASSWORD,
# e.g. from a Kubernetes secret (see k8s/secret.example.yaml).
ENV AUTOSCALER_HOST=0.0.0.0 \
    AUTOSCALER_PORT=8097 \
    AUTOSCALER_STORAGE=file \
    AUTOSCALER_DATA_FILE=/data/application-autoscaler.json \
    AUTOSCALER_FRONTEND_DIR=/app/frontend \
    AUTOSCALER_AUTH_MODE=jwt
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8097/health || exit 1

CMD ["./uim-application-autoscaler-platform-service"]
