FROM alpine:3.20 AS builder

RUN apk add --no-cache ldc dub gcc musl-dev

WORKDIR /build
COPY . /build/uim-platform

WORKDIR /build/uim-platform/responsibility
RUN dub build --compiler=ldc2 --build=release

# --- runtime ---
FROM alpine:3.20

RUN apk add --no-cache libgcc

WORKDIR /app
COPY --from=builder /build/uim-platform/responsibility/uim-responsibility-platform-service /app/

ENV RESPONSIBILITY_HOST=0.0.0.0
ENV RESPONSIBILITY_PORT=8118

EXPOSE 8118

CMD ["/app/uim-responsibility-platform-service"]
