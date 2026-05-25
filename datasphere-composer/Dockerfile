# Stage 1: Build
FROM ldc2:latest AS builder

WORKDIR /build
COPY . .
RUN dub build --build=release --config=default

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /build/uim-datasphere-composer-platform-service /app/uim-datasphere-composer-platform-service

ENV DATASPHERE_COMPOSER_HOST=0.0.0.0
ENV DATASPHERE_COMPOSER_PORT=8099

EXPOSE 8099

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -sf http://localhost:8099/api/v1/health || exit 1

ENTRYPOINT ["/app/uim-datasphere-composer-platform-service"]
