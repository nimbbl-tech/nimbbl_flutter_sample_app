#!/bin/bash

# Build script for GitHub Pages deployment
# Usage: ./scripts/build-gh-pages.sh [base-href] [web-renderer] [sdk-version]
# Example: ./scripts/build-gh-pages.sh /nimbbl_flutter_sample_app/ html 1.1.0
# 
# Arguments:
#   base-href: Base href for the app (default: /nimbbl_flutter_sample_app/)
#   web-renderer: Web renderer to use - 'html', 'canvaskit', or 'auto' (default: auto)
#   sdk-version: SDK version to use (if not provided, will prompt)

set -e

# Default base href (for project pages - update to match your repository name)
BASE_HREF=${1:-/nimbbl_flutter_sample_app/}
# WEB_RENDERER is deprecated in Flutter 3.32.5+ - kept for backward compatibility but not used
WEB_RENDERER=${2:-canvaskit}
SDK_VERSION=${3:-}

# Validate base href format
if [[ ! "$BASE_HREF" =~ ^/.*/$ ]]; then
  echo "Error: Base href must start and end with a slash (e.g., /repository-name/)"
  exit 1
fi

# Validate web renderer (deprecated but kept for backward compatibility)
# Note: Flutter 3.32.5+ automatically selects the best renderer
if [[ ! "$WEB_RENDERER" =~ ^(html|canvaskit|auto)$ ]]; then
  echo "Warning: Web renderer parameter is deprecated in Flutter 3.32.5+. Flutter will auto-select the renderer."
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "Error: Flutter is not installed or not in PATH"
  exit 1
fi

# Check if we're in the right directory (should have pubspec.yaml)
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found. Please run this script from the project root."
  exit 1
fi

echo "=========================================="
echo "Building Flutter web for GitHub Pages"
echo "=========================================="
echo "Base href: $BASE_HREF"
echo "Note: Web renderer selection is automatic in Flutter 3.32.5+"
echo ""

# Prompt for SDK version if not provided
if [ -z "$SDK_VERSION" ]; then
  echo "Enter the Nimbbl Flutter WebView SDK version (e.g., 1.1.0, 1.2.0):"
  read -r SDK_VERSION
  
  if [ -z "$SDK_VERSION" ]; then
    echo "Error: SDK version is required"
    exit 1
  fi
fi

