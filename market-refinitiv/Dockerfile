# ---- Stage 1: Build --------------------------------------------------------
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY . .
RUN dub build --build=release --config=defaultRun

# ---- Stage 2: Runtime -------------------------------------------------------
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY --from=builder /build/build/uim-market-refinitiv-platform-service .

ENV MARKET_RATES_HOST=0.0.0.0
ENV MARKET_RATES_PORT=8097

EXPOSE 8097

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8097/api/v1/health || exit 1

USER appuser
ENTRYPOINT ["./uim-market-refinitiv-platform-service"]
