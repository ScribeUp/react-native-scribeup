# ScribeUp React-Native SDK

Easily integrate the [ScribeUp](https://scribeup.io) subscription-manager experience in any React-Native application.
The package is a thin wrapper around the native [iOS](https://github.com/ScribeUp/scribeup-sdk-ios) and [Android](https://github.com/ScribeUp/scribeup-sdk-android) SDKs, providing a single cross-platform API.

---

## Table of Contents

1. [Installation](#installation)
   1. [Bare React-Native](#bare-react-native)
   2. [Expo Projects](#expo-projects)
2. [Quick Start](#quick-start)
3. [API Reference](#api-reference)
4. [Example Projects](#example-projects)
5. [Troubleshooting](#troubleshooting)
6. [Author](#author)
7. [License](#license)


## Installation

### Bare React-Native

```bash
npm install @scribeup/react-native-scribeup
```

The library supports autolinking on both platforms – no additional manual steps are required.

### Expo Projects

The SDK works in **development builds** (aka *Expo Dev Client*) and production builds generated with `eas build`.

```bash
expo install @scribeup/react-native-scribeup
```

After installing, create a development build (`eas build --profile development`) or a production build. The SDK cannot run in the standard Expo Go client because it contains custom native code.

---

## Quick Start

```tsx
// App.tsx
import React, { useState } from "react";
import { Button, SafeAreaView } from "react-native";
import ScribeUp from "@scribeup/react-native-scribeup";

export default function App() {
  const [visible, setVisible] = useState(false);

  const authenticatedUrl = "https://example.com/subscriptions?token=YOUR_JWT"; // Obtain from your backend (see docs)

  const handleExit = (data?: { message?: string; code?: number }) => {
    console.log("ScribeUp finished", data);
    setVisible(false);
  };

  return (
    <SafeAreaView style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <Button title="Manage my subscriptions" onPress={() => setVisible(true)} />

      {/* Mounting the component presents the native view controller / activity */}
      {visible && (
        <ScribeUp
          url={authenticatedUrl}
          productName="Subscription Manager" // optional text in the nav-bar
          onExit={handleExit} // called on success or error
        />
      )}
    </SafeAreaView>
  );
}
```

### Obtaining the `url` parameter

`url` must be a **fully authenticated URL** for managing the current user's subscriptions. Follow the steps in the [ScribeUp documentation](https://docs.scribeup.io) to create this URL on your backend.

---

## API Reference

ScribeUp is a *React component*. Mounting it immediately presents the native subscription-manager UI.

```
<ScribeUp
  url: string;              // required – authenticated manage-subscriptions URL
  productName?: string;     // optional – title shown in the navigation bar
  onExit?: (data?) => void; // optional – called when the user exits, with optional error
/>
```

### Exit Callback

`onExit` receives an object with two optional fields:

* `message` – descriptive error or informational message.
* `code` – numeric error code (0 on success, -1 on unknown error).

If both fields are undefined, the flow completed without errors.

---

## Example Projects

This repository contains two fully-working example apps:

* **`example/`** – a bare React-Native app.
* **`example_expo/`** – an Expo Router app using the dev-client.

You can run either example directly from the repository **root** using the convenience scripts below:

```bash
# ---------------------------
# Bare React-Native example
# ---------------------------

# iOS (default)
npm run dev

# Android
npm run dev -- --android

# ---------------------------
# Expo Router example
# ---------------------------

# iOS (default)
npm run expo

# Android
npm run expo -- --android
```

The first execution may take a while – the scripts:
1. Build a local tarball of the SDK.
2. Install it in the corresponding example app.
3. Install all native dependencies (including CocoaPods on iOS).
4. Start the Metro bundler and launch the app on the chosen simulator / emulator.

---

## Troubleshooting

1. **iOS: `The package '@scribeup/react-native-scribeup' doesn't seem to be linked`.**  
   Make sure you ran `pod install` after installing the package and rebuilt the app.
2. **Expo Go crashes when opening the manager.**  
   Expo Go does not include native code. Use a dev-client or production build.
3. Still stuck? Reach us at **dev@scribeup.io** or open an issue.

---

## Author

[ScribeUp](https://scribeup.io)

---

## License

ScribeUpSDK is released under the MIT license. See the [LICENSE](./LICENSE) file for details.
