FROM docker.io/dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . /build

RUN dub build --build=release --config=defaultRun --root=/build/rfc

# --------------------------------------------------------------------------
FROM docker.io/ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --system --no-create-home appuser

WORKDIR /app
COPY --from=builder /build/rfc/build/uim-rfc-platform-service /app/uim-rfc-platform-service

ENV RFC_HOST=0.0.0.0
ENV RFC_PORT=8092

EXPOSE 8092

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8092/api/v1/health || exit 1

USER appuser
ENTRYPOINT ["/app/uim-rfc-platform-service"]
