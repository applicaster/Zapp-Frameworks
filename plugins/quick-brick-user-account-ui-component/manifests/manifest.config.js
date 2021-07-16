const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/quick-brick-user-account-ui-component",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "User Account",
  description: "User Account Component",
  type: "ui_component",
  react_native: true,
  identifier: "quick-brick-user-account-ui-component",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  preload: true,
  custom_configuration_fields: [],
};

const styles = {
  fields: [
    {
      group: true,
      label: "Login 1 Button Styles",
      tooltip: "These fields affect login 1 button styles",
      folded: true,
      fields: [
        {
          key: "button_radius",
          type: "number_input",
          label_tooltip: "toggle component button radius",
          initial_value: 5,
        },
        {
          key: "background_color",
          type: "color_picker_rgba",
          label: "Background color of the component",
          label_tooltip: "Background Color for the toggle component",
          initial_value: "rgba(66,74,87,1)",
        },
        {
          key: "background_underlay_color",
          type: "color_picker_rgba",
          label: "Background Underlay color of the component",
          label_tooltip: "Background Underlay Color for the toggle component",
          initial_value: "rgba(66,74,87,1)",
        },
        {
          key: "title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "title_underlay_color",
          type: "color_picker_rgba",
          label: "Title Underlay color of the component",
          label_tooltip: "Title Underlay Color for the toggle component",
          initial_value: "rgba(200,200,200,1)",
        },
        {
          key: "title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "15",
        },

        {
          key: "hint_title_color",
          type: "color_picker_rgba",
          label: "Hint title color of the component",
          label_tooltip: "Hint title Color for the toggle component",
          initial_value: "rgba(200,200,200,1)",
        },
        {
          key: "hint_title_underlay_color",
          type: "color_picker_rgba",
          label: "Hint title Underlay color of the component",
          label_tooltip: "Hint title Underlay Color for the toggle component",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "hint_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle hint title for Android",
          initial_value: "Roboto-Regular",
        },
        {
          key: "hint_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle hint title for iOS",
          initial_value: "HelveticaNeue",
        },
        {
          key: "hint_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle hint title",
          initial_value: "12",
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
      fields: [],
    },
  };
}
module.exports = createManifest;
