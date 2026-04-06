FROM alpine:3.20 AS base
RUN apk add --no-cache ldc dub gcc musl-dev

FROM base AS build
WORKDIR /build
COPY dub.sdl dub.selections.json ./
COPY source/ source/
RUN dub build --compiler=ldc2 -b release

FROM alpine:3.20
RUN apk add --no-cache libgcc
WORKDIR /app
COPY --from=build /build/uim-asset-strategy-performance-platform-service .
EXPOSE 8105
ENV ASSET_STRATEGY_PERFORMANCE_HOST=0.0.0.0
ENV ASSET_STRATEGY_PERFORMANCE_PORT=8105
CMD ["./uim-asset-strategy-performance-platform-service"]
