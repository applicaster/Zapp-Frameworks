const R = require("ramda");
const Localizations = require("./localizations.config");

const baseManifest = {
  dependency_repository_url: [],
  dependency_name: "@applicaster/zapp-cleeng-storefront",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Cleeng Storefront",
  description: "Cleeng Storefront",
  type: "payments",
  screen: true,
  react_native: true,
  identifier: "zapp-cleeng-storefront",
  ui_builder_support: true,
  whitelisted_account_ids: [""],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
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
      key: "get_items_to_purchase_api_endpoint",
      label: "Get items to purcahse End Point",
      default: "subscriptions",
    },
    {
      type: "text",
      key: "purchase_an_item",
      label: "Validate purchased item End Point",
      default: "subscription",
    },
    {
      type: "text",
      key: "restore_api_endpoint",
      label: "Restore purchases End Point",
      default: "restore",
    },
    {
      group: true,
      label: "Debug",
      tooltip: "For development purposes",
      folded: true,
      fields: [
        {
          type: "tag_select",
          key: "debug_mode",
          tooltip_text: "Enables debug mode",
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
          conditional_fields: [
            {
              condition_value: ["on"],
              key: "custom_configuration_fields/debug_mode",
            },
          ],
          initial_value: "off",
        },
        {
          type: "tag_select",
          key: "stub_purchase_flow_complete",
          tooltip_text: "Stubbing all flow to purchase success",
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
          conditional_fields: [
            {
              condition_value: ["on"],
              key: "custom_configuration_fields/debug_mode",
            },
          ],
          initial_value: "off",
        },
        {
          type: "tag_select",
          key: "stub_purchase_flow_complete",
          tooltip_text: "Stubbing all flow to purchase failed",
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
          conditional_fields: [
            {
              condition_value: ["on"],
              key: "custom_configuration_fields/debug_mode",
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
      group: true,
      label: "Storefront Screen Design and Text",
      tooltip: "These fields affect the design of the storefront screen.",
      folded: true,
      fields: [
        {
          key: "payment_screen_background",
          type: "color_picker_rgba",
          label: "Payment Screen Background Color",
          label_tooltip: "Background Color for the payment screen.",
          initial_value: "rgba(66,74,87,1)",
        },
        {
          key: "close_button",
          type: "uploader",
          label: "Close Button",
          label_tooltip: "Icon for close button. Dimensions 45 x 45.",
          placeholder: "W 45px x H 45px",
        },
        {
          key: "client_logo",
          type: "uploader",
          label: "Client Logo",
          label_tooltip: "Client logo image. Dimension 200 x44.",
          placeholder: "W 200px x H 44px",
        },
        {
          key: "payment_screen_title_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for Main Title for ios.",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "payment_screen_title_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Main Title for android.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "payment_screen_title_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Main Title Text.",
          initial_value: "21",
        },
        {
          key: "payment_screen_title_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Main Title Text.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "restore_purchases_text_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for Restore Purchases Description Text for ios.",
          initial_value: "HelveticaNeue",
        },
        {
          key: "restore_purchases_text_font_android",
          type: "android_font_selector",
          label_tooltip:
            "Font for Restore Purchases Description Text for android.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "restore_purchases_text_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Restore Purchases Description Text.",
          initial_value: "12",
        },
        {
          key: "restore_purchases_text_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Restore Purchases Description Text.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "restore_purchases_link_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for Restore Purchases Link Text for ios.",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "restore_purchases_link_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for Restore Purchases Link Text for android.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "restore_purchases_link_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Restore Purchases Link Text.",
          initial_value: "13",
        },
        {
          key: "restore_purchases_link_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Restore Purchases Link Text.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "payment_option_background",
          type: "color_picker_rgba",
          label: "Payment Option Background Color",
          label_tooltip: "Background Color for the Payment Option.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "payment_option_corner_radius",
          type: "number_input",
          label: "Payment Option Corner Radius",
          label_tooltip: "Corner Radius for the Payment Option.",
          initial_value: "6",
        },
        {
          key: "payment_option_title_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the Payment Option Title for ios.",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "payment_option_title_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the Payment Option Title for android.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "payment_option_title_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Payment Option Title.",
          initial_value: "20",
        },
        {
          key: "payment_option_title_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Payment Option Title.",
          initial_value: "rgba(0,0,0,1)",
        },
        {
          key: "payment_option_description_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the Payment Option Description for ios.",
          initial_value: "HelveticaNeue",
        },
        {
          key: "payment_option_description_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the Payment Option Description for android.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "payment_option_description_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Payment Option Description.",
          initial_value: "14",
        },
        {
          key: "payment_option_description_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Payment Option Description.",
          initial_value: "rgba(66,74,87,1)",
        },
        {
          key: "payment_option_button_background",
          type: "color_picker_rgba",
          label: "Payment Option Action Button Background Color",
          label_tooltip:
            "Background Color for the Payment Option Action Button.",
          initial_value: "rgba(39, 218, 134, 1)",
        },
        {
          key: "payment_option_button_corner_radius",
          type: "number_input",
          label: "Payment Option Action Button Corner Radius",
          label_tooltip: "Corner Radius for the Payment Option Action Button.",
          initial_value: "18",
        },
        {
          key: "payment_option_button_font_ios",
          type: "ios_font_selector",
          label_tooltip:
            "Font for the Payment Option Action Button Text for ios.",
          initial_value: "HelveticaNeue-Bold",
        },
        {
          key: "payment_option_button_font_android",
          type: "android_font_selector",
          label_tooltip:
            "Font for the Payment Option Action Button Text for android.",
          initial_value: "Roboto-Bold",
        },
        {
          key: "payment_option_button_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for Payment Option Action Button Text.",
          initial_value: "12",
        },
        {
          key: "payment_option_button_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for Payment Option Action Button Text.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "terms_of_use_instructions_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the Terms of Use Instructions Text for ios.",
          initial_value: "HelveticaNeue",
        },
        {
          key: "terms_of_use_instructions_font_android",
          type: "android_font_selector",
          label_tooltip:
            "Font for the Terms of Use Instructions Text for android.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "terms_of_use_instructions_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for the Terms of Use Instructions Text.",
          initial_value: "10",
        },
        {
          key: "terms_of_use_instructions_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for the Terms of Use Instructions Text.",
          initial_value: "rgba(255, 255, 255, 1)",
        },
        {
          key: "terms_of_use_link",
          type: "text_input",
          label: "Payment Terms of use Link",
          label_tooltip: "Link for the Terms of Use.",
          initial_value: "http://google.com",
        },
        {
          key: "terms_of_use_link_font_ios",
          type: "ios_font_selector",
          label_tooltip: "Font for the Terms of Use Link Text for ios.",
          initial_value: "HelveticaNeue",
        },
        {
          key: "terms_of_use_link_font_android",
          type: "android_font_selector",
          label_tooltip: "Font for the Terms of Use Link Text for android.",
          initial_value: "Roboto-Regular",
        },
        {
          key: "terms_of_use_link_fontsize",
          type: "number_input",
          label_tooltip: "Font Size for the Terms of Use Link Text.",
          initial_value: "10",
        },
        {
          key: "terms_of_use_link_fontcolor",
          type: "color_picker_rgba",
          label_tooltip: "Font Color for the Terms of Use Link Text.",
          initial_value: "rgba(255, 255, 255, 1)",
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
      "@applicaster/applicaster-iap",
      "react-native-dropdownalert",
      "react-native-keyboard-aware-scroll-view",
    ],
  },
  android: {
    class_name: "com.applicaster.reactnative.plugins.APReactNativeAdapter",
    react_packages: [
      "com.applicaster.iap.reactnative.IAPPackage",
      "com.cmcewen.blurview.BlurViewPackage",
    ],
    proguard_rules:
      "-keep public class * extends com.facebook.react.ReactPackage {*;} -keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;} -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; } -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }",
  },
};

const project_dependencies = {
  default: [],
  android: [
    {
      iap: "node_modules/@applicaster/applicaster-iap/android/iap",
    },
    {
      "iap-uni": "node_modules/@applicaster/applicaster-iap/android/iap-uni",
    },
    {
      "iap-rn": "node_modules/@applicaster/applicaster-iap/android/iap-rn",
    },
    {
      "react-native-community_blur":
        "node_modules/@react-native-community/blur/android",
    },
  ],
};

const extra_dependencies = {
  apple: [
    {
      ApplicasterIAP:
        ":path => 'node_modules/@applicaster/applicaster-iap/apple/ApplicasterIAP.podspec'",
    },
    {
      "react-native-blur":
        ":path => 'node_modules/@react-native-community/blur/react-native-blur.podspec'",
    },
  ],
  default: [],
};

const npm_dependencies = {
  default: [
    "@applicaster/applicaster-iap@0.3.3",
    "@react-native-community/blur@3.4.1",
  ],
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
