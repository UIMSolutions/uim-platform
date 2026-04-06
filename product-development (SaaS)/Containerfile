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
COPY --from=build /build/uim-product-development-platform-service .
EXPOSE 8106
ENV PRODUCT_DEVELOPMENT_HOST=0.0.0.0
ENV PRODUCT_DEVELOPMENT_PORT=8106
CMD ["./uim-product-development-platform-service"]
