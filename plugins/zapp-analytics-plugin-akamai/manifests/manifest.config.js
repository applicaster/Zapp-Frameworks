const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Akamai",
  description:
    "Akamai Analytics provider",
  cover_image:
    "",
  type: "analytics",
  identifier: "akamai_ios",
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
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-akamai@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "vod_beacons"
  },
  {
    type: "text",
    key: "live_beacons"
  }
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
};

const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "2.0.2-Dev",
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginAkamai:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-akamai/apple/ZappAnalyticsPluginAkamai.podspec'",
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderAkamai",
  modules: ["ZappAnalyticsPluginAkamai"]
};

const api = {
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];

const targets = {
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
