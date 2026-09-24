# --- Stage 1: Build ---
FROM registry.cdso.army.mil/cdso/containers/approved-base/go_alpine:1.26 AS builder

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /app

COPY ecma.pem /usr/local/share/ca-certificates/ecma.crt
RUN apk add --no-cache ca-certificates jq && update-ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY cmd ./cmd
COPY internal ./internal
COPY scripts ./scripts

RUN scripts/govulncheck-report.sh

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /app/server ./cmd/server

# --- Stage 2: Runtime ---
FROM registry.cdso.army.mil/cdso/containers/approved-base/distroless:alpine-3.22 AS runtime

WORKDIR /app

COPY --from=builder --chown=10000:65534 /app/server /app/server

USER 10000:65534

EXPOSE 8080

CMD ["/app/server"]