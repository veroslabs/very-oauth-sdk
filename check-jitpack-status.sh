#!/bin/bash

# Script to check JitPack publishing status
echo "=== JitPack Publishing Status Check ==="
echo ""

# Get repository info
REPO_URL="https://github.com/veroslabs/very-oauth-sdk"
VERSION="v1.0.8"

echo "Repository: $REPO_URL"
echo "Version: $VERSION"
echo ""

# Check if version tag exists locally
echo "1. Checking local Git tags..."
if git tag -l | grep -q "^$VERSION$"; then
    echo "✅ Local tag $VERSION exists"
else
    echo "❌ Local tag $VERSION not found"
    exit 1
fi

# Check if version tag exists on remote
echo ""
echo "2. Checking remote Git tags..."
if git ls-remote --tags origin | grep -q "refs/tags/$VERSION$"; then
    echo "✅ Remote tag $VERSION exists"
else
    echo "❌ Remote tag $VERSION not found"
    echo "   Run: git push origin $VERSION"
    exit 1
fi

echo ""
echo "3. JitPack URLs to check:"
echo "   Main page: https://jitpack.io/#veroslabs/very-oauth-sdk/$VERSION"
echo "   Build log: https://jitpack.io/com/github/veroslabs/very-oauth-sdk/$VERSION/build.log"
echo ""

echo "4. Manual verification steps:"
echo "   a) Visit: https://jitpack.io/#veroslabs/very-oauth-sdk/$VERSION"
echo "   b) Look for green 'Get it' button (success) or red error message"
echo "   c) Click on the version number to see detailed build logs"
echo ""

echo "5. Test integration in a project:"
echo "   Add to your build.gradle:"
echo "   implementation 'com.github.veroslabs:very-oauth-sdk:$VERSION'"
echo ""

echo "=== Check Complete ==="
echo ""
echo "If build is still failing, check the build log for specific errors."
echo "Common issues:"
echo "- Gradle configuration problems"
echo "- Missing dependencies"
echo "- JDK version compatibility"
echo "- Android SDK configuration"
