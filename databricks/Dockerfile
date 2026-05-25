# Stage 1 — build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder
WORKDIR /build
COPY . .
RUN dub build --root=databricks --config=defaultRun --compiler=ldc2 --build=release

# Stage 2 — runtime
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libssl3 libcurl4 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -r -s /bin/false appuser

COPY --from=builder /build/databricks/uim-databricks-platform-service /usr/local/bin/uim-databricks-platform-service
RUN chmod 550 /usr/local/bin/uim-databricks-platform-service && \
    chown appuser:appuser /usr/local/bin/uim-databricks-platform-service

USER appuser
EXPOSE 8104
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8104/api/v1/health || exit 1
ENTRYPOINT ["/usr/local/bin/uim-databricks-platform-service"]
