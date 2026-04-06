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
COPY --from=build /build/uim-network-asset-collaboration-platform-service .
EXPOSE 8104
ENV NETWORK_ASSET_COLLABORATION_HOST=0.0.0.0
ENV NETWORK_ASSET_COLLABORATION_PORT=8104
CMD ["./uim-network-asset-collaboration-platform-service"]
