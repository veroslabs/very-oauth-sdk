#!/bin/bash

# VeryOauthSDK Release Script
# Usage: ./scripts/release.sh [version]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if version is provided
if [ -z "$1" ]; then
    print_error "Please provide a version number (e.g., 1.0.0)"
    exit 1
fi

VERSION=$1
print_status "Starting release process for version $VERSION"

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

print_status "Updating version numbers..."

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

# Run tests
print_status "Running tests..."

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

# Commit changes
print_status "Committing version changes..."
git add .
git commit -m "Release v$VERSION"

# Create and push tag
print_status "Creating and pushing tag v$VERSION..."
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

print_status "Release process completed!"
print_status "GitHub Actions will now automatically publish to:"
print_status "- iOS: CocoaPods and Swift Package Manager"
print_status "- Android: Maven Central"

print_status "You can monitor the release at:"
print_status "- GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
print_status "- Releases: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/releases"

print_status "Release v$VERSION is now in progress! 🚀"
