#!/bin/bash

# Build Android APK Script
# This script builds the Android APK using gradle directly (not React Native CLI)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXAMPLE_DIR="$PROJECT_ROOT/example"
ANDROID_DIR="$EXAMPLE_DIR/android"

echo -e "${BLUE}🔨 Building Android APK...${NC}"
echo -e "${YELLOW}Project root: $PROJECT_ROOT${NC}"
echo -e "${YELLOW}Example directory: $EXAMPLE_DIR${NC}"
echo -e "${YELLOW}Android directory: $ANDROID_DIR${NC}"

# Check if Android directory exists
if [ ! -d "$ANDROID_DIR" ]; then
    echo -e "${RED}❌ Android directory not found at: $ANDROID_DIR${NC}"
    exit 1
fi

# Check if gradlew exists
if [ ! -f "$ANDROID_DIR/gradlew" ]; then
    echo -e "${RED}❌ gradlew not found at: $ANDROID_DIR/gradlew${NC}"
    exit 1
fi

# Make gradlew executable
chmod +x "$ANDROID_DIR/gradlew"

# Navigate to example directory (where package.json is)
cd "$EXAMPLE_DIR"

echo -e "${BLUE}📦 Installing npm dependencies...${NC}"
npm install

echo -e "${BLUE}🏗️  Building React Native bundle...${NC}"
# Create the bundle directory if it doesn't exist
mkdir -p "$ANDROID_DIR/app/src/main/assets"

# Bundle the JavaScript code
npx react-native bundle \
    --platform android \
    --dev false \
    --entry-file index.js \
    --bundle-output "$ANDROID_DIR/app/src/main/assets/index.android.bundle" \
    --assets-dest "$ANDROID_DIR/app/src/main/res/"

# Navigate to Android directory
cd "$ANDROID_DIR"

echo -e "${BLUE}🔧 Cleaning previous builds...${NC}"
./gradlew clean

echo -e "${BLUE}🏗️  Building APK...${NC}"
# Build debug APK by default, can be changed to assembleRelease for release build
BUILD_TYPE=${1:-Debug}
echo -e "${YELLOW}Building $BUILD_TYPE APK...${NC}"

if [ "$BUILD_TYPE" = "Release" ] || [ "$BUILD_TYPE" = "release" ]; then
    ./gradlew assembleRelease
    APK_PATH="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
else
    ./gradlew assembleDebug
    APK_PATH="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
fi

# Check if APK was built successfully
if [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}✅ APK built successfully!${NC}"
    echo -e "${GREEN}📱 APK location: $APK_PATH${NC}"
    
    # Get APK size
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}📏 APK size: $APK_SIZE${NC}"
else
    echo -e "${RED}❌ APK build failed!${NC}"
    exit 1
fi

echo -e "${BLUE}🎉 Build completed successfully!${NC}"
echo -e "${YELLOW}To install and run the APK, use: ./scripts/run-android.sh${NC}"
