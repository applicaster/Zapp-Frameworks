const R = require("ramda");
const baseManifest = {
  dependency_repository_url: [],
  dependency_name: "@applicaster/zapp_login_plugin_oauth_2_0",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Oauth 2.0 Login",
  description: "Oauth 2.0 Login",
  type: "login",
  screen: true,
  react_native: true,
  identifier: "zapp_login_plugin_oauth_2_0",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  custom_configuration_fields: [
    {
      type: "text",
      key: "clientId",
      tooltip_text: "REQUIRED: your client id on the auth server",
      default: "",
    },
    {
      type: "text",
      key: "redirectUrl",
      tooltip_text:
        "REQUIRED: the url that links back to your app with the auth code",
      default: "",
    },
    {
      type: "text",
      key: "authorizationEndpoint",
      tooltip_text:
        "REQUIRED: fully formed url to the OAuth authorization endpoint",
      default: "",
    },
    {
      type: "text",
      key: "tokenEndpoint",
      tooltip_text:
        "REQUIRED: fully formed url to the OAuth token exchange endpoint",
      default: "",
    },
    {
      type: "text",
      key: "revocationEndpoint",
      tooltip_text:
        "fully formed url to the OAuth token revocation endpoint. If you want to be able to revoke a token and no issuer is specified, this field is mandatory.",
      default: "",
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
      key: "client_logo",
      type: "uploader",
      label: "Client Logo",
      label_tooltip: "Client logo image. Dimension 200 x44.",
      placeholder: "W 200px x H 44px",
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
      key: "action_button_font_ios",
      type: "ios_font_selector",
      label: "iOS Action button font",
      initial_value: "Helvetica-Bold",
    },
    {
      key: "action_button_font_android",
      type: "android_font_selector",
      label: "Android Action button font",
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
      label: "Action button font color",
      initial_value: "#ffffffff",
    },
  ],
};

const stylesTv = {
  fields: [],
};

const androidPlatforms = [
  "android",
  "android_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
];

const webPlatforms = ["samsung_tv"];

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
    {
      "react-native-app-auth":
        ":path => 'node_modules/react-native-app-auth.podspec'",
    },
  ],
  default: [],
};

const npm_dependencies = {
  default: [
    "@react-native-community/blur@3.4.1",
    "react-native-app-auth@6.0.1",
  ],
  web: [],
};

const min_zapp_sdk = {
  ios: "20.2.0-Dev",
  android: "20.0.0",
  ios_for_quickbrick: "0.1.0-alpha1",
  android_for_quickbrick: "0.1.0-alpha1",
  tvos_for_quickbrick: "0.1.0-alpha1",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
  samsung_tv: "1.2.2",
};

const isApple = R.includes(R.__, applePlatforms);
const iAndroid = R.includes(R.__, androidPlatforms);
const isWeb = R.includes(R.__, webPlatforms);

const withFallback = (obj, platform) => obj[platform] || obj["default"];
const localizations = {
  fields: [
    {
      key: "title_text",
      label: "Title label text",
      initial_value: "My Company",
    },
    {
      key: "login_text",
      label: "Login button text",
      initial_value: "Login",
    },
    {
      key: "logout_text",
      label: "Logout button text",
      initial_value: "Login",
    },
  ],
};

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
    localizations: localizations,
    targets: isTV ? ["tv"] : ["mobile"],
  };
}
module.exports = createManifest;