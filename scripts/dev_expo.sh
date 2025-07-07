set -e

# Default to iOS if no platform specified
PLATFORM="ios"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --ios)
      PLATFORM="ios"
      shift
      ;;
    --android)
      PLATFORM="android"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: npm run dev [--ios|--android]"
      exit 1
      ;;
  esac
done

PACKAGE_VERSION=$(node -p -e "require('./package.json').version")
echo "Package version: $PACKAGE_VERSION"

# Clear watchman to prevent recrawl warnings
echo "Clearing watchman cache..."
watchman watch-del "$(pwd)" 2>/dev/null || true
watchman watch-project "$(pwd)" 2>/dev/null || true

# Remove the tarball if it exists
TARBALL="scribeup-react-native-scribeup-${PACKAGE_VERSION}.tgz"
if [ -f "$TARBALL" ]; then
  echo "Removing existing tarball: $TARBALL"
  rm "$TARBALL"
fi

npm pack

# Update package.json file in example_expo project to reference the new tarball
echo "Updating package.json file to reference tarball: $TARBALL"

# Update example_expo/package.json
if [ -f "example_expo/package.json" ]; then
  echo "Updating example_expo/package.json..."
  # Use sed to replace the tarball reference
  sed -i.bak "s|file:../scribeup-react-native-scribeup-[0-9.]*\.tgz|file:../$TARBALL|g" example_expo/package.json
  rm example_expo/package.json.bak 2>/dev/null || true
fi

cd example_expo
rm package-lock.json || true
rm -rf node_modules

# Install all dependencies to ensure concurrently is available
echo "Installing all dependencies..."
npm i



if [ "$PLATFORM" = "ios" ]; then
  echo "Starting iOS development build..."
  ./node_modules/.bin/concurrently "npx expo start --reset-cache" "cd ios && pod install && cd ../ && npm run ios"
elif [ "$PLATFORM" = "android" ]; then
  echo "Starting Android development build..."
  ./node_modules/.bin/concurrently "npx expo start --reset-cache" "npm run android"
fi