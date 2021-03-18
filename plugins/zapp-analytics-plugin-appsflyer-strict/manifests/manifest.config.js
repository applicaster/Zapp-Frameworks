const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "AppsFlyer Strict Mode",
  description: "AppsFlyer Analytics provider with strict mode SDK to completely remove IDFA collection functionality and AdSupport framework dependencies",
  cover_image: "",
  type: "analytics",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: false,
  custom_configuration_fields: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    identifier: identifier[platform],
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-appsflyer@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
    react_native: platform.includes("android") // needed for Android rake to work properly
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "appsflyer_key"
  },
  {
    type: "text",
    key: "apple_app_id"
  },
  {
    type: "text",
    key: "plist.SKAdNetworkItems",
    label: "SKAdNetworks",
    initial_value: "",
    tooltip_text: "List of supported SKAdNetworks separated by comma"
  },
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
};

const identifier = {
  ios: "AppsFlyer-Strict",
  ios_for_quickbrick: "AppsFlyer-Strict",
};

const ui_frameworks_native = ["native"];
const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios: ui_frameworks_native,
  ios_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  ios: "16.0.0",
  ios_for_quickbrick: "4.1.0-Dev",
};

const extra_dependencies_apple = [
  {
    "ZappAnalyticsPluginAppsFlyer/Strict":
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-appsflyer/apple/ZappAnalyticsPluginAppsFlyer.podspec'",
  },
];

const extra_dependencies_apple_legacy = [
  {
    "ZappAnalyticsPluginAppsFlyer/LegacyStrict":
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-appsflyer/apple/ZappAnalyticsPluginAppsFlyer.podspec'",
  },
];

const extra_dependencies = {
  ios: extra_dependencies_apple_legacy,
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderAppsFlyer",
  modules: ["ZappAnalyticsPluginAppsFlyer"]
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
