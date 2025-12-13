# Test App

A simple test application for CI/CD pipeline testing.

## What This App Does

- Simple Python HTTP server
- Health check endpoint: `/health`
- Main page: `/`
- Runs on port 8080

## Structure

```
test-app/
├── Dockerfile              # Container image definition
├── .dockerignore           # Files to exclude from build
├── .github/
│   └── workflows/
│       └── ci-main.yml     # CI workflow (build & push)
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── README.md
```

## CI/CD Flow

1. **CI (GitHub Actions):**
   - Builds Docker image
   - Pushes to Harbor: `harbor.dev.synthlane.com/infra/test-app:{SHA}`
   - Tags: `{SHA}`, `{branch}`, `latest`

2. **CD (Argo CD - Later):**
   - Monitors Git repository
   - Syncs K8s manifests to cluster
   - Deploys updated image

## Local Development

```bash
# Build image
docker build -t test-app:local .

# Run container
docker run -p 8080:8080 test-app:local

# Test
curl http://localhost:8080
curl http://localhost:8080/health
```

## Kubernetes Deployment

```bash
# Apply manifests
kubectl apply -f k8s/

# Check status
kubectl -n test-app get all

# Access via ingress
curl https://test-app.dev.synthlane.com
```

## CI Workflow

The CI workflow (`ci-main.yml`) is configured to:
- Use self-hosted runners
- Build and push to Harbor
- Tag images with SHA and branch name

**Required GitHub Secrets:**
- `HARBOR_REGISTRY`
- `HARBOR_PROJECT`
- `HARBOR_USERNAME`
- `HARBOR_PASSWORD`

## Next Steps

1. Push this to a GitHub repository
2. Add Harbor secrets to GitHub
3. Configure runner deployment
4. Test CI workflow
5. Create Argo CD application (for CD)

