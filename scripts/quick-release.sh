#!/bin/bash

# VeryOauthSDK Quick Release Script
# Simplified interface for common release operations

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_header "🚀 VeryOauthSDK Quick Release"
echo "================================"

# Check if version is provided
if [ -z "$1" ]; then
    print_error "Please provide a version number"
    echo ""
    echo "Usage: $0 <version> [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build and sign only"
    echo "  upload    - Upload to Maven Central (requires credentials)"
    echo "  complete  - Complete release process (default)"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0                    # Complete release"
    echo "  $0 1.0.0 build              # Build and sign only"
    echo "  $0 1.0.0 upload             # Upload only (requires build first)"
    echo ""
    exit 1
fi

VERSION=$1
COMMAND=${2:-"complete"}

print_status "Version: $VERSION"
print_status "Command: $COMMAND"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$COMMAND" in
    "build")
        print_header "🔨 Building and signing..."
        "$SCRIPT_DIR/build-and-sign.sh" "$VERSION"
        print_status "✅ Build and sign completed"
        ;;
    "upload")
        print_header "📤 Uploading to Maven Central..."
        if [ -z "$CENTRAL_USERNAME" ] || [ -z "$CENTRAL_PASSWORD" ]; then
            print_error "Maven Central credentials not set"
            echo "Please set:"
            echo "  export CENTRAL_USERNAME=your_username"
            echo "  export CENTRAL_PASSWORD=your_password"
            exit 1
        fi
        "$SCRIPT_DIR/upload-to-central.sh" "$VERSION"
        print_status "✅ Upload completed"
        ;;
    "complete")
        print_header "🚀 Complete release process..."
        "$SCRIPT_DIR/release-complete.sh" "$VERSION"
        print_status "✅ Complete release finished"
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        echo "Available commands: build, upload, complete"
        exit 1
        ;;
esac

print_status "🎉 Operation completed successfully!"
