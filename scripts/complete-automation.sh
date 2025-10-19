#!/bin/bash

# Complete Maven Central automation process
# Includes build, sign, package and automatic upload

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🚀 Maven Central Complete Automation Process${NC}"
echo "============================================="

export CENTRAL_USERNAME=16Be1V
export CENTRAL_PASSWORD=vpBbpo3vSwNdIR3Th15WDUxRCdtFYatny


# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}📁 Project root: $PROJECT_ROOT${NC}"

# Check environment variables
echo -e "\n${YELLOW}🔍 Checking environment variables...${NC}"

if [ -z "$CENTRAL_USERNAME" ]; then
    echo -e "${RED}❌ CENTRAL_USERNAME environment variable not set${NC}"
    echo "Please set: export CENTRAL_USERNAME=your_username"
    echo "Or run: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

if [ -z "$CENTRAL_PASSWORD" ]; then
    echo -e "${RED}❌ CENTRAL_PASSWORD environment variable not set${NC}"
    echo "Please set: export CENTRAL_PASSWORD=your_password"
    echo "Or run: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

echo -e "${GREEN}✅ Environment variables set${NC}"

# Step 1: Build and sign
echo -e "\n${YELLOW}🔨 Step 1: Build and sign...${NC}"
cd "$PROJECT_ROOT"

if [ -f "scripts/build-and-sign-android.sh" ]; then
    echo "Running build script..."
    ./scripts/build-and-sign-android.sh
    echo -e "${GREEN}✅ Build and sign completed${NC}"
else
    echo -e "${RED}❌ Build script not found${NC}"
    exit 1
fi

# Step 2: Automatic upload
echo -e "\n${YELLOW}📤 Step 2: Automatic upload to Maven Central...${NC}"

if [ -f "scripts/auto-upload-to-central.sh" ]; then
    echo "Running automatic upload script..."
    ./scripts/auto-upload-to-central.sh
    echo -e "${GREEN}✅ Automatic upload completed${NC}"
else
    echo -e "${RED}❌ Upload script not found${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Complete automation process finished!${NC}"
echo -e "${BLUE}📋 Your Android SDK has been successfully published to Maven Central${NC}"
echo -e "${BLUE}🌐 View: https://central.sonatype.com/${NC}"
echo -e "${BLUE}📦 Use: implementation 'org.very:veryoauthsdk:1.0.0'${NC}"
