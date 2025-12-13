#!/usr/bin/env bash
set -euo pipefail

#######################################################################
# init-repo.sh
# Helper script to initialize the test-app repository
# Run this from the test-app directory
#######################################################################

echo "=========================================="
echo "Test App Repository Initialization"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "Dockerfile" ] || [ ! -d ".github/workflows" ]; then
  echo "❌ Error: Please run this script from the test-app directory"
  echo "   cd infra/k3s-tooling/test-app"
  echo "   ./init-repo.sh"
  exit 1
fi

# Get repository URL
read -p "Enter your GitHub repository URL (e.g., https://github.com/username/test-app.git): " REPO_URL

if [ -z "$REPO_URL" ]; then
  echo "❌ Repository URL is required"
  exit 1
fi

echo ""
echo "Initializing git repository..."

# Initialize git if not already
if [ ! -d ".git" ]; then
  git init
  echo "✅ Git repository initialized"
else
  echo "✅ Git repository already exists"
fi

# Check if remote exists
if git remote get-url origin >/dev/null 2>&1; then
  echo "⚠️  Remote 'origin' already exists"
  read -p "Update it? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git remote set-url origin "$REPO_URL"
    echo "✅ Remote updated"
  fi
else
  git remote add origin "$REPO_URL"
  echo "✅ Remote added"
fi

echo ""
echo "Adding files..."
git add .

echo ""
read -p "Commit and push to main branch? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git commit -m "Initial commit: Test app for CI/CD pipeline"
  
  # Set main branch
  git branch -M main 2>/dev/null || true
  
  # Push
  echo ""
  echo "Pushing to GitHub..."
  git push -u origin main
  
  echo ""
  echo "=========================================="
  echo "✅ Repository initialized and pushed!"
  echo "=========================================="
  echo ""
  echo "Next steps:"
  echo "1. Add Harbor secrets to GitHub repository"
  echo "2. Configure runner deployment"
  echo "3. Test CI workflow"
  echo ""
  echo "See SETUP.md for detailed instructions"
else
  echo ""
  echo "Files staged. Run manually:"
  echo "  git commit -m 'Initial commit'"
  echo "  git push -u origin main"
fi

