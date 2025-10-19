#!/bin/bash

# Complete script for automatic upload to Maven Central
# Based on Sonatype Central Publishing API

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Maven Central Automatic Upload Script${NC}"
echo "============================================="

# Configuration variables
CENTRAL_API_BASE="https://central.sonatype.com/api/v1"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"
ZIP_FILE="$UPLOAD_DIR/veryoauthsdk-1.0.2.zip"

# Check environment variables
echo -e "\n${YELLOW}🔍 Checking environment variables...${NC}"

if [ -z "$CENTRAL_USERNAME" ]; then
    echo -e "${RED}❌ CENTRAL_USERNAME environment variable not set${NC}"
    echo "Please set: export CENTRAL_USERNAME=your_username"
    exit 1
fi

if [ -z "$CENTRAL_PASSWORD" ]; then
    echo -e "${RED}❌ CENTRAL_PASSWORD environment variable not set${NC}"
    echo "Please set: export CENTRAL_PASSWORD=your_password"
    exit 1
fi

echo -e "${GREEN}✅ Environment variables set${NC}"

# Generate authentication token
echo -e "\n${YELLOW}🔐 Generating authentication token...${NC}"
AUTH_TOKEN=$(printf "%s:%s" "$CENTRAL_USERNAME" "$CENTRAL_PASSWORD" | base64)
echo -e "${GREEN}✅ Authentication token generated${NC}"

# Check if ZIP file exists
echo -e "\n${YELLOW}📦 Checking upload file...${NC}"
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ ZIP file not found: $ZIP_FILE${NC}"
    echo "Please run first: ./scripts/build-and-sign-android.sh"
    exit 1
fi

ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
echo -e "${GREEN}✅ Found ZIP file: $ZIP_FILE ($ZIP_SIZE)${NC}"

# Step 1: Upload deployment bundle
echo -e "\n${YELLOW}📤 Step 1: Upload deployment bundle...${NC}"

UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    --request POST \
    --header "Authorization: Bearer $AUTH_TOKEN" \
    --form "bundle=@$ZIP_FILE" \
           --form "name=VeryOauthSDK-1.0.2" \
    --form "publishingType=AUTOMATIC" \
    "$CENTRAL_API_BASE/publisher/upload")

# 分离响应体和状态码
HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$UPLOAD_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 201 ]; then
    DEPLOYMENT_ID="$RESPONSE_BODY"
    echo -e "${GREEN}✅ Upload successful${NC}"
    echo -e "${BLUE}📋 Deployment ID: $DEPLOYMENT_ID${NC}"
else
    echo -e "${RED}❌ Upload failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

# Step 2: Monitor deployment status
echo -e "\n${YELLOW}⏳ Step 2: Monitor deployment status...${NC}"

MAX_ATTEMPTS=30
ATTEMPT=0
SLEEP_INTERVAL=10

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo -e "${BLUE}📊 Checking status (attempt $ATTEMPT/$MAX_ATTEMPTS)...${NC}"
    
    STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" \
        --request POST \
        --header "Authorization: Bearer $AUTH_TOKEN" \
        "$CENTRAL_API_BASE/publisher/status?id=$DEPLOYMENT_ID")
    
    HTTP_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)
    STATUS_BODY=$(echo "$STATUS_RESPONSE" | head -n -1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        # 解析JSON响应 (需要jq工具)
        if command -v jq &> /dev/null; then
            DEPLOYMENT_STATE=$(echo "$STATUS_BODY" | jq -r '.deploymentState')
            DEPLOYMENT_NAME=$(echo "$STATUS_BODY" | jq -r '.deploymentName')
            
            echo -e "${BLUE}📋 Deployment name: $DEPLOYMENT_NAME${NC}"
            echo -e "${BLUE}📊 Deployment status: $DEPLOYMENT_STATE${NC}"
            
            case "$DEPLOYMENT_STATE" in
                "PENDING")
                    echo -e "${YELLOW}⏳ Waiting for processing...${NC}"
                    ;;
                "VALIDATING")
                    echo -e "${YELLOW}🔍 Validating...${NC}"
                    ;;
                "VALIDATED")
                    echo -e "${GREEN}✅ Validation passed, waiting for publish...${NC}"
                    ;;
                "PUBLISHING")
                    echo -e "${YELLOW}📤 Publishing...${NC}"
                    ;;
                "PUBLISHED")
                    echo -e "${GREEN}🎉 Published successfully!${NC}"
                    
                    # Display package URLs
                    PURLS=$(echo "$STATUS_BODY" | jq -r '.purls[]?' 2>/dev/null || echo "")
                    if [ -n "$PURLS" ]; then
                        echo -e "${BLUE}📦 Package URLs:${NC}"
                        echo "$PURLS" | while read -r purl; do
                            echo -e "${GREEN}  - $purl${NC}"
                        done
                    fi
                    
                    echo -e "\n${GREEN}🎯 Publishing completed!${NC}"
                    echo -e "${BLUE}📋 Deployment ID: $DEPLOYMENT_ID${NC}"
                    echo -e "${BLUE}🌐 View: https://central.sonatype.com/${NC}"
                    exit 0
                    ;;
                "FAILED")
                    echo -e "${RED}❌ Publishing failed${NC}"
                    echo "Response: $STATUS_BODY"
                    exit 1
                    ;;
                *)
                    echo -e "${YELLOW}❓ Unknown status: $DEPLOYMENT_STATE${NC}"
                    ;;
            esac
        else
            echo -e "${YELLOW}⚠️  jq not installed, cannot parse JSON response${NC}"
            echo "Response: $STATUS_BODY"
        fi
    else
        echo -e "${RED}❌ Status check failed (HTTP $HTTP_CODE)${NC}"
        echo "Response: $STATUS_BODY"
    fi
    
    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        echo -e "${BLUE}⏳ Waiting $SLEEP_INTERVAL seconds before retry...${NC}"
        sleep $SLEEP_INTERVAL
    fi
done

echo -e "${RED}❌ Timeout: Deployment status check exceeded $MAX_ATTEMPTS attempts${NC}"
echo -e "${YELLOW}💡 Please manually check deployment status: https://central.sonatype.com/${NC}"
exit 1
