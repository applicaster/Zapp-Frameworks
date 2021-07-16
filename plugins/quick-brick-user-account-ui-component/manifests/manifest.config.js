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
      key: "user_image_placeholder",
      type: "uploader",
      label: "Placeholder for the user image",
      placeholder: "Please, upload a file",
    },
    {
      group: true,
      label: "Login Button 1 Styles",
      tooltip: "These fields affect login 1 button styles",
      folded: true,
      fields: [
        {
          key: "button_1_radius",
          type: "number_input",
          label_tooltip: "Component button radius",
          initial_value: 16,
        },
        {
          key: "button_1_border",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 0,
        },
        {
          key: "button_1_border_underlay",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 0,
        },
        {
          key: "button_1_border_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border Color",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_1_border_underlay_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border underlay",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_1_background_color",
          type: "color_picker_rgba",
          label: "Background color of the component",
          label_tooltip: "Background Color for the toggle component",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "button_1_background_underlay_color",
          type: "color_picker_rgba",
          label: "Background Underlay color of the component",
          label_tooltip: "Background Underlay Color for the toggle component",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "button_1_title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "#161b29FF",
        },
        {
          key: "button_1_title_underlay_color",
          type: "color_picker_rgba",
          label: "Title Underlay color of the component",
          label_tooltip: "Title Underlay Color for the toggle component",
          initial_value: "#161b29FF",
        },
        {
          key: "button_1_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "button_1_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "button_1_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "12",
        },
      ],
    },
    {
      key: "login_button_2_enabled",
      label: "Switch to enable loggin button 2",
      type: "switch",
      initial_value: false,
    },
    {
      group: true,
      label: "Login Button 2 Styles",
      tooltip: "These fields affect login 2 button styles",
      folded: true,
      conditional_fields: [
        {
          condition_value: [false],
          key: "styles/login_button_2_enabled",
        },
      ],
      fields: [
        {
          key: "button_2_radius",
          type: "number_input",
          label_tooltip: "Component button radius",
          initial_value: 16,
        },
        {
          key: "button_2_border",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 1,
        },
        {
          key: "button_2_border_underlay",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 1,
        },
        {
          key: "button_2_border_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border Color",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "button_2_border_underlay_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border underlay color",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "button_2_background_color",
          type: "color_picker_rgba",
          label: "Background color of the component",
          label_tooltip: "Background Color for the toggle component",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_2_background_underlay_color",
          type: "color_picker_rgba",
          label: "Background Underlay color of the component",
          label_tooltip: "Background Underlay Color for the toggle component",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_2_title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "#161b29FF",
        },
        {
          key: "button_2_title_underlay_color",
          type: "color_picker_rgba",
          label: "Title Underlay color of the component",
          label_tooltip: "Title Underlay Color for the toggle component",
          initial_value: "#161b29FF",
        },
        {
          key: "button_2_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "button_2_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "button_2_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "12",
        },
      ],
    },
    {
      group: true,
      label: "Info View Styles",
      tooltip: "These fields affect inormation views",
      folded: true,
      fields: [
        {
          key: "info_label_title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "#ffffffff",
        },
        {
          key: "info_label_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "info_label_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "info_label_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "16",
        },
        {
          key: "info_label_description_title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "#161b29B3",
        },
        {
          key: "info_label_description_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "info_label_description_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "info_label_description_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "12",
        },
      ],
    },
    {
      group: true,
      label: "Logout Button Styles",
      tooltip: "These fields affect logout button styles",
      folded: true,
      fields: [
        {
          key: "button_logout_radius",
          type: "number_input",
          label_tooltip: "Component button radius",
          initial_value: 13,
        },
        {
          key: "button_logout_border",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 1,
        },
        {
          key: "button_logout_border_underlay",
          type: "number_input",
          label_tooltip: "Button Border",
          initial_value: 1,
        },
        {
          key: "button_logout_border_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border Color",
          initial_value: "#979797ff",
        },
        {
          key: "button_logout_border_underlay_color",
          type: "color_picker_rgba",
          label_tooltip: "Button Border underlay color",
          initial_value: "rgba(255,255,255,1)",
        },
        {
          key: "button_logout_background_color",
          type: "color_picker_rgba",
          label: "Background color of the component",
          label_tooltip: "Background Color for the toggle component",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_logout_background_underlay_color",
          type: "color_picker_rgba",
          label: "Background Underlay color of the component",
          label_tooltip: "Background Underlay Color for the toggle component",
          initial_value: "rgba(255,255,255,0)",
        },
        {
          key: "button_logout_title_color",
          type: "color_picker_rgba",
          label: "Title color of the component",
          label_tooltip: "Title Color for the toggle component",
          initial_value: "#979797FF",
        },
        {
          key: "button_logout_title_underlay_color",
          type: "color_picker_rgba",
          label: "Title Underlay color of the component",
          label_tooltip: "Title Underlay Color for the toggle component",
          initial_value: "#979797FF",
        },
        {
          key: "button_logout_title_text_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the toggle title for Android",
          initial_value: "Roboto-Bold",
        },
        {
          key: "button_logout_title_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the toggle title for iOS",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "button_logout_title_text_fontsize",
          type: "number_input",
          label_tooltip: "Font size toggle title",
          initial_value: "10",
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
