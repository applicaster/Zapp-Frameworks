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
      key: "token",
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
      label: "Image Base Url",
      placeholder: "Enter image base url",
      tooltip_text: "URL where the plugin get the images",
      type: "text"
    },
    {
      key: "ios_assets_bundle",
      type: "uploader",
      label: "iOS Design Assets",
      label_tooltip: "Please upload a zip file to provide the design assets for this plugin."
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
      label_tooltip: "Change how many matches we show in the carrousel",
      type: "text_input"
    },
    {
      type: "colorpicker",
      key: "navbar_bg_color",
      default: "#000000",
      tooltip_text: "Set Navbar bg color"
    },
    {
      type: "uploader",
      key: "navbar_logo_image_url",
      tooltip_text: "Upload NavBar logo image"
    },
    {
      type: "tag_select",
      key: "all_matches_item",
      tooltip_text: "Show All Matches Item",
      options: [
        {
          text: "As First Item",
          value: "first",
        },
        {
          text: "As Last Item",
          value: "last",
        },
        {
          text: "Hidden",
          value: "hidden",
        },
      ],
      initial_value: "first",
    },
    {
      type: "tag_select",
      key: "main_screen_type",
      tooltip_text: "Set the main screen type",
      options: [
        {
          text: "Default",
          value: "default",
        },
        {
          text: "Knockout phase",
          value: "knockout",
        },
      ],
      initial_value: "default",
    },
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
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/quick-brick-opta-stats@${version}`],
    targets: targets[platform],
    general,
  };
  return manifest;
}
const general = {
  fields: [
    // Type text_input
    {
      type: "hidden",
      key: "package_name",
      tooltip_text: "Opta Package Bridge Name",
      default: "OptaBridge",
    },
    // Type text_input
    {
      type: "hidden",
      key: "method_name",
      tooltip_text: "Default Method to Retreive",
      default: "showScreen",
    },
    // Type select
    {
      type: "hidden",
      key: "on_dismiss",
      label: "On Dismiss",
      label_tooltip: "On dismiss of native screen do this",
      rules: "conditional",
      options: [
        {
          text: "Navigate to screen",
          value: "screen",
        },
        {
          text: "Navigate to Home",
          value: "home",
        },
        {
          text: "Navigate back",
          value: "back",
        },
      ],
      initial_value: "back",
    },
    // Type screen_selector
    {
      type: "hidden",
      key: "to_screen",
      label: "Dismiss to Screen",
      tooltip_text: "Fallback or navigate to this screen after dismiss of native",
      conditional_fields: [
        {
          key: "styles/title_text_data_key",
          condition_value: "screen",
        },
      ],
    },
  ],
};

const min_zapp_sdk = {
  tvos_for_quickbrick: "4.1.0-Dev",
  ios_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "4.0.0"
};

const extra_dependencies_apple = {
  OptaStats:
    ":path => './node_modules/@applicaster/quick-brick-opta-stats/apple/OptaStats.podspec'",
};
const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const project_dependencies = {
  android_for_quickbrick: [
    {
      "quick-brick-opta-stats": "./quick_brick/node_modules/@applicaster/quick-brick-opta-stats/android",
    },
  ],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "OptaStats",
  modules: ["OptaStats"],
};

const api_android = {
    class_name: "com.applicaster.opta.statsscreenplugin.OptaStatsContract",
    react_packages: ["com.applicaster.opta.statsscreenplugin.reactnative.OptaPackage"],
};

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
  android_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
