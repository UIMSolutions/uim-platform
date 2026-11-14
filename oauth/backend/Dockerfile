# Build context: the uim-platform repository root (the backend depends on
# uim-platform:service via a path dependency):
#   docker build -f oauth/backend/Dockerfile -t uim-platform/oauth .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/oauth/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/oauth/backend/build/uim-oauth-platform-service /build/oauth/backend/build/uim-oauth-cli ./
COPY --from=build /build/oauth/backend/config ./config
COPY --from=build /build/oauth/frontend ./frontend
USER appuser

EXPOSE 8114
# Provide OAUTH_SIGNING_SECRET (>= 32 chars) and OAUTH_ISSUER at runtime, e.g. from a secret.
ENV OAUTH_HOST=0.0.0.0 \
    OAUTH_PORT=8114 \
    OAUTH_STORAGE=file \
    OAUTH_DATA_FILE=/data/oauth.json \
    OAUTH_FRONTEND_DIR=/app/frontend
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8114/health || exit 1

CMD ["./uim-oauth-platform-service"]
