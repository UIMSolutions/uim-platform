# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . .
RUN dub build --build=release --config=default

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    ca-certificates \
    curl \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app
COPY --from=builder /build/build/uim-snowflake-platform-service /app/uim-snowflake-platform-service

RUN chown appuser:appgroup /app/uim-snowflake-platform-service
USER appuser

ENV SNOWFLAKE_HOST=0.0.0.0
ENV SNOWFLAKE_PORT=8100

EXPOSE 8100

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -sf http://localhost:8100/api/v1/health || exit 1

ENTRYPOINT ["/app/uim-snowflake-platform-service"]
