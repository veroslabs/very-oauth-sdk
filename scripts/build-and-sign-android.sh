#!/bin/bash

# Android SDK Complete Build, Sign and Package Script
# Includes compilation, GPG signing, checksum generation, ZIP packaging

set -e

echo "🚀 Android SDK Complete Build Process"
echo "====================================="

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"

echo -e "${BLUE}📁 Project root: $PROJECT_ROOT${NC}"
echo -e "${BLUE}📁 Android directory: $ANDROID_DIR${NC}"
echo -e "${BLUE}📁 Upload directory: $UPLOAD_DIR${NC}"

# Check required tools
echo -e "\n${YELLOW}🔍 Checking required tools...${NC}"

# Check Gradle
if [ ! -f "$ANDROID_DIR/gradlew" ]; then
    echo -e "${RED}❌ Gradle Wrapper not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Gradle Wrapper found${NC}"

# Check GPG
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}❌ GPG not installed${NC}"
    echo "Please install GPG: brew install gnupg"
    exit 1
fi
echo -e "${GREEN}✅ GPG installed${NC}"

# Check GPG key
if ! gpg --list-secret-keys --keyid-format LONG | grep -q "sec"; then
    echo -e "${RED}❌ No GPG key found${NC}"
    echo "Please generate GPG key first: gpg --full-generate-key"
    exit 1
fi
echo -e "${GREEN}✅ GPG key found${NC}"

# Get GPG key information
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)
echo -e "${BLUE}🔑 GPG Key ID: $GPG_KEY_ID${NC}"

# Step 1: Clean and build
echo -e "\n${YELLOW}🧹 Step 1: Clean and build...${NC}"
cd "$ANDROID_DIR"

echo "Cleaning project..."
./gradlew clean

echo "Building project..."
./gradlew :veryoauthsdk:build

echo "Generating release version..."
./gradlew :veryoauthsdk:assembleRelease

echo "Generating sources and documentation..."
./gradlew :veryoauthsdk:sourcesJar :veryoauthsdk:javadocJar

echo "Generating POM file..."
./gradlew :veryoauthsdk:generatePomFileForReleasePublication

echo -e "${GREEN}✅ Build completed${NC}"

# Step 2: Prepare upload directory
echo -e "\n${YELLOW}📦 Step 2: Prepare upload directory...${NC}"

# Clean and create upload directory
rm -rf "$UPLOAD_DIR"
mkdir -p "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1"

# Copy files to correct location
echo "Copying AAR file..."
cp "$ANDROID_DIR/veryoauthsdk/build/outputs/aar/veryoauthsdk-release.aar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1/veryoauthsdk-1.0.1.aar"

echo "Copying POM file..."
cp "$ANDROID_DIR/veryoauthsdk/build/publications/release/pom-default.xml" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1/veryoauthsdk-1.0.1.pom"

echo "Copying sources JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-sources.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1/veryoauthsdk-1.0.1-sources.jar"

echo "Copying documentation JAR..."
cp "$ANDROID_DIR/veryoauthsdk/build/libs/veryoauthsdk-javadoc.jar" \
   "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1/veryoauthsdk-1.0.1-javadoc.jar"

echo -e "${GREEN}✅ File copying completed${NC}"

# Step 3: Generate checksums
echo -e "\n${YELLOW}🔐 Step 3: Generate checksums...${NC}"
cd "$UPLOAD_DIR/org/very/veryoauthsdk/1.0.1"

echo "Generating MD5 checksums..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        md5sum "$file" | cut -d' ' -f1 > "$file.md5"
        echo "  ✅ $file.md5"
    fi
done

echo "Generating SHA1 checksums..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        sha1sum "$file" | cut -d' ' -f1 > "$file.sha1"
        echo "  ✅ $file.sha1"
    fi
done

echo -e "${GREEN}✅ Checksum generation completed${NC}"

# Step 4: Generate GPG signatures
echo -e "\n${YELLOW}🔑 Step 4: Generate GPG signatures...${NC}"

echo "Generating GPG signatures..."
for file in *.aar *.jar *.pom; do
    if [ -f "$file" ]; then
        echo "  Signing: $file"
        gpg --armor --detach-sign "$file"
        if [ -f "$file.asc" ]; then
            echo "  ✅ $file.asc"
        else
            echo -e "${RED}  ❌ $file.asc generation failed${NC}"
        fi
done

echo -e "${GREEN}✅ GPG signature generation completed${NC}"

# Step 5: Create ZIP package
echo -e "\n${YELLOW}📦 Step 5: Create ZIP package...${NC}"
cd "$UPLOAD_DIR"

echo "Creating ZIP package..."
rm -f veryoauthsdk-1.0.1.zip
zip -r veryoauthsdk-1.0.1.zip org/

ZIP_SIZE=$(du -h veryoauthsdk-1.0.1.zip | cut -f1)
echo -e "${GREEN}✅ ZIP package created: veryoauthsdk-1.0.1.zip ($ZIP_SIZE)${NC}"

# Step 6: Display file list
echo -e "\n${YELLOW}📋 Step 6: File list...${NC}"
echo "Upload directory contents:"
find org/ -type f | sort

echo -e "\n${BLUE}📊 File statistics:${NC}"
echo "AAR files: $(find org/ -name "*.aar" | wc -l)"
echo "JAR files: $(find org/ -name "*.jar" | wc -l)"
echo "POM files: $(find org/ -name "*.pom" | wc -l)"
echo "MD5 files: $(find org/ -name "*.md5" | wc -l)"
echo "SHA1 files: $(find org/ -name "*.sha1" | wc -l)"
echo "ASC files: $(find org/ -name "*.asc" | wc -l)"

# Step 7: Display upload information
echo -e "\n${YELLOW}🚀 Step 7: Upload information...${NC}"
echo -e "${BLUE}GPG key information:${NC}"
echo "Key ID: $GPG_KEY_ID"
echo "Fingerprint: $(gpg --fingerprint $GPG_KEY_ID | grep "指纹" | cut -d' ' -f4-)"

echo -e "\n${BLUE}Upload steps:${NC}"
echo "1. Visit: https://central.sonatype.com/"
echo "2. Login to your account"
echo "3. Upload file: veryoauthsdk-1.0.0.zip"
echo "4. Wait for validation to complete"

echo -e "\n${BLUE}PGP public key upload:${NC}"
echo "If you encounter public key issues, visit:"
echo "- https://keyserver.ubuntu.com/"
echo "- https://pgp.mit.edu/"
echo "- https://keys.openpgp.org/"
echo "Upload your public key:"
gpg --armor --export $GPG_KEY_ID

echo -e "\n${GREEN}🎉 Build completed!${NC}"
echo -e "${GREEN}📦 ZIP file: $UPLOAD_DIR/veryoauthsdk-1.0.1.zip${NC}"
echo -e "${GREEN}📁 Upload directory: $UPLOAD_DIR/org/${NC}"
