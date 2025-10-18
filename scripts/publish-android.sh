#!/bin/bash

# Android Maven Publishing Script for VeryOauthSDK
# This script automates the process of publishing the Android SDK to Maven Central

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "android/veryoauthsdk/build.gradle" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check for required environment variables
check_credentials() {
    print_status "Checking for required credentials..."
    
    if [ -z "$OSSRH_USERNAME" ] || [ -z "$OSSRH_PASSWORD" ]; then
        print_error "OSSRH_USERNAME and OSSRH_PASSWORD environment variables are required"
        print_status "Set them with: export OSSRH_USERNAME=your_username && export OSSRH_PASSWORD=your_password"
        exit 1
    fi
    
    print_success "Credentials found"
}

# Clean and build the project
build_project() {
    print_status "Cleaning and building the project..."
    
    cd android
    
    # Clean previous builds
    ./gradlew clean
    
    # Build the project
    ./gradlew :veryoauthsdk:build
    
    # Generate documentation
    ./gradlew :veryoauthsdk:dokkaHtml
    
    print_success "Project built successfully"
}

# Publish to staging repository
publish_to_staging() {
    print_status "Publishing to Sonatype staging repository..."
    
    ./gradlew :veryoauthsdk:publishReleasePublicationToSonatypeRepository
    
    print_success "Published to staging repository"
    print_warning "Please go to https://s01.oss.sonatype.org/ to close and release the staging repository"
}

# Publish to local Maven repository for testing
publish_to_local() {
    print_status "Publishing to local Maven repository for testing..."
    
    ./gradlew :veryoauthsdk:publishToMavenLocal
    
    print_success "Published to local Maven repository"
    print_status "You can now test the library locally with: implementation 'com.veryoauthsdk:veryoauthsdk:1.0.0'"
}

# Main execution
main() {
    print_status "Starting Android Maven publishing process..."
    
    # Check credentials
    check_credentials
    
    # Build project
    build_project
    
    # Ask user what to do
    echo ""
    print_status "What would you like to do?"
    echo "1) Publish to local Maven repository (for testing)"
    echo "2) Publish to Sonatype staging repository"
    echo "3) Both"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            publish_to_local
            ;;
        2)
            publish_to_staging
            ;;
        3)
            publish_to_local
            publish_to_staging
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    print_success "Publishing process completed!"
    
    if [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
        echo ""
        print_warning "Next steps:"
        echo "1. Go to https://s01.oss.sonatype.org/"
        echo "2. Navigate to 'Staging Repositories'"
        echo "3. Find your uploaded repository"
        echo "4. Select it and click 'Close'"
        echo "5. Wait for validation to complete"
        echo "6. Click 'Release' to publish to Maven Central"
        echo ""
        print_status "The library will be available on Maven Central within a few hours"
    fi
}

# Run main function
main "$@"