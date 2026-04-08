FROM golang:1.26.2-bookworm AS builder

WORKDIR /app

COPY go.mod ./
COPY cmd ./cmd

RUN go build -o /app/server ./cmd/server

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/server /app/server

EXPOSE 8080

CMD ["/app/server"]