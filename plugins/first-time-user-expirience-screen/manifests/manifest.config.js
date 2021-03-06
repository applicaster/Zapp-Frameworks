const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/first-time-user-expirience-screen",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "First time user experience screen",
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
      label: "Background color",
      initial_value: "#161b29ff",
    },
    {
      key: "indicator_color",
      type: "color_picker",
      label: "Activity indicator color",
      initial_value: "#ffffffff",
    },
    {
      key: "bottom_bar_background_color",
      type: "color_picker",
      label: "Bottom bar background color",
      initial_value: "#161b29ff",
    },
    {
      key: "bottom_bar_height",
      type: "number_input",
      label_tooltip: "Bottom bar tab",
      initial_value: 68,
    },

    {
      key: "is_top_button_hidden",
      type: "checkbox",
      label: "Top button hidden",
      default: "0",
      tooltip_text: "Make top button hidden",
    },
    {
      key: "is_bar_back_button_hidden",
      type: "checkbox",
      label: "Back button hidden",
      default: "0",
      tooltip_text: "Make bottom bar back button hidden",
    },
    {
      key: "is_bar_next_button_hidden",
      type: "checkbox",
      label: "Next/Close bottom bar hidden",
      default: "0",
      tooltip_text: "Make close/back bottom bar hidden",
    },
    {
      key: "is_bar_login_button_hidden",
      type: "checkbox",
      label: "Login bottom bar hidden",
      default: "0",
      tooltip_text: "Make login bottom bar hidden",
    },

    {
      key: "navigation_bar_button_height",
      type: "number_input",
      label_tooltip: "Navigation bottom bar button height",
      initial_value: 40,
    },
    {
      key: "navigation_bar_button_radius",
      type: "number_input",
      label_tooltip: "Navigation Bottom bar button radius",
      initial_value: 5,
    },
    {
      key: "navigation_bar_button_border_size",
      type: "number_input",
      label_tooltip: "Navigation Bottom bar button border size",
      initial_value: 2,
    },
    {
      key: "navigation_bar_button_border_color",
      type: "color_picker",
      label: "Navigation Bottom bar Button bortder color",
      initial_value: "#00000000",
    },
    {
      key: "navigation_bar_button_border_color_disabled",
      type: "color_picker",
      label: "Navigation Bottom bar Button bortder color disabled",
      initial_value: "#00000000",
    },
    {
      key: "navigation_bar_button_background_color",
      type: "color_picker",
      label: "Navigation Bottom bar Button background color",
      initial_value: "#00000000",
    },
    {
      key: "navigation_bar_button_background_color_disabled",
      type: "color_picker",
      label: "Navigation Bottom bar Button background color disabled",
      initial_value: "#00000000",
    },
    {
      key: "navigation_bar_button_font_ios",
      type: "ios_font_selector",
      label: "iOS Navigation bottom bar Button font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "navigation_bar_button_font_android",
      type: "android_font_selector",
      label: "Android Navigation Bottom Bar Button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "navigation_bar_button_font_size",
      type: "number_input",
      label: "Navigation Bottom Bar Button font size",
      initial_value: 15,
    },
    {
      key: "navigation_bar_button_font_color",
      type: "color_picker",
      label: "Navigation Bottom Bar Button font color",
      initial_value: "#FFFFFFFF",
    },
    {
      key: "navigation_bar_button_font_color_disabled",
      type: "color_picker",
      label: "Navigation Bottom Bar Button font color disabled",
      initial_value: "#FFFFFFFF",
    },

    {
      key: "sign_in_bar_button_height",
      type: "number_input",
      label_tooltip: "Sign In bottom bar button height",
      initial_value: 40,
    },
    {
      key: "sign_in_bar_button_radius",
      type: "number_input",
      label_tooltip: "Sign In Bottom bar button radius",
      initial_value: 5,
    },
    {
      key: "sign_in_bar_button_border_size",
      type: "number_input",
      label_tooltip: "Sign In Bottom bar button border size",
      initial_value: 2,
    },
    {
      key: "sign_in_bar_button_border_color",
      type: "color_picker",
      label: "Sign In Bottom bar Button bortder color",
      initial_value: "#00000000",
    },
    {
      key: "sign_in_bar_button_border_color_disabled",
      type: "color_picker",
      label: "Sign In Bottom bar Button bortder color disabled",
      initial_value: "#00000000",
    },
    {
      key: "sign_in_bar_button_background_color",
      type: "color_picker",
      label: "Sign In Bottom bar Button background color",
      initial_value: "#00000000",
    },
    {
      key: "sign_in_bar_button_background_color_disabled",
      type: "color_picker",
      label: "Sign In Bottom bar Button background color disabled",
      initial_value: "#00000000",
    },
    {
      key: "sign_in_bar_button_font_ios",
      type: "ios_font_selector",
      label: "iOS Sign In bottom bar Button font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "sign_in_bar_button_font_android",
      type: "android_font_selector",
      label: "Android Sign In Bottom Bar Button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "sign_in_bar_button_font_size",
      type: "number_input",
      label: "Navigation Sign In Bar Button font size",
      initial_value: 15,
    },
    {
      key: "sign_in_bar_button_font_color",
      type: "color_picker",
      label: "Navigation Sign In Bar Button font color",
      initial_value: "#FFFFFFFF",
    },
    {
      key: "sign_in_bar_button_font_color_disabled",
      type: "color_picker",
      label: "Navigation Sign In Bar Button font color disabled",
      initial_value: "#FFFFFFFF",
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
      placeholder: "W 120 x H 120",
      conditional_fields: [
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
      placeholder: "W 120 x H 120",
      conditional_fields: [
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
          key: "flow_version",
          type: "number_input",
          tooltip_text:
            "Increment version number to +1 to force load FTUE on start again",
          label: "Version of the screen",
          initial_value: 1,
        },
        {
          type: "switch",
          key: "show_hook_once",
          tooltip_text:
            "Define if hook should be presented on time or each time screen will open",
          initial_value: true,
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
