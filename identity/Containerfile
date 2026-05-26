FROM dlang2/ldc-ubuntu:1.40.1 AS builder
WORKDIR /build
COPY . /workspace
WORKDIR /workspace
RUN dub build --build=release --config=defaultRun --root=identity

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN groupadd -r appgroup && useradd -r -g appgroup -u 1000 appuser
WORKDIR /app
COPY --from=builder /workspace/identity/uim-identity-platform-service ./uim-identity-platform-service
RUN chown appuser:appgroup uim-identity-platform-service && chmod 755 uim-identity-platform-service
RUN mkdir -p /data/identity && chown appuser:appgroup /data/identity
USER appuser
EXPOSE 8121
ENV IDENTITY_HOST=0.0.0.0
ENV IDENTITY_PORT=8121
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:8121/api/v1/health || exit 1
ENTRYPOINT ["./uim-identity-platform-service"]
