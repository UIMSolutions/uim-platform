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
COPY --from=build /build/uim-masterdata-governance-platform-service .
EXPOSE 8108
ENV MASTERDATA_GOVERNANCE_HOST=0.0.0.0
ENV MASTERDATA_GOVERNANCE_PORT=8108
CMD ["./uim-masterdata-governance-platform-service"]
