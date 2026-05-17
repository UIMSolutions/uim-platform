FROM dlang2/ldc-ubuntu:1.40.1 AS build

WORKDIR /build
COPY dub.sdl dub.selections.json ./
COPY source/ source/

RUN dub build --build=release --config=defaultRun

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY --from=build /build/uim-sap-event-mesh-platform-service .

ENV SAP_EVENT_MESH_HOST=0.0.0.0
ENV SAP_EVENT_MESH_PORT=8109

EXPOSE 8109

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8109/api/v1/health || exit 1

USER appuser
CMD ["./uim-sap-event-mesh-platform-service"]
