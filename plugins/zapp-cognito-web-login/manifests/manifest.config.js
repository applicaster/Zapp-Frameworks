const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  dependency_name: "@applicaster/cognito-webview-login",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Cognito Web Login",
  description: "Cognito Web Login",
  type: "login",
  react_native: true,
  screen: true,
  identifier: "cognito-webview-login",
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
      key: "loginURL",
      label: "Login URL",
      default: "",
    },
    {
      type: "text",
      key: "clientId",
      label: "Client Id",
      default: "",
    },
    {
      type: "text",
      key: "region",
      label: "Region",
      default: "",
    },
    {
      type: "tag_select",
      key: "logout_completion_action",
      tooltip_text: "Defines what action plugin should do after user log out. ",
      options: [
        {
          text: "Stay on current screen",
          value: "stay_on_screen",
        },
        {
          text: "Go back to home screen",
          value: "go_home",
        },
      ],
      initial_value: "go_back",
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
      key: "top_button_image_close",
      type: "uploader",
      label: "Close Button Image",
      label_tooltip: "Close button image next. Dimension 120 x120.",
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

const api = {
  default: {},
  web: {
    excludedNodeModules: ["react-native-dropdownalert"],
  },
  android: {},
};

const project_dependencies = {
  default: [],
  android: [],
};

const extra_dependencies = {
  apple: [],
  default: [],
};

const npm_dependencies = {
  default: [],
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
