FROM dlang2/ldc-ubuntu:1.40.1 AS build
WORKDIR /build
COPY dub.sdl dub.selections.json ./
COPY source/ source/
RUN dub build --build=release --config=defaultRun --compiler=ldc2

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false appuser
WORKDIR /app
COPY --from=build /build/uim-agentry-platform-service .
RUN chown appuser:appuser /app/uim-agentry-platform-service
USER appuser

EXPOSE 8117
ENV AGENTRY_HOST=0.0.0.0
ENV AGENTRY_PORT=8117

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8117/api/v1/health || exit 1

CMD ["./uim-agentry-platform-service"]
