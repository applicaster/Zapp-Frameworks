const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/quick-brick-opta-stats",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Opta Statistics",
  description:
    "This plugin fetching statistics from Opta",
  type: "general",
  screen: true,
  react_native: true,
  ui_builder_support: true,
  ui_frameworks: ["quickbrick"],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
  ],
  npm_dependencies: [],
  identifier: "quick-brick-opta-stats",
  targets: ["mobile"],
  custom_configuration_fields: [
    {
      key: "api_token",
      label: "API Token",
      placeholder: "Enter token",
      tooltip_text: "Token to access the information provided by Opta",
      type: "text"
    },
    {
      key: "referer", 
      label: "Referer",
      placeholder: "Enter referer",
      tooltip_text: "Referer of the provider",
      type: "text"
    },
    {
      key: "competition_id",
      label: "Competition Id",
      placeholder: "Enter the competition id",
      tooltip_text: "Competition Id of the tournament",
      type: "text"
    },
    {
      key: "calendar_id",
      label: "Calendar Id",
      placeholder: "Enter calendar id",
      tooltip_text: "Calendar id of the tournament",
      type: "text"
    }
  ],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    dependency_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/quick-brick-opta-stats@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos_for_quickbrick: "4.1.0-Dev",
  ios_for_quickbrick: "4.1.0-Dev"
};

const extra_dependencies_apple = {
  OptaStats:
    ":path => './node_modules/@applicaster/quick-brick-opta-stats/apple/OptaStats.podspec'",
};
const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "OptaStats",
  modules: ["OptaStats"],
};

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
