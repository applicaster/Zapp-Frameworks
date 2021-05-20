const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  dependency_repository_url: [],
  dependency_name: "@applicaster/zapp_login_plugin_oauth_tv_2_0",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "TV Oauth 2.0 Login",
  description: "TV Oauth 2.0 Login",
  type: "login",
  screen: true,
  react_native: true,
  identifier: "zapp_login_plugin_oauth_tv_2_0",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  general: {},
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
  fields: [],
};

const stylesTv = {
  fields: [
    {
      group: true,
      label: "Environment",
      folded: true,
      fields: [
        {
          key: "background_color",
          type: "color_picker",
          label: "Background color",
          initial_value: "#f1f1f1FF",
        },
        {
          key: "background_color_prehook",
          type: "color_picker",
          label: "Background color",
          initial_value: "#00000000",
        },
        {
          key: "client_logo",
          type: "uploader",
          label: "Logo",
          label_tooltip: "Logo image. Dimension 350x350 pixels.",
          placeholder: "W 350 x H 350px",
        },
        {
          key: "activity_indicator_color",
          type: "color_picker",
          label: "Activity indicator color",
          initial_value: "#525A5CFF",
        },
        {
          key: "line_separator_color",
          type: "color_picker",
          label: "Sign in screen verticall separator",
          initial_value: "#979797",
        },
      ],
    },
    {
      group: true,
      label: "Header text",
      folded: true,
      fields: [
        {
          key: "title_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "title_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "title_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 42,
        },
        {
          key: "title_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#ffffffff",
        },
      ],
    },
    {
      group: true,
      label: "Text",
      folded: true,
      fields: [
        {
          key: "text_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "text_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "text_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 32,
        },
        {
          key: "text_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#525A5C",
        },
      ],
    },
    {
      group: true,
      label: "Text URL",
      folded: true,
      fields: [
        {
          key: "text_url_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "text_url_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "text_url_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 20,
        },
        {
          key: "text_url_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#525A5C",
        },
      ],
    },
    {
      group: true,
      label: "Text Code",
      folded: true,
      fields: [
        {
          key: "text_code_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "text_code_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "text_code_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 20,
        },
        {
          key: "text_code_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#525A5C",
        },
      ],
    },
    {
      group: true,
      label: "Action button",
      folded: true,
      fields: [
        {
          key: "action_button_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "action_button_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "action_button_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 15,
        },
        {
          key: "action_button_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#5D5D5DFF",
        },
        {
          key: "action_button_font_color_focused",
          type: "color_picker",
          label: "Color Focused",
          initial_value: "#ffffffff",
        },
        {
          key: "action_button_background_color",
          type: "color_picker",
          label: "Background color",
          initial_value: "#D8D8D8ff",
        },
        {
          key: "action_button_background_color_focused",
          type: "color_picker",
          label: "Background color focused",
          initial_value: "#0081C8FF",
        },
      ],
    },
  ],
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
    react_packages: ["com.rnappauth.RNAppAuthPackage"],
    proguard_rules:
      "-keep public class * extends com.facebook.react.ReactPackage {*;} -keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;} -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; } -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }",
  },
};

const project_dependencies = {
  default: [],
  android: [],
};

const extra_dependencies = {
  apple: [],
  default: [],
};

function npm_dependencies(version) {
  return {
    default: [],
    web: [],
  };
}

const min_zapp_sdk = {
  ios: "20.2.0-Dev",
  android: "20.0.0",
  ios_for_quickbrick: "0.1.0-alpha1",
  tvos_for_quickbrick: "0.1.0-alpha1",
  android_for_quickbrick: "3.0.0-dev",
  android_tv_for_quickbrick: "3.0.0-dev",
  amazon_fire_tv_for_quickbrick: "3.0.0-dev",
  samsung_tv: "1.2.2",
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

  const custom_configuration_fields = [
    {
      type: "text_input",
      key: "clientId",
      label: "Client Id",
      tooltip_text: "REQUIRED: Client Id",
      default: "",
    },
    {
      type: "text_input",
      key: "deviceEndPoint",
      label: "Device Endpoint",
      tooltip_text: "REQUIRED: Device Endpoint",
      default: "",
    },
    {
      type: "text_input",
      key: "tokenEndPoint",
      label: "Token Endpoint",
      tooltip_text: "REQUIRED: Token Endpoint",
      default: "",
    },
    {
      type: "text_input",
      key: "refreshEndPoint",
      label: "Refresh Endpoint",
      tooltip_text: "REQUIRED: Refresh Endpoint",
      default: "",
    },
    {
      type: "text_input",
      key: "logoutEndPoint",
      label: "Logout Endpoint",
      tooltip_text: "OPTIONAL: Logout Endpoint",
      default: "",
    },
    {
      type: "text_input",
      key: "session_storage_key",
      label: "Session Storage Key",
      tooltip_text:
        "Session storage key that will be used to save oauth token data. This is used to fetch data, please verify with your DSP developer in case you wish to change it.",
      default: "access_token",
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
  ];

  return {
    ...baseManifest,
    platform,
    dependency_version: version,
    manifest_version: version,
    api: withFallback(api, basePlatform),
    project_dependencies: withFallback(project_dependencies, basePlatform),
    extra_dependencies: withFallback(extra_dependencies, basePlatform),
    min_zapp_sdk: withFallback(min_zapp_sdk, platform),
    npm_dependencies: withFallback(npm_dependencies(version), basePlatform),
    custom_configuration_fields,
    styles: isTV ? stylesTv : stylesMobile,
    localizations: isTV ? Localizations.tv : Localizations.mobile,
    targets: isTV ? ["tv"] : ["mobile"],
  };
}

module.exports = createManifest;
