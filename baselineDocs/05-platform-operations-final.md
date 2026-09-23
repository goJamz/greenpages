# Green Pages Platform Operations

## 1. Purpose

This document captures the current deployed platform shape for Green Pages and the basic operational checks needed to verify ingress, SSO, service routing, and SPA session-expiry behavior.

It is intentionally practical. Product behavior belongs in the product definition. API shape belongs in the data model/API document. Code standards belong in engineering standards.

## 2. Current dev URL

Green Pages dev is available at:

```text
https://greenpages.dev.ai.army.mil/
```

This URL is protected by Keycloak through UDS authservice.

## 3. Current request path

The deployed request path is:

```text
browser
-> Istio tenant gateway
-> Green Pages ambient waypoint/authservice policy
-> frontend Service on port 8080
-> frontend NGINX
-> static SPA or /api proxy
-> backend Service on port 8080
```

Only the frontend is externally exposed. The backend remains internal-only.

## 4. UDS Package shape

The dev UDS Package intentionally uses a simple shape:

- one exposed service: `frontend`
- gateway: `tenant`
- host: `greenpages`
- port: `8080`
- service mesh mode: `ambient`
- SSO client: `greenpages`
- authservice selector: `app.kubernetes.io/component: frontend`

Current SSO block:

```yaml
sso:
  - name: Green Pages
    clientId: greenpages
    enableAuthserviceSelector:
      app.kubernetes.io/component: frontend
    redirectUris:
      - https://greenpages.dev.ai.army.mil/*
```

Do not add localhost redirect URIs to this cluster-managed client. Local development does not use this SSO client.

Do not set `publicClient: true` unless Green Pages later moves to app-native browser OIDC. The current design uses UDS authservice in front of the app.

## 5. Expected generated resources

After applying the UDS Package, the Package status should show:

```text
phase: Ready
ssoClients:
- greenpages
authserviceClients:
- clientId: greenpages
  selector:
    app.kubernetes.io/component: frontend
```

Expected generated resources in the `greenpages` namespace include:

```text
VirtualService:
- greenpages-tenant-greenpages-8080-frontend

AuthorizationPolicies:
- deny-all-except-waypoint-greenpages-waypoint
- greenpages-authservice
- greenpages-jwt-authz
- protect-greenpages-ingress-8080-app-kubernetes-io-component-frontend-greenpages-waypoint
- protect-greenpages-ingress-allow-inbound-traffic-between-green-pages-pods-in-the-same-namespace

RequestAuthentication:
- greenpages-jwt-authn
```

The `greenpages-authservice` and `greenpages-jwt-authz` policies should target the `greenpages-waypoint` Gateway and report `WaypointAccepted=True`.

## 6. Validation commands

Check the Package:

```bash
kubectl get package -n greenpages greenpages \
  -o jsonpath='{.status.phase}{"\n"}{.status.ssoClients}{"\n"}{.status.authserviceClients}{"\n"}'
```

Expected:

```text
Ready
["greenpages"]
[{"clientId":"greenpages","selector":{"app.kubernetes.io/component":"frontend"}}]
```

Check generated resources:

```bash
kubectl get virtualservice,authorizationpolicy,requestauthentication -n greenpages -o wide
```

Check policy details:

```bash
kubectl get authorizationpolicy -n greenpages -o yaml
kubectl get requestauthentication -n greenpages -o yaml
```

Check unauthenticated browser behavior:

```bash
curl -sI https://greenpages.dev.ai.army.mil/
```

Expected:

```text
HTTP/1.1 302 Found
location: https://sso.dev.ai.army.mil/realms/uds/protocol/openid-connect/auth?client_id=greenpages...
```

Check unauthenticated API behavior:

```bash
curl -sI https://greenpages.dev.ai.army.mil/api/health
```

Expected:

```text
HTTP/1.1 302 Found
location: https://sso.dev.ai.army.mil/realms/uds/protocol/openid-connect/auth?client_id=greenpages...
```

A `302` here is success. It means unauthenticated traffic is being redirected to Keycloak instead of reaching the app directly.

## 7. Browser validation

Open:

```text
https://greenpages.dev.ai.army.mil/
```

