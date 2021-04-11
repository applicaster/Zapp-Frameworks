const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/quick-brick-copa-america-stats",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "CopaAmerica Stats plugin for QuickBrick",
  description:
    "This plugin allow to fetch statistics for CopaAmerica",
  type: "general",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5ae06cef8fba0f00084bd3c6",
  ],
  min_zapp_sdk: "4.1.0-Dev",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  npm_dependencies: [],
  identifier: "quick_brick_copa_america_stats",
  targets: ["mobile"],
  ui_frameworks: ["native", "quickbrick"],
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
    },
    {
      key: "image_base_url",
      label: "Image Base URL",
      placeholder: "Enter image base url",
      tooltip_text: "URL where the plugin get the images",
      type: "text"
    },
    {
      key: "show_team",
      label: "Show Team",
      placeholder: "",
      tooltip_text: "Show Players in Team screen",
      type: "checkbox"
    },
    {
      key: "number_of_matches",
      label: "Number of matches",
      placeholder: "",
      tooltip_text: "Change how many matches we show in the carrousel",
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
    npm_dependencies: [`@applicaster/quick-brick-copa-america-stats@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos_for_quickbrick: "4.1.0-Dev",
  ios_for_quickbrick: "4.1.0-Dev"
};

const extra_dependencies_apple = {
  CopaAmericaStats:
    ":path => './node_modules/@applicaster/quick-brick-copa-america-stats/apple/CopaAmericaStats.podspec'",
};
const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "CopaAmericaStats",
  modules: ["CopaAmericaStats"],
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
