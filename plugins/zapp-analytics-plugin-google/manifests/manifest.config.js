const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Google Analytics",
  description: "Google Analytics provider",
  cover_image: "",
  type: "analytics",
  screen: false,
  react_native: true, // neeeded for Android rake
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "2.0.0",
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
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-google@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
    react_native: platform.includes("android"), // needed for Android rake to work properly
  };
  return manifest;
}

const custom_configuration_fields_android = [
  {
    key: "mobile_app_account_id",
    type: "text",
  },
  {
    key: "do_not_set_client_id",
    type: "checkbox",
    default: 0,
    tooltip_text:
      "Check this box if you want to prevent the Applicaster SDK from explicitly setting a client ID for the user. This prevents double-counting in cases where a plugin or another source may be setting a client ID as well.",
  },
  {
    key: "anonymize_user_ip",
    type: "checkbox",
    default: 0,
  },
  {
    key: "screen_views",
    type: "checkbox",
    default: 0,
  },
];

const custom_configuration_fields = {
  android_for_quickbrick: custom_configuration_fields_android,
  android_tv_for_quickbrick: custom_configuration_fields_android,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_android,
};

const identifier = {
  android_for_quickbrick: "google_analytics_android",
  android_tv_for_quickbrick: "google_analytics_android",
  amazon_fire_tv_for_quickbrick: "google_analytics_android",
};

const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  android_for_quickbrick: ui_frameworks_quickbrick,
  android_tv_for_quickbrick: ui_frameworks_quickbrick,
  amazon_fire_tv_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  android_for_quickbrick: "2.0.0",
  android_tv_for_quickbrick: "2.0.0",
  amazon_fire_tv_for_quickbrick: "2.0.0",
};

const project_dependencies_android = [
  {
    "zapp-analytics-plugin-google":
      "node_modules/@applicaster/zapp-analytics-plugin-google/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_android = {
  class_name: "com.applicaster.analytics.google.GoogleAnalyticsAgent",
};

const api = {
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
