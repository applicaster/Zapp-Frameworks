const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "AppsFlyer",
  description: "AppsFlyer Analytics provider",
  cover_image: "",
  type: "analytics",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
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
    project_dependencies: project_dependencies[platform],
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
  }
];

const custom_configuration_fields_android = [
  {
    type: "text",
    key: "appsflyer_key"
  }
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
  android_tv_for_quickbrick: custom_configuration_fields_android,
};

const identifier = {
  ios: "AppsFlyer-iOS",
  ios_for_quickbrick: "AppsFlyer-iOS",
  android_for_quickbrick: "AppsFlyer",
  android_tv_for_quickbrick: "AppsFlyer",
};

const ui_frameworks_native = ["native"];
const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios: ui_frameworks_native,
  ios_for_quickbrick: ui_frameworks_quickbrick,
  android_for_quickbrick: ui_frameworks_quickbrick,
  android_tv_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  ios: "15.1.2-Dev",
  ios_for_quickbrick: "1.0.0",
  android_for_quickbrick: "1.0.0",
  android_tv_for_quickbrick: "1.0.0",
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginAppsFlyer:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-appsflyer/apple/ZappAnalyticsPluginAppsFlyer.podspec'",
  },
];

const extra_dependencies = {
  ios: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-analytics-plugin-appsflyer":
      "node_modules/@applicaster/zapp-analytics-plugin-appsflyer/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderAppsFlyer",
  modules: ["ZappAnalyticsPluginAppsFlyer"]
};

const api_android = {
  class_name: "com.applicaster.appsflyerplugin.AppsFlyerAnalyticsAgent"
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
    android_for_quickbrick: mobileTarget,
    android_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
