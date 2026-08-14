FROM alpine:3.20 AS builder

RUN apk add --no-cache ldc dub gcc musl-dev

WORKDIR /build
COPY . /build/uim-platform

WORKDIR /build/uim-platform/architecture
RUN dub build --compiler=ldc2 --build=release --config=defaultRun

FROM alpine:3.20

RUN apk add --no-cache libgcc

WORKDIR /app
COPY --from=builder /build/uim-platform/architecture/uim-architecture-platform-service /app/

ENV ARCHITECTURE_HOST=0.0.0.0
ENV ARCHITECTURE_PORT=8122

EXPOSE 8122

CMD ["/app/uim-architecture-platform-service"]
