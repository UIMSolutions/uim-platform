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
COPY --from=build /build/uim-print-platform-service .
RUN chown appuser:appuser /app/uim-print-platform-service
USER appuser

EXPOSE 8120
ENV PRINT_HOST=0.0.0.0
ENV PRINT_PORT=8120

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8120/api/v1/health || exit 1

CMD ["./uim-print-platform-service"]
