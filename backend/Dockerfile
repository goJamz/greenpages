FROM golang:1.26.2-bookworm AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
COPY internal ./internal

RUN go build -o /app/server ./cmd/server

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/server /app/server

EXPOSE 8080

CMD ["/app/server"]