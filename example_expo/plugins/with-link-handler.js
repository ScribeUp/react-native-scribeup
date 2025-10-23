// plugins/with-link-handler.js
// Expo config plugin to:
// 1) Add a Kotlin "trampoline" activity (LinkHandlerActivity) that forwards verified https:// links to MainActivity.
// 2) Inject an intent-filter for App Links on LinkHandlerActivity.
// 3) (Safety) Remove any https VIEW/BROWSABLE filters for the same host from MainActivity to avoid conflicts.
//
// Usage in app.json/app.config.*:
// {
//   "expo": {
//     "android": { "package": "io.scribeup.exposcribeupsdkexample" },
//     "plugins": ["./plugins/with-link-handler"]
//   }
// }
//
// Then:
//   npx expo prebuild --clean
//   npx expo run:android

const fs = require("fs");
const path = require("path");
const { withAndroidManifest, withDangerousMod } = require("@expo/config-plugins");

// ===== Customize if needed =====
const HOST = "scribeup.io";
// Use "/example_expo" to match all routes under it, or "/example_expo/open" for a single route
const PATH_PREFIX = "/example_expo/open";

// If true, remove any https VIEW/BROWSABLE filters for HOST from MainActivity to prevent conflicts.
const CLEAN_MAIN_ACTIVITY_HTTPS = true;
// =================================

function ensureLinkHandlerActivityInManifest(androidManifest) {
  const app = androidManifest.manifest.application?.[0];
  if (!app) throw new Error("AndroidManifest.xml missing <application> node");

  app.activity = app.activity || [];

  const already = app.activity.some(
    (a) => a.$?.["android:name"] === ".LinkHandlerActivity"
  );
  if (already) {
    // Ensure intent-filter exists/updated (idempotent)
    const act = app.activity.find((a) => a.$?.["android:name"] === ".LinkHandlerActivity");
    act["intent-filter"] = act["intent-filter"] || [];
    const hasFilter = act["intent-filter"].some((f) => filterMatchesHostAndPath(f, HOST, PATH_PREFIX));
    if (!hasFilter) {
      act["intent-filter"].push(makeIntentFilter(HOST, PATH_PREFIX));
    }
    return androidManifest;
  }

  app.activity.push({
    $: {
      "android:name": ".LinkHandlerActivity",
      "android:exported": "true",
      "android:noHistory": "true",
      "android:excludeFromRecents": "true",
      "android:launchMode": "singleTop",
      "android:theme": "@android:style/Theme.Translucent.NoTitleBar",
    },
    "intent-filter": [makeIntentFilter(HOST, PATH_PREFIX)],
  });

  return androidManifest;
}

function makeIntentFilter(host, pathPrefix) {
  return {
    $: { "android:autoVerify": "true" },
    action: [{ $: { "android:name": "android.intent.action.VIEW" } }],
    category: [
      { $: { "android:name": "android.intent.category.DEFAULT" } },
      { $: { "android:name": "android.intent.category.BROWSABLE" } },
    ],
    data: [
      { $: { "android:scheme": "https", "android:host": host } },
      { $: { "android:pathPrefix": pathPrefix } },
    ],
  };
}

function filterMatchesHostAndPath(filter, host, pathPrefix) {
  if (!filter?.data) return false;
  const schemeOk = filter.data.some((d) => d.$?.["android:scheme"] === "https");
  const hostOk = filter.data.some((d) => d.$?.["android:host"] === host);
  const pathOk = filter.data.some((d) => d.$?.["android:pathPrefix"] === pathPrefix);
  const hasView = (filter.action || []).some((a) => a.$?.["android:name"] === "android.intent.action.VIEW");
  const hasBrowsable = (filter.category || []).some((c) => c.$?.["android:name"] === "android.intent.category.BROWSABLE");
  return schemeOk && hostOk && pathOk && hasView && hasBrowsable;
}

function removeHttpsFromMainActivity(androidManifest, host) {
  const app = androidManifest.manifest.application?.[0];
  if (!app) return androidManifest;

  const activities = app.activity || [];
  const main = activities.find(
    (a) =>
      a.$?.["android:name"] === ".MainActivity" ||
      a.$?.["android:name"]?.endsWith(".MainActivity")
  );
  if (!main) return androidManifest;

  if (!main["intent-filter"]) return androidManifest;

  // Remove any https VIEW/BROWSABLE filters targeting HOST from MainActivity
  main["intent-filter"] = main["intent-filter"].filter((f) => {
    const hasView = (f.action || []).some((a) => a.$?.["android:name"] === "android.intent.action.VIEW");
    const hasBrowsable = (f.category || []).some((c) => c.$?.["android:name"] === "android.intent.category.BROWSABLE");
    const targetsHost =
      (f.data || []).some((d) => d.$?.["android:scheme"] === "https") &&
      (f.data || []).some((d) => d.$?.["android:host"] === host);

    // keep filter if it is NOT an https browsable filter for our host
    return !(hasView && hasBrowsable && targetsHost);
  });

  return androidManifest;
}

function writeKotlinTrampoline(projectRoot, packageName) {
  const pkgPath = packageName.replace(/\./g, "/");
  const javaDir = path.join(projectRoot, "android", "app", "src", "main", "java", pkgPath);
  fs.mkdirSync(javaDir, { recursive: true });

  const ktFile = path.join(javaDir, "LinkHandlerActivity.kt");
  if (fs.existsSync(ktFile)) return; // idempotent

  const contents = `package ${packageName}

import android.app.Activity
import android.os.Bundle

/**
 * Handles https://${HOST}${PATH_PREFIX} App Links and forwards them to MainActivity
 * without closing any Custom Tab that may be open.
 *
 * - No history / no recents
 * - Immediately finishes after starting MainActivity
 */
class LinkHandlerActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isTaskRoot()) {
            // App wasn't running: start MainActivity with the original VIEW intent (data/extras preserved)
            val mainIntent = intent
            mainIntent.setClass(this, MainActivity::class.java)
            startActivity(mainIntent)
            finish()
        } else {
            // App already running: just finish so user lands in current task; keeps Custom Tabs open
            finish()
        }
    }
}
`;
  fs.writeFileSync(ktFile, contents);
}

const withLinkHandler = (config) => {
  // 1) Write the Kotlin trampoline (exact behavior as your pure-Android version)
  config = withDangerousMod(config, [
    "android",
    (c) => {
      const pkg = c.android?.package;
      if (!pkg) {
        throw new Error("android.package is required in app.json/app.config.* to place LinkHandlerActivity.kt");
      }
      writeKotlinTrampoline(c.modRequest.projectRoot, pkg);
      return c;
    },
  ]);

  // 2) Inject LinkHandlerActivity + App Link filter; optionally remove MainActivity https filters for HOST
  config = withAndroidManifest(config, (c) => {
    c.modResults = ensureLinkHandlerActivityInManifest(c.modResults);
    if (CLEAN_MAIN_ACTIVITY_HTTPS) {
      c.modResults = removeHttpsFromMainActivity(c.modResults, HOST);
    }
    return c;
  });

  return config;
};

module.exports = withLinkHandler;
module.exports.HOST = HOST;
module.exports.PATH_PREFIX = PATH_PREFIX;
module.exports.CLEAN_MAIN_ACTIVITY_HTTPS = CLEAN_MAIN_ACTIVITY_HTTPS;
