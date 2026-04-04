FROM dlang2/ldc-ubuntu:1.40.1 AS builder

RUN apt-get update && apt-get install -y libssl-dev zlib1g-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY dub.sdl dub.selections.json ./
COPY source/ source/
COPY ../service/ ../service/

RUN dub build --build=release

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 zlib1g ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/build/uim-ai-launchpad-platform-service .

ENV AILP_HOST=0.0.0.0
ENV AILP_PORT=8097

EXPOSE 8097

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8097/api/v1/health || exit 1

ENTRYPOINT ["./uim-ai-launchpad-platform-service"]
