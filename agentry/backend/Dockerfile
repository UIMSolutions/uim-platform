# Build context: the uim-platform repository root (the backend depends on
# uim-platform:service via a path dependency):
#   docker build -f agentry/backend/Dockerfile -t uim-platform/agentry .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/agentry/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/agentry/backend/build/uim-agentry-platform-service /build/agentry/backend/build/uim-agentry-cli ./
COPY --from=build /build/agentry/backend/config ./config
USER appuser

EXPOSE 8117
ENV AGENTRY_HOST=0.0.0.0 \
    AGENTRY_PORT=8117 \
    AGENTRY_DATA_DIR=/data \
    AGENTRY_FRONTEND_DIR=""
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8117/api/v1/health || exit 1

CMD ["./uim-agentry-platform-service"]
