#!/bin/bash

# Build and Run Expo Android APK Script
# This script builds the Expo Android APK and then installs/runs it on device/emulator

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Building and Running Expo Android APK...${NC}"

# Build type (debug or release)
BUILD_TYPE=${1:-debug}
echo -e "${YELLOW}Build type: $BUILD_TYPE${NC}"

# Step 1: Build the Expo APK
echo -e "${BLUE}📦 Step 1: Building Expo APK...${NC}"
"$SCRIPT_DIR/build-expo-android.sh" "$BUILD_TYPE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Step 2: Run the Expo APK
echo -e "${BLUE}📱 Step 2: Installing and running Expo APK...${NC}"
"$SCRIPT_DIR/run-expo-android.sh" "$BUILD_TYPE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Run failed!${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Expo build and run completed successfully!${NC}"
