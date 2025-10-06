#!/bin/bash

# Run Expo Android APK Script
# This script installs and runs the Expo Android APK on connected device/emulator

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

echo -e "${BLUE}📱 Running Expo Android APK...${NC}"

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}❌ adb not found. Please install Android SDK and add adb to your PATH${NC}"
    echo -e "${YELLOW}💡 You can install Android SDK via Android Studio or command line tools${NC}"
    exit 1
fi

# Build type (debug or release)
BUILD_TYPE=${1:-debug}
echo -e "${YELLOW}Using build type: $BUILD_TYPE${NC}"

# Determine APK path based on build type
if [ "$BUILD_TYPE" = "release" ]; then
    APK_PATH="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
else
    APK_PATH="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
fi

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ APK not found at: $APK_PATH${NC}"
    echo -e "${YELLOW}💡 Run ./scripts/build-expo-android.sh first to build the APK${NC}"
    exit 1
fi

echo -e "${GREEN}📦 Found APK at: $APK_PATH${NC}"

# Check for connected devices/emulators
echo -e "${BLUE}🔍 Checking for connected devices...${NC}"
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No Android devices or emulators found${NC}"
    
    # Check if emulator command is available
    if ! command -v emulator &> /dev/null; then
        echo -e "${RED}❌ emulator command not found. Please install Android SDK and add emulator to your PATH${NC}"
        echo -e "${YELLOW}💡 Or connect an Android device with USB debugging enabled${NC}"
        exit 1
    fi
    
    # List available AVDs
    echo -e "${BLUE}📱 Looking for available emulators...${NC}"
    AVDS=$(emulator -list-avds 2>/dev/null)
    
    if [ -z "$AVDS" ]; then
        echo -e "${RED}❌ No Android Virtual Devices (AVDs) found${NC}"
        echo -e "${YELLOW}💡 Please create an AVD using Android Studio or avdmanager${NC}"
        echo -e "${YELLOW}💡 Or connect an Android device with USB debugging enabled${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}📱 Available emulators:${NC}"
    echo "$AVDS" | while read -r avd; do
        echo -e "${YELLOW}  • $avd${NC}"
    done
    
    # Get the first AVD
    FIRST_AVD=$(echo "$AVDS" | head -n 1)
    
    # Ask user if they want to start an emulator
    echo -e "${BLUE}🚀 Would you like to start the '$FIRST_AVD' emulator? (y/N)${NC}"
    read -r -t 10 response || response="y"  # Default to yes after 10 seconds
    
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        echo -e "${BLUE}🚀 Starting emulator '$FIRST_AVD'...${NC}"
        echo -e "${YELLOW}💡 This may take a few minutes...${NC}"
        
        # Start emulator in background
        emulator -avd "$FIRST_AVD" -no-snapshot-save -no-boot-anim &
        EMULATOR_PID=$!
        
        echo -e "${BLUE}⏳ Waiting for emulator to boot...${NC}"
        
        # Wait for emulator to be ready (max 2 minutes)
        TIMEOUT=120
        ELAPSED=0
        while [ $ELAPSED -lt $TIMEOUT ]; do
            DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
            if [ "$DEVICES" -gt 0 ]; then
                # Check if device is fully booted
                BOOT_COMPLETE=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
                if [ "$BOOT_COMPLETE" = "1" ]; then
                    echo -e "${GREEN}✅ Emulator is ready!${NC}"
                    break
                fi
            fi
            
            echo -e "${YELLOW}⏳ Still waiting... (${ELAPSED}s/${TIMEOUT}s)${NC}"
            sleep 5
            ELAPSED=$((ELAPSED + 5))
        done
        
        # Check if emulator started successfully
        DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
        if [ "$DEVICES" -eq 0 ]; then
            echo -e "${RED}❌ Emulator failed to start within ${TIMEOUT} seconds${NC}"
            echo -e "${YELLOW}💡 You can manually start it with: emulator -avd $FIRST_AVD${NC}"
            # Kill the emulator process if it's still running
            kill $EMULATOR_PID 2>/dev/null || true
            exit 1
        fi
    else
        echo -e "${YELLOW}💡 Please start an emulator manually or connect an Android device${NC}"
        echo -e "${YELLOW}💡 To start an emulator: emulator -avd <avd_name>${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Found $DEVICES connected device(s)${NC}"
adb devices

# If multiple devices, let user choose or use first one
if [ "$DEVICES" -gt 1 ]; then
    echo -e "${YELLOW}⚠️  Multiple devices found. Using the first one.${NC}"
    echo -e "${YELLOW}💡 To specify a device, use: adb -s <device_id> install <apk>${NC}"
fi

# Get package name from build.gradle (Expo uses different package name)
PACKAGE_NAME="com.anonymous.example_expo"  # From the build.gradle we saw

echo -e "${BLUE}🗑️  Uninstalling previous version (if exists)...${NC}"
adb uninstall "$PACKAGE_NAME" 2>/dev/null || echo -e "${YELLOW}No previous installation found${NC}"

echo -e "${BLUE}📲 Installing Expo APK...${NC}"
adb install "$APK_PATH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Expo APK installed successfully!${NC}"
else
    echo -e "${RED}❌ APK installation failed!${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Launching Expo app...${NC}"
adb shell am start -n "$PACKAGE_NAME/.MainActivity"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Expo app launched successfully!${NC}"
    echo -e "${BLUE}📱 The app should now be running on your device/emulator${NC}"
else
    echo -e "${RED}❌ Failed to launch app!${NC}"
    echo -e "${YELLOW}💡 You can manually launch the app from the device${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Useful commands:${NC}"
echo -e "${YELLOW}  • View logs: adb logcat | grep '$PACKAGE_NAME'${NC}"
echo -e "${YELLOW}  • Stop app: adb shell am force-stop $PACKAGE_NAME${NC}"
echo -e "${YELLOW}  • Uninstall: adb uninstall $PACKAGE_NAME${NC}"

echo -e "${GREEN}🎉 Done!${NC}"
