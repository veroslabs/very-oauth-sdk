#!/bin/bash

# VeryOauthSDK Upload to Maven Central Script
# Automatically uploads signed packages to Maven Central via Sonatype Central API

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

print_header "🚀 Maven Central Automatic Upload Script"
echo "============================================="

# Configuration variables
CENTRAL_API_BASE="https://central.sonatype.com/api/v1"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPLOAD_DIR="$PROJECT_ROOT/upload-package"

# Get version from command line or use default
VERSION=${1:-"1.0.2"}
ZIP_FILE="$UPLOAD_DIR/veryoauthsdk-$VERSION.zip"

CENTRAL_USERNAME=slPqDf
CENTRAL_PASSWORD=ehP5DBrVAmZx1lYqHhsg8LVZucB9jKnCy

print_status "Version: $VERSION"
print_status "ZIP file: $ZIP_FILE"

# Check environment variables
print_header "🔍 Checking environment variables..."

if [ -z "$CENTRAL_USERNAME" ]; then
    print_error "CENTRAL_USERNAME environment variable not set"
    echo "Please set: export CENTRAL_USERNAME=your_username"
    echo "Or run: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

if [ -z "$CENTRAL_PASSWORD" ]; then
    print_error "CENTRAL_PASSWORD environment variable not set"
    echo "Please set: export CENTRAL_PASSWORD=your_password"
    echo "Or run: CENTRAL_USERNAME=your_username CENTRAL_PASSWORD=your_password $0"
    exit 1
fi

print_status "✅ Environment variables set"

# Generate authentication token
print_header "🔐 Generating authentication token..."
AUTH_TOKEN=$(printf "%s:%s" "$CENTRAL_USERNAME" "$CENTRAL_PASSWORD" | base64)
print_status "✅ Authentication token generated"

# Check if ZIP file exists
print_header "📦 Checking upload file..."
if [ ! -f "$ZIP_FILE" ]; then
    print_error "ZIP file not found: $ZIP_FILE"
    echo "Please run first: ./scripts/build-and-sign.sh $VERSION"
    exit 1
fi

ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
print_status "✅ Found ZIP file: $ZIP_FILE ($ZIP_SIZE)"

# Step 1: Upload deployment bundle
print_header "📤 Step 1: Upload deployment bundle..."

UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    --request POST \
    --header "Authorization: Bearer $AUTH_TOKEN" \
    --form "bundle=@$ZIP_FILE" \
    --form "name=VeryOauthSDK-$VERSION" \
    --form "publishingType=AUTOMATIC" \
    "$CENTRAL_API_BASE/publisher/upload")

# Separate response body and status code
HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$UPLOAD_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 201 ]; then
    DEPLOYMENT_ID="$RESPONSE_BODY"
    print_status "✅ Upload successful"
    print_status "📋 Deployment ID: $DEPLOYMENT_ID"
else
    print_error "Upload failed (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

# Step 2: Monitor deployment status
print_header "⏳ Step 2: Monitor deployment status..."

MAX_ATTEMPTS=30
ATTEMPT=0
SLEEP_INTERVAL=10

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    print_status "📊 Checking status (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
    
    STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" \
        --request POST \
        --header "Authorization: Bearer $AUTH_TOKEN" \
        "$CENTRAL_API_BASE/publisher/status?id=$DEPLOYMENT_ID")
    
    HTTP_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)
    STATUS_BODY=$(echo "$STATUS_RESPONSE" | head -n -1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        # Parse JSON response (requires jq tool)
        if command -v jq &> /dev/null; then
            DEPLOYMENT_STATE=$(echo "$STATUS_BODY" | jq -r '.deploymentState')
            DEPLOYMENT_NAME=$(echo "$STATUS_BODY" | jq -r '.deploymentName')
            
            print_status "📋 Deployment name: $DEPLOYMENT_NAME"
            print_status "📊 Deployment status: $DEPLOYMENT_STATE"
            
            case "$DEPLOYMENT_STATE" in
                "PENDING")
                    print_warning "⏳ Waiting for processing..."
                    ;;
                "VALIDATING")
                    print_warning "🔍 Validating..."
                    ;;
                "VALIDATED")
                    print_status "✅ Validation passed, waiting for publish..."
                    ;;
                "PUBLISHING")
                    print_warning "📤 Publishing..."
                    ;;
                "PUBLISHED")
                    print_status "🎉 Published successfully!"
                    
                    # Display package URLs
                    PURLS=$(echo "$STATUS_BODY" | jq -r '.purls[]?' 2>/dev/null || echo "")
                    if [ -n "$PURLS" ]; then
                        print_status "📦 Package URLs:"
                        echo "$PURLS" | while read -r purl; do
                            print_status "  - $purl"
                        done
                    fi
                    
                    print_status "🎯 Publishing completed!"
                    print_status "📋 Deployment ID: $DEPLOYMENT_ID"
                    print_status "🌐 View: https://central.sonatype.com/"
                    print_status "📦 Use: implementation 'org.very:veryoauthsdk:$VERSION'"
                    exit 0
                    ;;
                "FAILED")
                    print_error "❌ Publishing failed"
                    echo "Response: $STATUS_BODY"
                    exit 1
                    ;;
                *)
                    print_warning "❓ Unknown status: $DEPLOYMENT_STATE"
                    ;;
            esac
        else
            print_warning "⚠️  jq not installed, cannot parse JSON response"
            echo "Response: $STATUS_BODY"
        fi
    else
        print_error "Status check failed (HTTP $HTTP_CODE)"
        echo "Response: $STATUS_BODY"
    fi
    
    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        print_status "⏳ Waiting $SLEEP_INTERVAL seconds before retry..."
        sleep $SLEEP_INTERVAL
    fi
done

print_error "Timeout: Deployment status check exceeded $MAX_ATTEMPTS attempts"
print_warning "💡 Please manually check deployment status: https://central.sonatype.com/"
exit 1
