#!/bin/bash

# Build and Run Android APK Script
# This script builds the Android APK and then installs/runs it on device/emulator

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Building and Running Android APK...${NC}"

# Build type (debug or release)
BUILD_TYPE=${1:-debug}
echo -e "${YELLOW}Build type: $BUILD_TYPE${NC}"

# Step 1: Build the APK
echo -e "${BLUE}📦 Step 1: Building APK...${NC}"
"$SCRIPT_DIR/build-android.sh" "$BUILD_TYPE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Step 2: Run the APK
echo -e "${BLUE}📱 Step 2: Installing and running APK...${NC}"
"$SCRIPT_DIR/run-android.sh" "$BUILD_TYPE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Run failed!${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Build and run completed successfully!${NC}"