Expected flow:

```text
Green Pages URL
-> Keycloak/CAC login
-> redirect back to Green Pages
-> app loads
-> API-backed pages work
```

After login, validate:

- section search,
- section detail,
- person detail,
- position explorer,
- CSV exports.

## 8. Current known-good live validation

The following checks have passed in dev:

```text
Package phase: Ready
ssoClients: ["greenpages"]
authserviceClients: greenpages -> app.kubernetes.io/component=frontend

Generated auth resources:
- greenpages-authservice
- greenpages-jwt-authz
- greenpages-jwt-authn
- deny-all-except-waypoint-greenpages-waypoint
- protect-greenpages-ingress-8080-app-kubernetes-io-component-frontend-greenpages-waypoint

Unauthenticated:
- / returns 302 to Keycloak
- /api/health returns 302 to Keycloak

Browser:
- login flow completes
- app loads after login

SPA session expiry:
- background API call after authservice cookie deletion produces a clean reload
- Keycloak silent SSO bounces the user back to the same URL with state preserved
```

## 9. Session expiry behavior

When the authservice session cookie (`__Host-greenpages-authservice-session-id-cookie`) expires, the next background API call from the SPA is intercepted by authservice and answered with a 302 to Keycloak.

Expected user-visible behavior:

- the user changes a filter, runs a search, or navigates to an API-backed page,
- a brief flash of `Reloading` may appear in the frontend error boundary while the browser is already leaving the page,
- the page reloads automatically as a top-level navigation,
- if the Keycloak realm session is still valid, silent SSO completes without a login prompt,
- the user lands back on the same URL with URL-driven state preserved, fully authenticated.

If the Keycloak realm session has also expired, the reload will produce a normal Keycloak login prompt before bouncing back.

### Detection mechanism

The frontend `apiFetch` wrapper in `src/api/greenpages.ts` uses `redirect: 'manual'` so that an authservice 302 surfaces as `response.type === 'opaqueredirect'` instead of being followed as a background fetch.

On detection, the wrapper calls `window.location.reload()` and throws `Error('Reloading')`. The throw intentionally stops downstream JSON parsing while keeping the control flow simple and visible during debugging.

This avoids a CSP-driven failure mode: with default `redirect: 'follow'`, the browser would try to follow the cross-origin redirect to `sso.dev.ai.army.mil`, the SPA's `connect-src 'self'` directive would refuse it, and the user would see `TypeError: Failed to fetch`.

CSV export uses `window.location.assign()` and is a top-level navigation, so it is not subject to `connect-src` and does not flow through `apiFetch`.

### Repro

1. Open `https://greenpages.dev.ai.army.mil/` and log in.
2. Navigate to an API-backed page such as `/explorer`.
3. Open DevTools and enable **Preserve log** in the Network tab.
4. DevTools → Application → Cookies → delete `__Host-greenpages-authservice-session-id-cookie`.
5. Do not manually refresh the page.
6. Trigger any API call by changing an explorer filter, running a search, or opening a section/person detail page.
7. Expect a clean reload-and-bounce, not a stuck SPA or `Failed to fetch` error.

### Expected network sequence

When this behavior is healthy, the Network tab should show a sequence like:

```text
/api/explorer/positions?...     302   fetch / Redirect
/explorer?...                   302   document / Redirect
sso.dev.ai.army.mil/...         302   document / Redirect
/explorer?...                   200   document
/assets/...                     200   script/stylesheet
/api/explorer/positions?...     200   fetch
```

The first `/api/*` request may show as a 302 fetch redirect. The important part is that the browser then switches into a top-level document redirect flow and comes back to Green Pages with a valid authservice session.

### Diagnostic clues in the network tab

When session expiry is the cause, the failing API request shows:

- status `302`,
- response header `server: istio-envoy` (confirming the redirect originated at the waypoint, not at the frontend NGINX),
- response header `set-cookie` rotating the authservice session cookie value,
- response header `location` pointing to `sso.dev.ai.army.mil/realms/uds/protocol/openid-connect/auth?client_id=greenpages...`.

If `server` is not `istio-envoy`, or if there is no `location` header, the failure is something else and the SPA reload behavior will not help.

