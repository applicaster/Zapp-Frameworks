const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Comscore",
  description: "Comscore Analytics provider",
  cover_image: "",
  type: "analytics",
  identifier: "comscore_ios",
  screen: false,
  react_native: true, // needed for android rake
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
    identifier: identifier[platform],
    project_dependencies: project_dependencies[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-comscore@${version}`],
    targets: targets[platform],
    dependency_repository_url: dependency_repository_url[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "customer_c2"
  },
  {
    type: "text",
    key: "app_name"
  },
  {
    type: "text",
    key: "publisher_secret"
  },
  {
    type: "text",
    key: "ns_site"
  },
  {
    type: "text",
    key: "stream_sense"
  },
  {
    type: "text",
    key: "ns_st_pu",
    tooltip_text: "publisher name"
  },
  {
    type: "text",
    key: "c3",
    tooltip_text: "c3 value"
  }
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_apple,
};

const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_quickbrick,
  android_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  android_for_quickbrick: "2.0.0",
  ios_for_quickbrick: "2.0.2-Dev",
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginComScore:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-comscore/apple/ZappAnalyticsPluginComScore.podspec'",
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APAnalyticsProviderComScore",
  modules: ["ZappAnalyticsPluginComScore"]
};

const api_android = {
  require_startup_execution: false,
  class_name: "com.applicaster.analytics.comscore.ComScoreAgent"
};

const api = {
  ios_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];

const targets = {
  ios_for_quickbrick: mobileTarget,
  android_for_quickbrick: mobileTarget,
};

const identifier = {
    ios_for_quickbrick: "comscore_ios",
    android_for_quickbrick: "comscore"
};

const android_project_dependencies = [
  {
    "zapp-analytics-plugin-comscore":
      "node_modules/@applicaster/zapp-analytics-plugin-comscore/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: android_project_dependencies,
};

const dependency_repository_url = {
  android_for_quickbrick: [ { "url": "https://comscore.bintray.com/Analytics" } ],
};

module.exports = createManifest;
