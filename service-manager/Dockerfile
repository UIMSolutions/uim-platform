FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . /build/

RUN dub build --build=release --config=defaultRun

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser

WORKDIR /app
COPY --from=builder /build/uim-service-manager-platform-service /app/

ENV SERVICE_MANAGER_HOST=0.0.0.0
ENV SERVICE_MANAGER_PORT=8113

EXPOSE 8113

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8113/health || exit 1

USER appuser

ENTRYPOINT ["/app/uim-service-manager-platform-service"]
