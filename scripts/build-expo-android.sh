#!/bin/bash

# Build Expo Android APK Script
# This script builds the Expo Android APK using gradle directly (not Expo CLI)

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
EXPO_DIR="$PROJECT_ROOT/example_expo"
ANDROID_DIR="$EXPO_DIR/android"

echo -e "${BLUE}🔨 Building Expo Android APK...${NC}"
echo -e "${YELLOW}Project root: $PROJECT_ROOT${NC}"
echo -e "${YELLOW}Expo directory: $EXPO_DIR${NC}"
echo -e "${YELLOW}Android directory: $ANDROID_DIR${NC}"

# Check if Expo directory exists
if [ ! -d "$EXPO_DIR" ]; then
    echo -e "${RED}❌ Expo directory not found at: $EXPO_DIR${NC}"
    exit 1
fi

# Check if Android directory exists
if [ ! -d "$ANDROID_DIR" ]; then
    echo -e "${RED}❌ Android directory not found at: $ANDROID_DIR${NC}"
    echo -e "${YELLOW}💡 Run 'expo prebuild' first to generate the android directory${NC}"
    exit 1
fi

# Check if gradlew exists
if [ ! -f "$ANDROID_DIR/gradlew" ]; then
    echo -e "${RED}❌ gradlew not found at: $ANDROID_DIR/gradlew${NC}"
    echo -e "${YELLOW}💡 Run 'expo prebuild' first to generate the android directory${NC}"
    exit 1
fi

# Make gradlew executable
chmod +x "$ANDROID_DIR/gradlew"

# Navigate to expo directory (where package.json is)
cd "$EXPO_DIR"

echo -e "${BLUE}📦 Installing npm dependencies...${NC}"
npm install

echo -e "${BLUE}🏗️  Building Expo bundle...${NC}"
# Create the bundle directory if it doesn't exist
mkdir -p "$ANDROID_DIR/app/src/main/assets"

# Check if expo CLI is available
if ! command -v npx expo &> /dev/null; then
    echo -e "${RED}❌ Expo CLI not found. Installing...${NC}"
    npm install -g @expo/cli
fi

# Bundle the JavaScript code using Expo CLI
npx expo export:embed --platform android --dev false --bundle-output "$ANDROID_DIR/app/src/main/assets/index.android.bundle"

# The expo export:embed command should have created the bundle in the right location
# But let's verify it exists
BUNDLE_PATH="$ANDROID_DIR/app/src/main/assets/index.android.bundle"
if [ ! -f "$BUNDLE_PATH" ]; then
    echo -e "${YELLOW}⚠️  Bundle not found at expected location, trying alternative approach...${NC}"
    
    # Alternative: use expo export and copy files manually
    npx expo export --platform android --dev false --output-dir ./dist
    
    # Copy the bundle to the expected location
    if [ -f "./dist/_expo/static/js/android/index.js" ]; then
        cp "./dist/_expo/static/js/android/index.js" "$BUNDLE_PATH"
        echo -e "${GREEN}✅ Bundle copied to: $BUNDLE_PATH${NC}"
    else
        echo -e "${RED}❌ Could not create bundle. Please check Expo configuration.${NC}"
        exit 1
    fi
fi

# Navigate to Android directory
cd "$ANDROID_DIR"

echo -e "${BLUE}🔧 Cleaning previous builds and generating codegen...${NC}"
# Clean build artifacts and .cxx directory which can cause CMake issues
rm -rf app/.cxx
rm -rf app/build
rm -rf build

# Generate codegen for native modules (required for new architecture)
echo -e "${BLUE}📝 Generating codegen for native modules...${NC}"
./gradlew generateCodegenArtifactsFromSchema

echo -e "${BLUE}🧹 Running gradle clean...${NC}"
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
    echo -e "${GREEN}✅ Expo APK built successfully!${NC}"
    echo -e "${GREEN}📱 APK location: $APK_PATH${NC}"
    
    # Get APK size
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}📏 APK size: $APK_SIZE${NC}"
else
    echo -e "${RED}❌ APK build failed!${NC}"
    exit 1
fi

echo -e "${BLUE}🎉 Build completed successfully!${NC}"
echo -e "${YELLOW}To install and run the APK, use: ./scripts/run-expo-android.sh${NC}"
