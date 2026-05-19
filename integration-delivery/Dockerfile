# syntax=docker/dockerfile:1
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . .
RUN dub build --build=release --config=defaultRun

FROM ubuntu:24.04 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app
COPY --from=builder /build/uim-integration-delivery-platform-service .

ENV INTEGRATION_DELIVERY_HOST=0.0.0.0
ENV INTEGRATION_DELIVERY_PORT=8120

EXPOSE 8120

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8120/health || exit 1

USER appuser
ENTRYPOINT ["/app/uim-integration-delivery-platform-service"]
