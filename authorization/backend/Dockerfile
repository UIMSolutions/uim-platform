# Build from the uim-platform repository root (the backend depends on ../../service):
#   docker build -f authorization/backend/Dockerfile -t uim-authorization .
FROM dlanguage/dmd:latest AS builder
WORKDIR /workspace
COPY . .
WORKDIR /workspace/authorization/backend
RUN dub build --build=release --config=defaultRun

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /workspace/authorization/backend/build/uim-authorization-platform-service /app/
COPY --from=builder /workspace/authorization/backend/config /app/config
COPY --from=builder /workspace/authorization/frontend /frontend
ENV AUTHORIZATION_HOST=0.0.0.0 \
    AUTHORIZATION_PORT=8117 \
    AUTHORIZATION_STORAGE=file \
    AUTHORIZATION_DATA_FILE=/data/authorization.json \
    AUTHORIZATION_FRONTEND_DIR=/frontend
VOLUME /data
EXPOSE 8117
CMD ["/app/uim-authorization-platform-service"]
