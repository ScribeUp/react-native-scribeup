# Android Build Scripts

This directory contains scripts to build and run Android APKs using CLI commands instead of React Native CLI or Expo CLI.

## 📱 Available App Types

- **React Native Example** (`example/`) - Standard React Native app
- **Expo Example** (`example_expo/`) - Expo-managed React Native app

## Prerequisites

1. **Android SDK**: Make sure you have Android SDK installed and `adb` in your PATH
2. **Java Development Kit (JDK)**: Required for Android development
3. **Node.js**: Required for React Native bundle generation
4. **Android Device/Emulator**: Connected device or running emulator

## Scripts

## 🔧 React Native Scripts

### 1. `build-android.sh`
Builds the Android APK using Gradle directly.

**Usage:**
```bash
# Build debug APK (default)
./scripts/build-android.sh

# Build release APK
./scripts/build-android.sh release
```

**What it does:**
- Installs npm dependencies
- Creates React Native bundle
- Cleans previous builds
- Builds APK using Gradle
- Reports APK location and size

### 2. `run-android.sh`
Installs and runs the APK on connected device/emulator.

**Usage:**
```bash
# Install and run debug APK (default)
./scripts/run-android.sh

# Install and run release APK
./scripts/run-android.sh release
```

**What it does:**
- Checks for connected devices/emulators
- **Auto-starts emulator if none found** (with user confirmation)
- Waits for emulator to fully boot
- Uninstalls previous version (if exists)
- Installs the APK
- Launches the app
- Provides useful debugging commands

### 3. `build-and-run-android.sh`
Combined script that builds and then runs the APK.

**Usage:**
```bash
# Build and run debug APK (default)
./scripts/build-and-run-android.sh

# Build and run release APK
./scripts/build-and-run-android.sh release
```

## 🚀 Expo Scripts

### 4. `build-expo-android.sh`
Builds the Expo Android APK using Gradle directly.

**Usage:**
```bash
# Build debug APK (default)
./scripts/build-expo-android.sh

# Build release APK
./scripts/build-expo-android.sh release
```

**What it does:**
- Installs npm dependencies
- Creates Expo bundle using `expo export:embed`
- Cleans previous builds
- Builds APK using Gradle
- Reports APK location and size

### 5. `run-expo-android.sh`
Installs and runs the Expo APK on connected device/emulator.

**Usage:**
```bash
# Install and run debug APK (default)
./scripts/run-expo-android.sh

# Install and run release APK
./scripts/run-expo-android.sh release
```

**What it does:**
- Checks for connected devices/emulators
- **Auto-starts emulator if none found** (with user confirmation)
- Waits for emulator to fully boot
- Uninstalls previous version (if exists)
- Installs the Expo APK
- Launches the app
- Provides useful debugging commands

### 6. `build-and-run-expo-android.sh`
Combined script that builds and then runs the Expo APK.

**Usage:**
```bash
# Build and run debug APK (default)
./scripts/build-and-run-expo-android.sh

# Build and run release APK
./scripts/build-and-run-expo-android.sh release
```

## Troubleshooting

### Common Issues

1. **`adb not found`**
   - Install Android SDK
   - Add Android SDK platform-tools to your PATH
   - On macOS with Homebrew: `brew install android-platform-tools`

2. **No devices found**
   - The script will automatically offer to start an available emulator
   - Or connect an Android device with USB debugging enabled
   - Or manually start an emulator: `emulator -avd <avd_name>`
   - List available AVDs: `emulator -list-avds`

3. **Build fails**
   - Make sure you're in the project root directory
   - Check that all dependencies are installed: `npm install`
   - Clean and rebuild: `cd example/android && ./gradlew clean`

4. **APK not found**
   - For React Native: Run `./scripts/build-android.sh` first
   - For Expo: Run `./scripts/build-expo-android.sh` first
   - Check the build output for errors

5. **Expo prebuild required**
   - If android directory is missing: `cd example_expo && npx expo prebuild`
   - This generates the native Android project files

### Useful Commands

```bash
# View app logs (React Native)
adb logcat | grep 'com.example'

# View app logs (Expo)
adb logcat | grep 'io.scribeup.exposcribeupsdkexample'

# Stop the app (React Native)
adb shell am force-stop com.example

# Stop the app (Expo)
adb shell am force-stop io.scribeup.exposcribeupsdkexample

# Uninstall the app (React Native)
adb uninstall com.example

# Uninstall the app (Expo)
adb uninstall io.scribeup.exposcribeupsdkexample

# List connected devices
adb devices

# Start an emulator
emulator -avd <avd_name>

# List available emulators
emulator -list-avds
```

## Build Output

### React Native APKs
- **Debug APK**: `example/android/app/build/outputs/apk/debug/app-debug.apk`
- **Release APK**: `example/android/app/build/outputs/apk/release/app-release.apk`

### Expo APKs
- **Debug APK**: `example_expo/android/app/build/outputs/apk/debug/app-debug.apk`
- **Release APK**: `example_expo/android/app/build/outputs/apk/release/app-release.apk`

## Notes

### React Native
- Scripts use the example app in the `example/` directory
- Package name: `com.example` (defined in `build.gradle`)
- Uses React Native CLI for bundling

### Expo
- Scripts use the Expo example app in the `example_expo/` directory
- Package name: `io.scribeup.exposcribeupsdkexample` (defined in `app.json` and `build.gradle`)
- Uses Expo CLI for bundling (`expo export:embed`)
- Requires `expo prebuild` to generate Android project if not present

### General
- Debug builds use the debug keystore for signing
- Release builds also use debug keystore (change this for production)
- Both apps support automatic emulator startup with user confirmation
