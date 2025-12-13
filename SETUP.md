# Test App Setup Guide

This guide will help you set up the test-app repository and configure CI/CD.

## 📁 What's Included

- ✅ Simple Python web server (Dockerfile)
- ✅ CI workflow (`.github/workflows/ci-main.yml`)
- ✅ Kubernetes manifests (`k8s/`)
- ✅ README and documentation

## 🚀 Setup Steps

### Step 1: Create GitHub Repository

1. Go to GitHub and create a new repository:
   - Name: `test-app`
   - Visibility: Private or Public (your choice)
   - **Don't** initialize with README (we already have one)

2. Note your repository path:
   - Format: `YOUR_USERNAME/test-app` or `YOUR_ORG/test-app`
   - Example: `synthlane/test-app`

### Step 2: Push Test App to GitHub

**On your local machine (where you have this code):**

```bash
cd test-app

# Initialize git (if not already)
git init

# Add remote (replace with your actual repo)
git remote add origin https://github.com/YOUR_USERNAME/test-app.git

# Add all files
git add .

# Commit
git commit -m "Initial commit: Test app for CI/CD"

# Push to main branch
git branch -M main
git push -u origin main
```

### Step 3: Add Harbor Secrets to GitHub

In your GitHub repository (`test-app`):

1. Go to: **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add these 4 secrets:

| Secret Name | Value | Example |
|------------|-------|---------|
| `HARBOR_REGISTRY` | Harbor domain | `harbor.dev.synthlane.com` |
| `HARBOR_PROJECT` | Harbor project | `infra` |
| `HARBOR_USERNAME` | Harbor username | `admin` |
| `HARBOR_PASSWORD` | Harbor password | (your Harbor password) |

### Step 4: Configure Runner Deployment

**On your K3s server:**

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Edit runner deployment
nano ~/github-runners/test-app-runnerdeployment.yaml
```

Change this line:
```yaml
repository: YOUR_ORG/YOUR_REPO
```

To your actual repository (from Step 1):
```yaml
repository: YOUR_USERNAME/test-app
# Example: repository: synthlane/test-app
```

Save and apply:
```bash
kubectl apply -f ~/github-runners/test-app-runnerdeployment.yaml

# Verify runner was created
kubectl -n actions get runners
kubectl -n actions get pods | grep test-app
```

### Step 5: Verify Runner in GitHub

1. Go to your repository: `https://github.com/YOUR_USERNAME/test-app`
2. Navigate to: **Settings** → **Actions** → **Runners** → **Self-hosted**
3. You should see a runner with status: **Idle** or **Online**
4. Labels should include: `self-hosted`, `linux`, `k3s`, `ci`, `test-app`

### Step 6: Test CI Workflow

1. Go to your repository: `https://github.com/YOUR_USERNAME/test-app`
2. Click **Actions** tab
3. Click **"Build & Push to Harbor (NO deploy yet)"**
4. Click **"Run workflow"**
5. Keep branch: `main`
6. Click **"Run workflow"** button

**Expected result:**
- ✅ Workflow runs successfully
- ✅ Uses self-hosted runner
- ✅ Builds Docker image
- ✅ Pushes to Harbor

**Verify in Harbor:**
- Go to: `https://harbor.dev.synthlane.com`
- Navigate to your project (`infra`)
- You should see `test-app` image with tags

### Step 7: (Optional) Create Harbor Image Pull Secret

If your Harbor project is private, create a pull secret:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

kubectl create secret docker-registry harbor-creds \
  --docker-server=harbor.dev.synthlane.com \
  --docker-username=admin \
  --docker-password='YOUR_HARBOR_PASSWORD' \
  -n test-app \
  --dry-run=client -o yaml | kubectl apply -f -
```

## ✅ Verification Checklist

- [ ] GitHub repository created
- [ ] Test app code pushed to GitHub
- [ ] Harbor secrets added to GitHub
- [ ] Runner deployment configured with correct repository
- [ ] Runner appears in GitHub (Settings → Actions → Runners)
- [ ] CI workflow runs successfully
- [ ] Image appears in Harbor

## 🎯 Next Steps (For Full CI/CD)

When you're ready to add CD (automatic deployment):

1. **Update CI workflow** to update image tag in `k8s/deployment.yaml`
2. **Create Argo CD Application** pointing to `k8s/` folder
3. **Test full CI/CD flow**

## 📝 Notes

- The CI workflow uses `workflow_dispatch` (manual trigger) for safety
- Images are tagged with: `{SHA}` and `{branch}`
- K8s manifests are ready but not deployed yet (waiting for Argo CD)
- The app is a simple Python HTTP server for testing

## 🔧 Troubleshooting

**Runner not appearing in GitHub:**
```bash
kubectl -n actions get runners
kubectl -n actions logs -l app.kubernetes.io/name=actions-runner-controller
```

**Workflow stuck in "Queued":**
- Check if runner is online in GitHub
- Verify runner labels match workflow `runs-on` labels

**Build fails:**
- Check Harbor secrets are correct
- Verify Harbor registry is accessible
- Check runner pod logs

