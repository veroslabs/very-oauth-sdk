#!/bin/bash

# VeryOauthSDK Complete Release Script
# Complete automation: Build -> Sign -> Upload to Maven Central

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_header "🚀 VeryOauthSDK Complete Release Process"
echo "============================================="

# Get version from command line
if [ -z "$1" ]; then
    print_error "Please provide a version number (e.g., 1.0.0)"
    echo "Usage: $0 <version> [--skip-upload]"
    echo "  --skip-upload: Build and sign only, skip upload to Maven Central"
    exit 1
fi

VERSION=$1
SKIP_UPLOAD=false

# Check for skip upload flag
if [ "$2" = "--skip-upload" ]; then
    SKIP_UPLOAD=true
fi

print_status "Starting complete release process for version $VERSION"
if [ "$SKIP_UPLOAD" = true ]; then
    print_warning "Upload to Maven Central will be skipped"
fi

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

print_status "Project root: $PROJECT_ROOT"
print_status "Scripts directory: $SCRIPTS_DIR"

# Check if we're in the right directory
if [ ! -f "ios/VeryOauthSDK.podspec" ] || [ ! -f "android/veryoauthsdk/build.gradle" ]; then
    print_error "Please run this script from the root of the very-sdk repository"
    exit 1
fi

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    print_error "Git working directory is not clean. Please commit or stash changes."
    exit 1
fi

# Check if tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    print_error "Tag v$VERSION already exists"
    exit 1
fi

# Step 1: Update version numbers
print_header "📝 Step 1: Update version numbers..."

# Update iOS version
sed -i '' "s/spec.version.*=.*/spec.version = \"$VERSION\"/" ios/VeryOauthSDK.podspec
print_status "Updated iOS podspec version to $VERSION"

# Update Android version
sed -i '' "s/version = .*/version = '$VERSION'/" android/veryoauthsdk/build.gradle
print_status "Updated Android build.gradle version to $VERSION"

# Update Package.swift version (if needed)
if [ -f "Package.swift" ]; then
    print_status "Package.swift version update not needed (uses git tags)"
fi

# Step 2: Run tests
print_header "🧪 Step 2: Run tests..."

# iOS tests
if command -v pod >/dev/null 2>&1; then
    print_status "Running iOS podspec validation..."
    cd ios
    pod spec lint VeryOauthSDK.podspec --allow-warnings
    cd ..
else
    print_warning "CocoaPods not found, skipping iOS validation"
fi

# Android tests
if command -v ./gradlew >/dev/null 2>&1; then
    print_status "Running Android tests..."
    ./gradlew :android:veryoauthsdk:build :android:veryoauthsdk:test
else
    print_warning "Gradle wrapper not found, skipping Android tests"
fi

# Step 3: Build and sign
print_header "🔨 Step 3: Build and sign..."

if [ -f "$SCRIPTS_DIR/build-and-sign.sh" ]; then
    print_status "Running build and sign script..."
    "$SCRIPTS_DIR/build-and-sign.sh" "$VERSION"
    print_status "✅ Build and sign completed"
else
    print_error "Build script not found: $SCRIPTS_DIR/build-and-sign.sh"
    exit 1
fi

# Step 4: Upload to Maven Central (if not skipped)
if [ "$SKIP_UPLOAD" = false ]; then
    print_header "📤 Step 4: Upload to Maven Central..."
    
    # Check environment variables
    if [ -z "$CENTRAL_USERNAME" ] || [ -z "$CENTRAL_PASSWORD" ]; then
        print_error "Maven Central credentials not set"
        echo "Please set environment variables:"
        echo "  export CENTRAL_USERNAME=your_username"
        echo "  export CENTRAL_PASSWORD=your_password"
        echo ""
        echo "Or run with credentials:"
        echo "  CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0 $VERSION"
        exit 1
    fi
    
    if [ -f "$SCRIPTS_DIR/upload-to-central.sh" ]; then
        print_status "Running upload script..."
        "$SCRIPTS_DIR/upload-to-central.sh" "$VERSION"
        print_status "✅ Upload completed"
    else
        print_error "Upload script not found: $SCRIPTS_DIR/upload-to-central.sh"
        exit 1
    fi
else
    print_warning "Skipping upload to Maven Central"
fi

# Step 5: Commit changes and create tag
print_header "📝 Step 5: Commit changes and create tag..."

print_status "Committing version changes..."
git add .
git commit -m "Release v$VERSION"

print_status "Creating and pushing tag v$VERSION..."
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

# Step 6: Display completion information
print_header "🎉 Release completed!"

print_status "Release v$VERSION is now complete!"
print_status "GitHub Actions will automatically publish to:"
print_status "- iOS: CocoaPods and Swift Package Manager"
print_status "- Android: Maven Central"

print_status "You can monitor the release at:"
print_status "- GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
print_status "- Releases: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/releases"

if [ "$SKIP_UPLOAD" = false ]; then
    print_status "📦 Android SDK has been uploaded to Maven Central"
    print_status "🌐 View: https://central.sonatype.com/"
    print_status "📦 Use: implementation 'org.very:veryoauthsdk:$VERSION'"
fi

print_status "🚀 Release v$VERSION is now in progress!"
