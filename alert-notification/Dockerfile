FROM docker.io/dlang2/ldc-ubuntu:1.40.1 AS builder

WORKDIR /build
COPY alert-notification/ ./alert-notification/
COPY service/             ./service/
COPY dub.sdl              ./dub.sdl
COPY dub.selections.json  ./dub.selections.json
WORKDIR /build/alert-notification
RUN dub build --build=release --config=defaultRun

FROM docker.io/ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends libssl3 curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appgroup && useradd -r -g appgroup appuser
COPY --from=builder /build/alert-notification/build/uim-alert-notification-platform-service /app/uim-alert-notification-platform-service
RUN chown appuser:appgroup /app/uim-alert-notification-platform-service && chmod 550 /app/uim-alert-notification-platform-service
USER appuser
WORKDIR /app
EXPOSE 8095
HEALTHCHECK --interval=30s --timeout=5s CMD curl -sf http://localhost:8095/api/v1/health || exit 1
ENTRYPOINT ["/app/uim-alert-notification-platform-service"]
