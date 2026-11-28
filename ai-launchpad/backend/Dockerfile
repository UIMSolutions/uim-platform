# Build context: the uim-platform repository root (the backend depends on
# the shared "service" package via a path dependency):
#   docker build -f ai-launchpad/backend/Dockerfile -t uim-platform/ai-launchpad .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/ai-launchpad/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/ai-launchpad/backend/build/uim-ai-launchpad-platform-service /build/ai-launchpad/backend/build/uim-ai-launchpad-cli ./
COPY --from=build /build/ai-launchpad/backend/config ./config
COPY --from=build /build/ai-launchpad/frontend ./frontend
USER appuser

EXPOSE 8097
# Built-in login: set AILP_JWT_SECRET (>= 32 characters) and AILP_ADMIN_PASSWORD,
# e.g. from a Kubernetes secret (see k8s/secret.example.yaml).
ENV AILP_HOST=0.0.0.0 \
    AILP_PORT=8097 \
    AILP_STORAGE=file \
    AILP_DATA_FILE=/data/ai-launchpad.json \
    AILP_FRONTEND_DIR=/app/frontend \
    AILP_AUTH_MODE=jwt
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8097/health || exit 1

CMD ["./uim-ai-launchpad-platform-service"]
