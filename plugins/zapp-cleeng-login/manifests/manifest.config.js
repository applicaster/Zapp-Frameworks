const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  dependency_name: "@applicaster/zapp-cleeng-login",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Quick Brick Cleeng login",
  description: "Quick Brick Cleeng login",
  type: "login",
  react_native: true,
  screen: true,
  identifier: "zapp-cleeng-login",
  ui_builder_support: true,
  whitelisted_account_ids: [""],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  preload: true,
  custom_configuration_fields: [
    {
      type: "text",
      key: "publisherId",
      label: "Cleeng Publisher ID",
      default: "",
    },
    {
      type: "text",
      key: "base_URL_api",
      label: "Base URL",
      default: "https://applicaster-cleeng-sso.herokuapp.com/",
    },
    {
      type: "text",
      key: "login_api_endpoint",
      label: "Login End Point",
      default: "login",
    },
    {
      type: "text",
      key: "signin_api_endpoint",
      label: "Create Account End Point",
      default: "register",
    },
    {
      type: "text",
      key: "password_reset_api_endpoint",
      label: "Password Reset End Point",
      default: "passwordReset",
    },
    {
      group: true,
      label: "Debug",
      tooltip: "For development purposes",
      folded: true,
      fields: [
        {
          type: "tag_select",
          key: "force_authentication_on_all",
          tooltip_text:
            "If On, all video entries will be marked as required login",
          options: [
            {
              text: "On",
              value: "on",
            },
            {
              text: "Off",
              value: "off",
            },
          ],
          initial_value: "off",
        },
      ],
    },
  ],
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
  ui_frameworks: ["quickbrick"],
};

const stylesMobile = {
  fields: [
    {
      key: "background_color",
      type: "color_picker",
      label: "Background font color",
      initial_value: "#161b29ff",
    },
    {
      key: "title_font_ios",
      type: "ios_font_selector",
      label: "iOS title font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "title_font_android",
      type: "android_font_selector",
      label: "Android title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "title_font_size",
      type: "number_input",
      label: "Title font size",
      initial_value: 15,
    },
    {
      key: "title_font_color",
      type: "color_picker",
      label: "Title font color",
      initial_value: "#ffffffff",
    },
    {
      key: "back_button_font_ios",
      type: "ios_font_selector",
      label: "iOS back button font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "back_button_font_android",
      type: "android_font_selector",
      label: "Android back button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "back_button_font_size",
      type: "number_input",
      label: "Back button font size",
      initial_value: 15,
    },
    {
      key: "back_button_font_color",
      type: "color_picker",
      label: "Back button font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_font_ios",
      type: "ios_font_selector",
      label: "iOS input fields title font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "fields_font_android",
      type: "android_font_selector",
      label: "Android input fields title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "fields_font_size",
      type: "number_input",
      label: "Input fields title font size",
      initial_value: 13,
    },
    {
      key: "fields_font_color",
      type: "color_picker",
      label: "Input fields font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_placeholder_font_color",
      type: "color_picker",
      label: "Input fields placeholder font color",
      initial_value: "#ffffffff",
    },
    {
      key: "fields_separator_color",
      type: "color_picker",
      label: "Input fields separator color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "forgot_password_font_ios",
      type: "ios_font_selector",
      label: "iOS forgot password font",
      initial_value: "Helvetica",
    },
    {
      key: "forgot_password_font_android",
      type: "android_font_selector",
      label: "Android forgot password font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "forgot_password_font_size",
      type: "number_input",
      label: "Forgot password font size",
      initial_value: 11,
    },
    {
      key: "forgot_password_font_color",
      type: "color_picker",
      label: "Forgot password font color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "action_button_background_color",
      type: "color_picker",
      label: "iOS action button background color",
      initial_value: "#f1af13ff",
    },
    {
      key: "action_button_font_ios",
      type: "ios_font_selector",
      label: "iOS action button font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "action_button_font_android",
      type: "android_font_selector",
      label: "Android action button font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "action_button_font_size",
      type: "number_input",
      label: "Action button font size",
      initial_value: 15,
    },
    {
      key: "action_button_font_color",
      type: "color_picker",
      label: "Action button font Color",
      initial_value: "#ffffffff",
    },
    {
      key: "create_account_link_font_ios",
      type: "ios_font_selector",
      label: "iOS Create account link font",
      initial_value: "Helvetica",
    },
    {
      key: "create_account_link_font_android",
      type: "android_font_selector",
      label: "Android Create account link font",
      initial_value: "Roboto-Regular",
    },
    {
      key: "create_account_link_font_size",
      type: "number_input",
      label: "Create account link font size",
      initial_value: 11,
    },
    {
      key: "create_account_link_font_color",
      type: "color_picker",
      label: "Create account link font color",
      initial_value: "#a9a9a9ff",
    },
    {
      key: "logout_title_font_ios",
      type: "ios_font_selector",
      label: "Logout iOS title font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "logout_title_font_android",
      type: "android_font_selector",
      label: "Logout Android title font",
      initial_value: "Roboto-Bold",
    },
    {
      key: "logout_title_font_size",
      type: "number_input",
      label: "Logout title font size",
      initial_value: 15,
    },
    {
      key: "logout_title_font_color",
      type: "color_picker",
      label: "Logout title font color",
      initial_value: "#ffffffff",
    },
  ],
};

const androidPlatforms = [
  "android",
  "android_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
];

const webPlatforms = ["samsung_tv", "lg_tv"];

const applePlatforms = ["ios", "ios_for_quickbrick", "tvos_for_quickbrick"];

const tvPlatforms = [
  "tvos_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
  "samsung_tv",
];

const api = {
  default: {},
  web: {
    excludedNodeModules: [
      "react-native-dropdownalert",
      "react-native-keyboard-aware-scroll-view",
    ],
  },
  android: {
    class_name: "com.applicaster.reactnative.plugins.APReactNativeAdapter",
    react_packages: ["com.cmcewen.blurview.BlurViewPackage"],
    proguard_rules:
      "-keep public class * extends com.facebook.react.ReactPackage {*;} -keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;} -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; } -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }",
  },
};

const project_dependencies = {
  default: [],
  android: [
    {
      "react-native-community_blur":
        "node_modules/@react-native-community/blur/android",
    },
  ],
};

const extra_dependencies = {
  apple: [
    {
      "react-native-blur":
        ":path => 'node_modules/@react-native-community/blur/react-native-blur.podspec'",
    },
  ],
  default: [],
};

const npm_dependencies = {
  default: ["@react-native-community/blur@3.4.1"],
  web: [],
};

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
    api: withFallback(api, basePlatform),
    project_dependencies: withFallback(project_dependencies, basePlatform),
    extra_dependencies: withFallback(extra_dependencies, basePlatform),
    min_zapp_sdk: withFallback(min_zapp_sdk, platform),
    npm_dependencies: withFallback(npm_dependencies, basePlatform),
    styles: isTV ? stylesTv : stylesMobile,
    localizations: isTV ? Localizations.tv : Localizations.mobile,
    targets: isTV ? ["tv"] : ["mobile"],
  };
}
module.exports = createManifest;
