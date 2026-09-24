# Green Pages Frontend

React and TypeScript frontend for Green Pages. The application source and
container build context are under `frontend/`.

## Local development

```bash
cd frontend
npm ci
npm run dev
```

The Vite development server listens on `http://localhost:5173` and proxies API
requests to the backend at `http://localhost:8080`.

## Checks

```bash
cd frontend
npm run lint
npm run build
```

## Container build

Run from this project root:

```bash
docker build --file frontend/Dockerfile --tag greenpages-frontend:local frontend
```
