FROM dlang2/ldc-ubuntu:1.40.1 AS builder
WORKDIR /build
COPY . .
RUN dub build --build=release --config=defaultRun

FROM ubuntu:24.04 AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libcurl4 \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -r -s /bin/false appuser
WORKDIR /app
COPY --from=builder /build/uim-redis-platform-service .
RUN chown appuser:appuser /app/uim-redis-platform-service
USER appuser
ENV REDIS_HOST=0.0.0.0
ENV REDIS_PORT=8130
EXPOSE 8130
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8130/health || exit 1
CMD ["/app/uim-redis-platform-service"]