A bad sign is a console error like:

```text
Connecting to 'https://sso.dev.ai.army.mil/...' violates the following Content Security Policy directive: "connect-src 'self'".
```

Do not loosen CSP to allow this background fetch. The correct behavior is a top-level reload/redirect, not a background browser connection to Keycloak.

## 10. Troubleshooting

### Package is not ready

Run:

```bash
kubectl get package -n greenpages greenpages -o yaml
```

Check:

- `status.phase`
- `status.conditions`
- `status.retryAttempt`
- `status.ssoClients`
- `status.authserviceClients`

### Auth resources are missing

Run:

```bash
kubectl get authorizationpolicy,requestauthentication -n greenpages -o wide
```

If `greenpages-authservice`, `greenpages-jwt-authz`, or `greenpages-jwt-authn` are missing, check the UDS Package `sso` block and the `enableAuthserviceSelector`.

The selector must match the frontend pod labels:

```yaml
app.kubernetes.io/component: frontend
```

### Auth policy binds to ztunnel instead of waypoint

For ambient mode, the SSO auth policies should target the waypoint Gateway.

Healthy resources should show:

```text
targetRef:
  group: gateway.networking.k8s.io
  kind: Gateway
  name: greenpages-waypoint
```

and:

```text
type: WaypointAccepted
status: "True"
```

If the policy reports that ztunnel does not support the `CUSTOM` action, the authservice policy is not attached in the desired ambient/waypoint shape.

### Browser login fails with redirect URI error

Check the Green Pages client redirect URI in the Package:

```yaml
redirectUris:
  - https://greenpages.dev.ai.army.mil/*
```

Do not broaden redirect URIs unless there is a real need. Redirect URIs should remain as specific as practical.

### App loads but API fails after login

Check that frontend NGINX still proxies `/api/` to the backend service.

Also check backend readiness internally:

```bash
kubectl exec -n greenpages deploy/frontend -- wget -qO- http://backend:8080/api/health
```

If that fails, troubleshoot service discovery, backend pod health, or intra-namespace network policy.

### SPA shows `Failed to fetch` or CSP errors after session expiry

If DevTools shows an error like:

```text
Connecting to 'https://sso.dev.ai.army.mil/...' violates the following Content Security Policy directive: "connect-src 'self'".
```

or the UI shows `Failed to fetch` after deleting the authservice cookie, the SPA is not catching the authservice redirect correctly.

Check first:

- the failing request really is a 302 from `istio-envoy` (per the diagnostic clues in §9),
- the frontend build is current and includes the `apiFetch` wrapper in `src/api/greenpages.ts`,
- all API call sites in the frontend route through `apiFetch`, not raw `fetch()`,
- `apiFetch` uses `redirect: 'manual'`,
- `apiFetch` reloads when `httpResponse.type === 'opaqueredirect'`.

Do not fix this by adding Keycloak to `connect-src`.

Do not treat generic `TypeError: Failed to fetch` as session expiry. If the failing request is not a 302 from authservice, the failure is a real network, routing, or backend error and should remain visible as a request failure.

### Frontend logs show NGINX startup error-log warning

If logs show:

```text
nginx: [alert] could not open error log file: open() "/var/log/nginx/error.log" failed (13: Permission denied)
```

Use the NGINX `-e /dev/stderr` startup option in the frontend Dockerfile command:

```dockerfile
CMD ["/usr/sbin/nginx", "-e", "/dev/stderr", "-g", "daemon off;", "-c", "/tmp/nginx.conf"]
```

This points NGINX error logging to container stderr before full config parsing completes and preserves the non-root container posture.

## 11. Current non-goals

Do not add these yet:

- React OIDC libraries
- frontend token storage
- app-native login/logout routes
- RBAC
- role-aware UI
- backend JWT claim parsing
- direct external backend route

Those are future decisions. The current MVP only needs authenticated access to the app.

## 12. Operational takeaway

The current platform shape is intentionally simple:

```text
one external frontend route
+ UDS authservice gate
+ internal backend service
+ frontend NGINX /api proxy
+ SPA-side session-expiry reload
```

Keep that shape until a real product or operational need proves otherwise.
