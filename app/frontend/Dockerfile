# --- Stage 1: Build ---
FROM registry.cdso.army.mil/cdso/containers/approved-base/node_alpine:24 AS builder

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY scripts ./scripts
RUN npm audit --json > /tmp/npm-audit.json || true
RUN node scripts/npm-audit-report.mjs /tmp/npm-audit.json

COPY . .
RUN npm run build

# --- Stage 2: Runtime ---
FROM registry.cdso.army.mil/cdso/containers/approved-base/nginx:1.31 AS runtime

COPY --from=builder --chown=nginx:nginx /app/dist /usr/share/nginx/html
COPY --chown=nginx:nginx nginx.conf /tmp/nginx.conf
COPY --chown=nginx:nginx default.conf /tmp/default.conf

USER nginx

EXPOSE 8080

CMD ["/usr/sbin/nginx", "-e", "/dev/stderr", "-g", "daemon off;", "-c", "/tmp/nginx.conf"]