FROM dlang2/ldc-ubuntu:1.40.1 AS builder
WORKDIR /app

COPY . .
RUN dub build --build=release --config=defaultRun

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && useradd -m -u 10001 appuser \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/uim-analytics-platform-service /app/uim-analytics-platform-service

ENV ANALYTICS_HOST=0.0.0.0
ENV ANALYTICS_PORT=8112
ENV ANALYTICS_STORAGE=memory
ENV ANALYTICS_DATA_PATH=/data/analytics
ENV ANALYTICS_MONGO_URI=
ENV ANALYTICS_MONGO_DB=analytics

EXPOSE 8112

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8112/api/v1/health || exit 1

RUN mkdir -p /data/analytics && chown -R appuser:appuser /app /data/analytics
USER appuser

ENTRYPOINT ["/app/uim-analytics-platform-service"]