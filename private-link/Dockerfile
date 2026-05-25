# syntax=docker/dockerfile:1
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . /build/private-link
WORKDIR /build/private-link
RUN dub build --build=release --config=defaultRun

# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY --from=builder /build/private-link/build/uim-private-link-platform-service .

ENV PRIVLINK_HOST=0.0.0.0
ENV PRIVLINK_PORT=8087

EXPOSE 8087

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fs http://localhost:8087/api/v1/health || exit 1

USER appuser
ENTRYPOINT ["/app/uim-private-link-platform-service"]