# Validate SDK version format (basic check: should be x.y.z or ^x.y.z)
if [[ ! "$SDK_VERSION" =~ ^[\^]?[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  echo "Error: Invalid SDK version format. Expected format: x.y.z or ^x.y.z (e.g., 1.1.0 or ^1.1.0)"
  exit 1
fi

# Ensure version starts with ^ for pubspec.yaml
if [[ ! "$SDK_VERSION" =~ ^\^ ]]; then
  SDK_VERSION="^$SDK_VERSION"
fi

echo "SDK version: $SDK_VERSION"
echo ""

# Backup pubspec.yaml
PUBSPEC_BACKUP="pubspec.yaml.backup"
if [ -f "pubspec.yaml" ]; then
  echo "Creating backup of pubspec.yaml..."
  cp pubspec.yaml "$PUBSPEC_BACKUP"
fi

# Update pubspec.yaml to use published SDK version
echo "Updating pubspec.yaml with SDK version $SDK_VERSION..."

# Create a temporary file for the updated pubspec.yaml
TEMP_PUBSPEC=$(mktemp)
IN_SDK_SECTION=0
SDK_UPDATED=0

while IFS= read -r line; do
  # Check if we're entering the SDK section (local path version)
  if [[ "$line" =~ ^[[:space:]]*nimbbl_mobile_kit_flutter_webview_sdk:[[:space:]]*$ ]]; then
    # Comment out the local SDK section
    echo "  # nimbbl_mobile_kit_flutter_webview_sdk:" >> "$TEMP_PUBSPEC"
    IN_SDK_SECTION=1
  # Check if this is the path line (indented under SDK)
  elif [[ "$IN_SDK_SECTION" -eq 1 && "$line" =~ ^[[:space:]]+path: ]]; then
    # Comment out the path line
    echo "  #   path: /path/to/local/sdk" >> "$TEMP_PUBSPEC"
    IN_SDK_SECTION=0
  # Check if this is an active published version line (has version number)
  elif [[ "$line" =~ ^[[:space:]]*nimbbl_mobile_kit_flutter_webview_sdk:[[:space:]]*[\^]?[0-9] ]]; then
    # Update with new version
    echo "  nimbbl_mobile_kit_flutter_webview_sdk: $SDK_VERSION" >> "$TEMP_PUBSPEC"
    SDK_UPDATED=1
  # Check if this is the commented published version line
  elif [[ "$line" =~ ^[[:space:]]*#[[:space:]]*nimbbl_mobile_kit_flutter_webview_sdk: ]]; then
    # Uncomment and update with new version
    echo "  nimbbl_mobile_kit_flutter_webview_sdk: $SDK_VERSION" >> "$TEMP_PUBSPEC"
    SDK_UPDATED=1
  else
    # Regular line, copy as-is
    echo "$line" >> "$TEMP_PUBSPEC"
    if [[ "$IN_SDK_SECTION" -eq 1 && "$line" =~ ^[[:space:]]*$ ]]; then
      # Empty line after SDK section, reset flag
      IN_SDK_SECTION=0
    fi
  fi
done < pubspec.yaml

# Replace original file with updated version
mv "$TEMP_PUBSPEC" pubspec.yaml

# Verify the update
if [ "$SDK_UPDATED" -eq 0 ] || ! grep -q "nimbbl_mobile_kit_flutter_webview_sdk: $SDK_VERSION" pubspec.yaml; then
  echo "Error: Failed to update SDK version in pubspec.yaml. Please check manually."
  if [ -f "$PUBSPEC_BACKUP" ]; then
    echo "Restoring backup..."
    mv "$PUBSPEC_BACKUP" pubspec.yaml
  fi
  exit 1
fi

echo "✓ Updated pubspec.yaml successfully"
echo ""

# Get dependencies
echo "Installing dependencies..."
flutter pub get

# Clean previous build (optional, but recommended)
if [ -d "build/web" ]; then
  echo "Cleaning previous build..."
  rm -rf build/web
fi

# Build Flutter web
echo "Building Flutter web..."
# Note: --web-renderer flag is deprecated/removed in Flutter 3.32.5+
# Flutter now automatically selects the best renderer
flutter build web --release --base-href "$BASE_HREF"

# Copy 404.html for SPA routing
if [ -f web/404.html ]; then
  echo "Copying 404.html for SPA routing..."
  cp web/404.html build/web/404.html
else
  echo "Warning: web/404.html not found. SPA routing may not work correctly."
fi

# Preserve CNAME if it exists
if [ -f web/CNAME ]; then
  echo "Preserving CNAME file..."
  cp web/CNAME build/web/CNAME
fi

echo ""
echo "=========================================="
echo "Build complete! Ready for GitHub Pages deployment."
echo "=========================================="
echo "Build output: build/web/"
echo ""

# Ask if user wants to restore the original pubspec.yaml
if [ -f "$PUBSPEC_BACKUP" ]; then
  echo "Do you want to restore the original pubspec.yaml? (y/n)"
  read -r RESTORE
  if [[ "$RESTORE" =~ ^[Yy]$ ]]; then
    echo "Restoring original pubspec.yaml..."
    mv "$PUBSPEC_BACKUP" pubspec.yaml
    echo "✓ Restored original pubspec.yaml"
  else
    echo "Keeping updated pubspec.yaml with SDK version $SDK_VERSION"
    echo "Backup saved as: $PUBSPEC_BACKUP"
  fi
fi

echo ""
echo "Next steps:"
echo "1. Review the build output in build/web/"
echo "2. Deploy to GitHub Pages using GitHub Actions or manual upload"
echo "3. Ensure your repository settings have GitHub Pages enabled"
echo ""

