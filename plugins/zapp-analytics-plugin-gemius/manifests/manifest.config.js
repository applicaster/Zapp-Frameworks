const baseManifest = {
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Gemius Analytics",
  identifier: "gemius_analytics",
  description: "Gemius Analytics",
  type: "analytics",
  react_native: true,
  custom_configuration_fields: [
    {
      section: "configuration",
      type: "text",
      key: "gemius_identifier",
      tooltip_text: "Gemius Identifier",
      default: "",
    },
    {
      section: "configuration",
      type: "text_area",
      key: "blacklisted_events_list",
      initial_value: "",
      label: "Blacklisted Events",
      tooltip_text: "The key used to specify the blacklisted events, separated by comma",
    }
  ],
  whitelisted_account_ids: [],
  ui_builder_support: false,
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    min_zapp_sdk: min_zapp_sdk[platform],
    manifest_version: version,
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    targets: targets[platform],
    npm_dependencies: [
      `@applicaster/zapp-analytics-plugin-gemius@${version}`,
    ]
  };
  return manifest;
}

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  tvos_for_quickbrick: "4.1.0-Dev"
};

const extra_dependencies_apple = [
  {
    GemiusAnalytics:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-gemius/apple/GemiusAnalytics.podspec'",
  },
];

const extra_dependencies = {
  tvos_for_quickbrick: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "GemiusAnalytics",
  modules: ["GemiusAnalytics"]
};

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget
};

module.exports = createManifest;
