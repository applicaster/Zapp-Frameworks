const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "CoolaData",
  description:
    "CoolaData Analytics provider",
  cover_image:
    "",
  type: "analytics",
  identifier: "CoolaData-iOS",
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
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-cooladata@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "app_key",
    tooltip_text: "Application Key"
  },
  {
    type: "text",
    key: "video_start_event_name",
    tooltip_text: "Video Start Event Name"
  },
  {
    type: "text",
    key: "watch_preroll_event_name",
    tooltip_text: "Watch Preroll Event Name"
  },
  {
    type: "text",
    key: "watch_midroll_event_name",
    tooltip_text: "Watch Midroll Event Name"
  },
  {
    type: "text",
    key: "preroll_opportunity_event_name",
    tooltip_text: "Preroll Opportunity Event Name"
  },
  {
    type: "text",
    key: "midroll_opportunity_event_name",
    tooltip_text: "Midroll Opportunity Event Name"
  },
  {
    type: "text",
    key: "video_reach_event_name",
    tooltip_text: "Video Reach Event Name"
  },
  {
    type: "text",
    key: "video_complete_event_name",
    tooltip_text: "Video Complete Event Name"
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
  ios_for_quickbrick: "2.0.0-Dev",
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginCoolaData:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-cooladata/apple/ZappAnalyticsPluginCoolaData.podspec'",
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderCoolaData",
  modules: ["ZappAnalyticsPluginCoolaData"]
};

const api = {
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];

const targets = {
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
