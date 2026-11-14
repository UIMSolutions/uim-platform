# Build context: the uim-platform repository root (the backend depends on
# uim-platform:service via a path dependency):
#   docker build -f service-manager/backend/Dockerfile -t uim-platform/service-manager .
FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY . .
WORKDIR /build/service-manager/backend
RUN dub build --build=release --config=defaultRun --compiler=ldc2 \
 && dub build --build=release --config=cli --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser && mkdir -p /data && chown appuser:appuser /data
WORKDIR /app
COPY --from=build /build/service-manager/backend/build/uim-service-manager-platform-service /build/service-manager/backend/build/uim-service-manager-cli ./
COPY --from=build /build/service-manager/backend/config ./config
COPY --from=build /build/service-manager/frontend ./frontend
USER appuser

EXPOSE 8113
ENV SERVICE_MANAGER_HOST=0.0.0.0 \
    SERVICE_MANAGER_PORT=8113 \
    SERVICE_MANAGER_STORAGE=file \
    SERVICE_MANAGER_DATA_FILE=/data/service-manager.json \
    SERVICE_MANAGER_FRONTEND_DIR=/app/frontend
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8113/health || exit 1

CMD ["./uim-service-manager-platform-service"]
