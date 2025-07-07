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

# Remove the tarball if it exists
TARBALL="scribeup-react-native-scribeup-${PACKAGE_VERSION}.tgz"
if [ -f "$TARBALL" ]; then
  echo "Removing existing tarball: $TARBALL"
  rm "$TARBALL"
fi

npm pack

# Update package.json files in example projects to reference the new tarball
echo "Updating package.json files to reference tarball: $TARBALL"

# Update example/package.json
if [ -f "example/package.json" ]; then
  echo "Updating example/package.json..."
  # Use sed to replace the tarball reference
  sed -i.bak "s|file:../scribeup-react-native-scribeup-[0-9.]*\.tgz|file:../$TARBALL|g" example/package.json
  rm example/package.json.bak 2>/dev/null || true
fi


cd example
rm package-lock.json || true
rm -rf node_modules
npm i

if [ "$PLATFORM" = "ios" ]; then
  echo "Starting iOS development server..."
  ./node_modules/.bin/concurrently "npx react-native start --reset-cache" "cd ios && pod install && cd ../ && npm run ios"
elif [ "$PLATFORM" = "android" ]; then
  echo "Starting Android development server..."
  ./node_modules/.bin/concurrently "npx react-native start --reset-cache" "npm run android"
fi