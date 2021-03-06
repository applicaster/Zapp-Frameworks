const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Google Analytics Web Based API",
  description:
    "Provide Google Analytics as agent. Please use this plugin only if you are using quick brick",
  type: "analytics",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  ui_frameworks: ["quickbrick"],

  custom_configuration_fields: [
    {
      type: "checkbox",
      key: "enabled",
      default: 1,
      label: "Plugin enabled",
      label_tooltip: "Disable plugin if you do not want to use plugin",
    },
    {
      type: "text",
      key: "tracker_id",
      tooltip_text: "Tracker ID",
    },
    {
      type: "checkbox",
      key: "screen_views_enabled",
      tooltip_text: "Enable Screen Views",
      default: 0,
    },
    {
      type: "text",
      key: "user_id",
      tooltip_text:
        "Please do not populate the user id field unless your app is legally authorised (for further information, please reach support).",
    },
  ],
  npm_dependencies: [],
  identifier: "zapp_google_analytics",
  targets: ["mobile"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [
      `@applicaster/google-analytics-web-based-apple@${version}`,
    ],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos_for_quickbrick: "4.1.0-Dev",
  ios_for_quickbrick: "4.1.0-Dev",
};

const extra_dependencies_apple = {
  ZappGoogleAnalytics:
    ":path => './node_modules/@applicaster/google-analytics-web-based-apple/apple/ZappGoogleAnalytics.podspec'",
};
const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "GoogleAnalyticsPluginAdapter",
  modules: ["ZappGoogleAnalytics"],
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  tvos: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
