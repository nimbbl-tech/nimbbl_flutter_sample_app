# GitHub Pages Deployment Guide

This document provides a comprehensive guide for deploying the Flutter web sample app to GitHub Pages.

## Overview

GitHub Pages is a free hosting service for static websites. It's perfect for Flutter web applications and provides automatic HTTPS, custom domains, and easy deployment via GitHub Actions.

## Prerequisites

- GitHub repository
- GitHub Actions enabled
- Flutter SDK installed (for local testing)

## Deployment Options

### Option 1: Deploy to Repository Root (User/Organization Pages)

If deploying to `https://username.github.io` or `https://organization.github.io`:

**Base href**: `/` (root)

### Option 2: Deploy to Project Pages

If deploying to `https://username.github.io/repository-name`:

**Base href**: `/repository-name/`

## Step 1: Create GitHub Actions Workflow

Create `.github/workflows/deploy-gh-pages.yml` at the repository root:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - master  # or main, depending on your default branch
  workflow_dispatch:  # Allow manual triggering

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Build web
      run: |
        # For project pages: use /repository-name/
        # For user/org pages: use /
        flutter build web --release --web-renderer canvaskit --base-href /nimbbl_flutter_sample_app/
    
    - name: Copy 404.html for SPA routing
      run: |
        if [ -f web/404.html ]; then
          cp web/404.html build/web/404.html
        fi
    
    - name: Preserve CNAME if exists
      run: |
        if [ -f web/CNAME ]; then
          cp web/CNAME build/web/CNAME
        fi
    
    - name: Setup Pages
      uses: actions/configure-pages@v4
    
    - name: Upload artifact
      uses: actions/upload-pages-artifact@v3
      with:
        path: build/web
    
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v4
```

## Step 2: Configure Base Href

The `--base-href` flag is critical for GitHub Pages deployment:

**For Project Pages** (`https://username.github.io/repository-name/`):
```bash
flutter build web --release --base-href /repository-name/
```

**For User/Organization Pages** (`https://username.github.io/`):
```bash
flutter build web --release --base-href /
```

## Step 3: Handle SPA Routing (404.html)

GitHub Pages doesn't support server-side routing for SPAs. The `web/404.html` file handles client-side routing by redirecting to `index.html`.

The file is already included in the repository at `web/404.html` and will be automatically copied to `build/web/` during the build process.

## Step 4: Build Script

Use the provided build script for local testing:

**Location**: `scripts/build-gh-pages.sh`

```bash
# Make it executable
chmod +x scripts/build-gh-pages.sh

# Run the script
./scripts/build-gh-pages.sh [base-href] [web-renderer] [sdk-version]

# Example for project pages:
./scripts/build-gh-pages.sh /nimbbl_flutter_sample_app/ canvaskit 1.1.1-alpha.2
```

The script will:
1. Prompt for SDK version (if not provided)
2. Update `pubspec.yaml` to use the published SDK version
3. Build the Flutter web app
4. Copy `404.html` for SPA routing
5. Preserve `CNAME` if it exists

## Step 5: Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select:
   - **Source**: `GitHub Actions`
4. Save the settings

## Step 6: Deploy

1. **Automatic**: Push to the `master` (or `main`) branch
2. **Manual**: Go to **Actions** tab → Select workflow → **Run workflow**

## Step 7: Verify Deployment

After deployment completes:
1. Go to **Actions** tab → Check the latest workflow run
2. Once successful, visit: `https://username.github.io/repository-name/`

## Custom Domain (Optional)

To use a custom domain:

1. Add `CNAME` file to `web/`:
   ```
   yourdomain.com
   ```

2. Update GitHub Pages settings:
   - Go to **Settings** → **Pages**
   - Enter your custom domain
   - GitHub will provide DNS records to configure

3. The workflow automatically preserves `CNAME` during build

## Environment-Specific Builds

For different environments (staging, production), use GitHub Actions secrets:

```yaml
- name: Build web
  run: |
    flutter build web --release \
      --web-renderer canvaskit \
      --base-href /nimbbl_flutter_sample_app/ \
      --dart-define=API_HOST=${{ secrets.API_HOST }} \
      --dart-define=CHECKOUT_ENDPOINT=${{ secrets.CHECKOUT_ENDPOINT }}
```

## Troubleshooting

### Issue: 404 on Routes

**Solution**: Ensure `404.html` is copied to `build/web/` and contains the SPA redirect script.

### Issue: Assets Not Loading

**Solution**: Check `--base-href` matches your repository path. For project pages, it must be `/repository-name/` (with trailing slash).

### Issue: Blank Page

**Solution**: 
1. Check browser console for errors
2. Verify `base href` in `index.html` matches build command
3. Ensure all assets are in `build/web/`

### Issue: Build Fails

**Solution**:
1. Check Flutter version compatibility
2. Verify all dependencies are in `pubspec.yaml`
3. Review GitHub Actions logs

## Advantages of GitHub Pages

- ✅ **Free hosting** for public repositories
- ✅ **Automatic HTTPS** with Let's Encrypt
- ✅ **Custom domains** support
- ✅ **CDN** via GitHub's infrastructure
- ✅ **Easy deployment** via GitHub Actions
- ✅ **Version control** integration
- ✅ **No server maintenance**

## Limitations

- ⚠️ **Static files only** (no server-side processing)
- ⚠️ **Build size limits** (recommended < 1GB)
- ⚠️ **No server-side routing** (requires 404.html workaround)
- ⚠️ **Public repositories only** for free tier

## References

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
