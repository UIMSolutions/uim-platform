# Stage 1: Build
FROM dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build

COPY . /build/uim-platform
WORKDIR /build/uim-platform

RUN dub build --root=ui-flexibility --build=release --config=defaultRun

# Stage 2: Runtime
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

COPY --from=builder /build/uim-platform/ui-flexibility/uim-ui-flexibility-platform-service /app/

RUN chown -R appuser:appgroup /app

USER appuser

ENV UIFLEXIBILITY_HOST=0.0.0.0
ENV UIFLEXIBILITY_PORT=8098
ENV UIFLEXIBILITY_STORAGE=memory
ENV UIFLEXIBILITY_DATA_PATH=/data/ui-flexibility
ENV UIFLEXIBILITY_MONGO_URI=

EXPOSE 8098

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:8098/api/v1/health || exit 1

ENTRYPOINT ["/app/uim-ui-flexibility-platform-service"]
