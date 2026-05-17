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
COPY --from=build /build/uim-usage-data-platform-service .
RUN chown appuser:appuser /app/uim-usage-data-platform-service
USER appuser

EXPOSE 10004
ENV USAGE_DATA_HOST=0.0.0.0
ENV USAGE_DATA_PORT=10004

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:10004/api/v1/health || exit 1

CMD ["./uim-usage-data-platform-service"]
