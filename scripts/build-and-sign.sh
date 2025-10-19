#!/bin/bash

# VeryOauthSDK Build and Sign Script
# Builds Android SDK, generates GPG signatures, and prepares for Maven Central upload

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

# Get version from command line or use default
VERSION=${1:-"1.0.2"}
print_header "🚀 VeryOauthSDK Build and Sign Process"
echo "============================================="
print_status "Building version: $VERSION"

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"

print_status "Project root: $PROJECT_ROOT"
print_status "Android directory: $ANDROID_DIR"
print_status "Upload directory: $UPLOAD_DIR"

# Check required tools
print_header "🔍 Checking required tools..."

# Check Gradle
if [ ! -f "$ANDROID_DIR/gradlew" ]; then
    print_error "Gradle Wrapper not found"
    exit 1
fi
print_status "✅ Gradle Wrapper found"

# Check GPG
if ! command -v gpg &> /dev/null; then
    print_error "GPG not installed"
    echo "Please install GPG: brew install gnupg"
    exit 1
fi
print_status "✅ GPG installed"

# Check GPG key
if ! gpg --list-secret-keys --keyid-format LONG | grep -q "sec"; then
    print_error "No GPG key found"
    echo "Please generate GPG key first: gpg --full-generate-key"
    exit 1
fi
print_status "✅ GPG key found"

# Get GPG key information
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)
print_status "🔑 GPG Key ID: $GPG_KEY_ID"

# Step 1: Clean and build
print_header "🧹 Step 1: Clean and build..."
cd "$ANDROID_DIR"

print_status "Cleaning project..."
./gradlew clean

print_status "Building project..."
./gradlew :veryoauthsdk:build

print_status "Generating release version..."
./gradlew :veryoauthsdk:assembleRelease

print_status "Generating sources and documentation..."
./gradlew :veryoauthsdk:sourcesJar :veryoauthsdk:javadocJar

print_status "Generating POM file..."
./gradlew :veryoauthsdk:generatePomFileForReleasePublication

print_status "✅ Build completed"

# Step 2: Prepare upload directory
print_header "📦 Step 2: Prepare upload directory..."

# Clean and create upload directory
rm -rf "$UPLOAD_DIR"
mkdir -p "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION"

# Copy files to correct location
print_status "Copying AAR file..."
cp "$ANDROID_DIR/veryoauthsdk/build/outputs/aar/veryoauthsdk-release.aar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION/veryoauthsdk-$VERSION.aar"

print_status "Copying POM file..."
cp "$ANDROID_DIR/veryoauthsdk/build/publications/release/pom-default.xml" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION/veryoauthsdk-$VERSION.pom"

print_status "Copying sources JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-sources.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION/veryoauthsdk-$VERSION-sources.jar"

print_status "Copying documentation JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-javadoc.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION/veryoauthsdk-$VERSION-javadoc.jar"

print_status "✅ File copying completed"

# Step 3: Generate checksums
print_header "🔐 Step 3: Generate checksums..."
cd "$UPLOAD_DIR/org/very/veryoauthsdk/$VERSION"

print_status "Generating MD5 checksums..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        md5sum "$file" | cut -d' ' -f1 > "$file.md5"
        print_status "  ✅ $file.md5"
    fi
done

print_status "Generating SHA1 checksums..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        sha1sum "$file" | cut -d' ' -f1 > "$file.sha1"
        print_status "  ✅ $file.sha1"
    fi
done

print_status "✅ Checksum generation completed"

# Step 4: Generate GPG signatures
print_header "🔑 Step 4: Generate GPG signatures..."

print_status "Generating GPG signatures..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        print_status "  Signing: $file"
        gpg --armor --detach-sign "$file"
        if [ -f "$file.asc" ]; then
            print_status "  ✅ $file.asc"
        else
            print_error "  ❌ $file.asc generation failed"
        fi
    fi
done

print_status "✅ GPG signature generation completed"

# Step 5: Create ZIP package
print_header "📦 Step 5: Create ZIP package..."
cd "$UPLOAD_DIR"

print_status "Creating ZIP package..."
rm -f veryoauthsdk-$VERSION.zip
zip -r veryoauthsdk-$VERSION.zip org/

ZIP_SIZE=$(du -h veryoauthsdk-$VERSION.zip | cut -f1)
print_status "✅ ZIP package created: veryoauthsdk-$VERSION.zip ($ZIP_SIZE)"

# Step 6: Display file list
print_header "📋 Step 6: File list..."
print_status "Upload directory contents:"
find org/ -type f | sort

print_status "📊 File statistics:"
echo "AAR files: $(find org/ -name "*.aar" | wc -l)"
echo "JAR files: $(find org/ -name "*.jar" | wc -l)"
echo "POM files: $(find org/ -name "*.pom" | wc -l)"
echo "MD5 files: $(find org/ -name "*.md5" | wc -l)"
echo "SHA1 files: $(find org/ -name "*.sha1" | wc -l)"
echo "ASC files: $(find org/ -name "*.asc" | wc -l)"

# Step 7: Display upload information
print_header "🚀 Step 7: Upload information..."
print_status "GPG key information:"
echo "Key ID: $GPG_KEY_ID"
echo "Fingerprint: $(gpg --fingerprint $GPG_KEY_ID | grep "指纹" | cut -d' ' -f4-)"

print_status "Upload steps:"
echo "1. Visit: https://central.sonatype.com/"
echo "2. Login to your account"
echo "3. Upload file: veryoauthsdk-$VERSION.zip"
echo "4. Wait for validation to complete"

print_status "PGP public key upload:"
echo "If you encounter public key issues, visit:"
echo "- https://keyserver.ubuntu.com/"
echo "- https://pgp.mit.edu/"
echo "- https://keys.openpgp.org/"
echo "Upload your public key:"
gpg --armor --export $GPG_KEY_ID

print_status "🎉 Build and sign completed!"
print_status "📦 ZIP file: $UPLOAD_DIR/veryoauthsdk-$VERSION.zip"
print_status "📁 Upload directory: $UPLOAD_DIR/org/"
