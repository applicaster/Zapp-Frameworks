const npmDependency = "@applicaster/zapp-generic-chromecast";

const baseManifest = {
  general: {},
  data: {},
  styles: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Chromecast (QB)",
  description:
    "A react native plugin that allows you to add chromecast support to a QuickBrick based project",
  type: "general",
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
    "572a0a65373163000b000000",
  ],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: false,
  custom_configuration_fields: [
    {
      type: "text",
      key: "chromecast_app_id",
      tooltip_text: "Chromecast application ID",
    },
    {
      type: "hidden",
      key: "plist.array.NSBonjourServices",
      initial_value: "_[chromecast_app_id]._googlecast._tcp, _googlecast._tcp"
    },
  ],
  ui_frameworks: ["quickbrick"],
  identifier: "chromecast_qb",
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    dependency_name: npmDependency,
    dependency_version: version,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    api: api[platform],
    npm_dependencies: [`${npmDependency}@${version}`],
    targets: ["mobile"],
  };

  if (platform.includes("android")) {
    manifest.project_dependencies = [
      {
        "react-native-google-cast": `./node_modules/${npmDependency}/android`,
      },
    ];

    manifest.extra_dependencies = [];
  }

  if (platform.includes("ios")) {
    manifest.extra_dependencies = [
      {
        ZappChromecast: `:path => './node_modules/${npmDependency}/apple/ZappChromecast.podspec'`,
      },
    ];
  }

  return manifest;
}
const min_zapp_sdk = {
  android: "20.0.0",
  tvos_for_quickbrick: "2.0.2-Dev",
  ios_for_quickbrick: "2.0.2-Dev",
  android_for_quickbrick: "1.0.0-Dev",
};

const api_apple = {
  class_name: "ChromecastAdapter",
  modules: ["ZappChromecast"],
  plist: {
    NSLocalNetworkUsageDescription: "App uses the local network to discover Cast-enabled devices on your WiFi network.",
  },
};
const api_android = {
  require_startup_exectution: false,
  class_name: "com.applicaster.chromecast.ChromeCastPlugin",
  react_packages: ["com.reactnative.googlecast.GoogleCastPackage"],
  roguard_rules: "-keep public class com.reactnative.googlecast.** {*;}",
};
const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  android: api_android,
  android_for_quickbrick: api_android,
};

module.exports = createManifest;
