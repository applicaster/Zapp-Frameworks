const R = require("ramda");
const Localizations = require("./localizations.config");

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
    {
      key: "indicator_color",
      type: "color_picker",
      label: "Activity indicator color",
      initial_value: "#ffffffff",
    },
    {
      type: "tag_select",
      key: "top_button_type",
      tooltip_text: "Select style of top button",
      options: [
        {
          text: "Image",
          value: "image",
        },
        {
          text: "Text",
          value: "text",
        },
      ],
      initial_value: "text",
    },
    {
      key: "top_button_radius",
      type: "number_input",
      label_tooltip: "Top Button radius",
      initial_value: 5,
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_border_size",
      type: "number_input",
      label_tooltip: "Top Button border siz",
      initial_value: 2,
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_border_color",
      type: "color_picker",
      label: "Top Button bortder color",
      initial_value: "#00000000",
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_background_color",
      type: "color_picker",
      label: "Top Button background color",
      initial_value: "#00000000",
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_font_ios",
      type: "ios_font_selector",
      label: "iOS next button font",
      initial_value: "Helvetica-Bold",
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_font_android",
      type: "android_font_selector",
      label: "Android next button font",
      initial_value: "Roboto-Bold",
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_font_size",
      type: "number_input",
      label: "Next button font size",
      initial_value: 15,
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_font_color",
      type: "color_picker",
      label: "Top Button font color",
      initial_value: "#FFFFFFFF",
      conditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "text",
        },
      ],
    },
    {
      key: "top_button_image_next",
      type: "uploader",
      label: "Next Button Image",
      label_tooltip: "Top button image next. Dimension 44 x44.",
      placeholder: "W 88 x H 88",
      onditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "image",
        },
      ],
    },
    {
      key: "top_button_image_close",
      type: "uploader",
      label: "Close Button Image",
      label_tooltip: "Close button image next. Dimension 44 x44.",
      placeholder: "W 88 x H 88",
      onditional_fields: [
        {
          key: "styles/top_button_type",
          condition_value: "image",
        },
      ],
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
    localizations: isTV ? Localizations.tv : Localizations.mobile,
    general: {
      fields: [
        {
          key: "identifier",
          type: "text_input",
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
          type: "switch",
          key: "present_on_each_new_version",
          label: "Present component on each new application version",
          tooltip_text: "Present component on each new application version",
          initial_value: false,
        },
        {
          type: "screen_selector",
          key: "screen_selector_1",
          label: "Screen 1",
          tooltip_text: "First screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_2",
          label: "Screen 2",
          tooltip_text: "Second screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_3",
          label: "Screen 3",
          tooltip_text: "Third screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_4",
          label: "Screen 4",
          tooltip_text: "Fourth screen that will be presented",
        },
        {
          type: "screen_selector",
          key: "screen_selector_5",
          label: "Screen 5",
          tooltip_text: "Fifth screen that will be presented",
        },
      ],
    },
  };
}
module.exports = createManifest;
