const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Adobe Analytics",
  description: "Adobe Analytics provider",
  cover_image: "",
  type: "analytics",
  identifier: "AdobeAnalyticsAgent",
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
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-adobe@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
    project_dependencies: project_dependencies[platform],
    react_native: platform.includes("android"), // needed for Android rake to work properly
  };
  return manifest;
}

// same as for Android
const custom_configuration_fields_apple = [
  {
    type: "text",
    label: "account id debug",
    key: "mobile_app_account_id"
  },
  {
    type: "text",
    label: "account id production",
    key: "mobile_app_account_id_production"
  }
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_apple,
  android_tv_for_quickbrick: custom_configuration_fields_apple,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_apple,
};

const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_quickbrick,
  android_for_quickbrick: ui_frameworks_quickbrick,
  android_tv_for_quickbrick: ui_frameworks_quickbrick,
  amazon_fire_tv_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "2.0.2-Dev",
  android_for_quickbrick: "2.0.0",
  android_tv_for_quickbrick: "2.0.0",
  amazon_fire_tv_for_quickbrick: "2.0.0",
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginAdobe:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-adobe/apple/ZappAnalyticsPluginAdobe.podspec'",
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-analytics-plugin-adobe":
      "node_modules/@applicaster/zapp-analytics-plugin-adobe/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderAdobe",
  modules: ["ZappAnalyticsPluginAdobe"]
};

const api_android = {
  class_name: "com.adobeagent.AdobeAnalyticsAgent",
};

const api = {
  ios_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  ios_for_quickbrick: mobileTarget,
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
