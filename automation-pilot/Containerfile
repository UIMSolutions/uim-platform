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
COPY --from=build /build/uim-automation-pilot-platform-service .
EXPOSE 8110
ENV AUTOMATION_PILOT_HOST=0.0.0.0
ENV AUTOMATION_PILOT_PORT=8110
CMD ["./uim-automation-pilot-platform-service"]
