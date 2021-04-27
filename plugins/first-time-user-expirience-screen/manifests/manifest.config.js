const R = require("ramda");

const baseManifest = {
  dependency_repository_url: [],
  dependency_name: "@applicaster/first-time-user-expirience-screen",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "First time user expirience screen",
  description: "Hook to present one time",
  type: "general",
  react_native: true,
  screen: true,
  identifier: "first-time-user-expirience-screen",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  preload: true,
  custom_configuration_fields: [],
  hooks: {
    fields: [
      {
        group: true,
        label: "Before Load",
        folded: true,
        fields: [
          {
            key: "preload_plugins",
            type: "preload_plugins_selector",
            label: "Select Plugins",
          },
        ],
      },
    ],
  },
};

const styles = {
  fields: [
    {
      key: "background_color",
      type: "color_picker",
      label: "Background font color",
      initial_value: "#161b29ff",
    },
  ],
};

const androidPlatforms = [
  "android_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
];

const webPlatforms = ["samsung_tv", "lg_tv"];

const applePlatforms = ["ios_for_quickbrick", "tvos_for_quickbrick"];

const tvPlatforms = [
  "tvos_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
  "samsung_tv",
];

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "0.1.0-alpha1",
  tvos_for_quickbrick: "4.1.0-Dev",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
  samsung_tv: "1.2.2",
  lg_tv: "1.0.0",
};

const isApple = R.includes(R.__, applePlatforms);
const iAndroid = R.includes(R.__, androidPlatforms);
const isWeb = R.includes(R.__, webPlatforms);

const withFallback = (obj, platform) => obj[platform] || obj["default"];

function createManifest({ version, platform }) {
  const basePlatform = R.cond([
    [isApple, R.always("apple")],
    [iAndroid, R.always("android")],
    [isWeb, R.always("web")],
  ])(platform);

  const isTV = R.includes(platform, tvPlatforms);

  return {
    ...baseManifest,
    platform,
    dependency_version: version,
    manifest_version: version,
    min_zapp_sdk: withFallback(min_zapp_sdk, platform),
    styles,
    targets: isTV ? ["tv"] : ["mobile"],
    general: {
      fields: [
        {
          key: "identifier",
          type: "text_input",
          disableField: true,
        },
        {
          type: "text_input",
          key: "transition_type",
          initial_value: "modal",
          disableField: true,
        },
        {
          type: "switch",
          key: "show_hook_once",
          tooltip_text:
            "Define if hook should be presented on time or each time screen will open",
          initial_value: true,
        },
        {
          key: "close_button",
          type: "uploader",
          label: "Close Button Asset",
          label_tooltip: "Please upload close button asset",
        },
        {
          key: "next_button",
          type: "uploader",
          label: "Close Button Asset",
          label_tooltip: "Please upload next button asset",
        },
        {
          key: "skip_button",
          type: "uploader",
          label: "Skip Button Asset",
          label_tooltip: "Please upload next button asset",
        },
        {
          type: "screen_selector",
          key: "screen_selector_1",
          tooltip_text: "First screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_2",
          tooltip_text: "Second screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_3",
          tooltip_text: "Third screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_4",
          tooltip_text: "Fourth screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_5",
          tooltip_text: "Fifth screen that will be presented",
        },
      ],
    },
  };
}
module.exports = createManifest;
