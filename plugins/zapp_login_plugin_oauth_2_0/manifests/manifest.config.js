const R = require("ramda");
const Localizations = require("./localizations.config");

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
      key: "provider_selector",
      type: "select",
      initial_value: "aws_cognito",
      options: [
        {
          label: "AWS Cognito",
          value: "aws_cognito",
        },
        {
          label: "Other",
          value: "other",
        },
      ],
    },
    {
      type: "text_input",
      key: "session_storage_key",
      label: "Session Storage Key",
      tooltip_text:
        "Session storage key that will be used to save oauth token data",
      default: "access_token",
    },
    {
      type: "text_input",
      key: "clientId",
      label: "Client ID",
      tooltip_text: "REQUIRED: your client id on the auth server",
      default: "",
    },
    {
      type: "text_input",
      key: "logoutURL",
      label: "Logout URL",
      tooltip_text:
        "If defined will be called during user will logout, allow to clear browser cache",
      default: "",
    },
    {
      group: true,
      label: "AWS Cognito",
      tooltip: "AWS Cognito",
      folded: true,
      fields: [
        {
          type: "text_input",
          key: "domainName",
          label: "Domain Name",
          tooltip_text: "REQUIRED: Domain name",
          default: "",
        },
      ],
    },
    {
      group: true,
      label: "Other provider",
      tooltip: "Other provider",
      folded: true,
      fields: [
        {
          type: "text_input",
          key: "issuer",
          label: "Issuer",
          tooltip_text:
            "base URI of the authentication server. If no serviceConfiguration (below) is provided, issuer is a mandatory field, so that the configuration can be fetched from the issuer's OIDC discovery endpoint.",
          default: "",
        },
        {
          type: "text_input",
          key: "authorizationEndpoint",
          label: "Authorization End Point",
          tooltip_text:
            "REQUIRED: fully formed url to the OAuth authorization endpoint",
          default: "",
        },
        {
          type: "text_input",
          key: "tokenEndpoint",
          label: "Token End Point",
          tooltip_text:
            "REQUIRED: fully formed url to the OAuth token exchange endpoint",
          default: "",
        },
        {
          type: "text_input",
          key: "revocationEndpoint",
          label: "Revocation End Point",
          tooltip_text:
            "Fully formed url to the OAuth token revocation endpoint. If you want to be able to revoke a token and no issuer is specified, this field is mandatory.",
          default: "",
        },
        {
          type: "text_input",
          key: "registrationEndpoint",
          label: "Registration End Point",
          tooltip_text:
            "Fully formed url to your OAuth/OpenID Connect registration endpoint. Only necessary for servers that require client registration.",
          default: "",
        },
        {
          type: "text_input",
          key: "registrationEndpoint",
          label: "Registration End Point",
          tooltip_text:
            "Fully formed url to your OAuth/OpenID Connect registration endpoint. Only necessary for servers that require client registration.",
          default: "",
        },
        {
          type: "text_input",
          key: "clientSecret",
          label: "Client Secret",
          tooltip_text: "Client secret to pass to token exchange requests.",
          default: "",
        },
        {
          type: "text_input",
          key: "scopes",
          label: "Scopes",
          tooltip_text:
            "The scopes for your token, e.g. ['email', 'offline_access']. Please add values comma seperated like email,offline_access",
          default: "",
        },
        {
          type: "text_input",
          key: "additionalParameters",
          multiline: true,
          label: "Additional Parameters",
          tooltip_text:
            "Additional parameters that will be passed in the authorization request. Must be string values! E.g. setting additionalParameters: { hello: 'world', foo: 'bar' } would add hello=world&foo=bar to the authorization request. Add in this feild data in json format",
          default: "",
        },
        {
          type: "text_input",
          key: "clientAuthMethod",
          label: "Client Auth Method",
          tooltip_text:
            "ANDROID Client Authentication Method. Can be either basic (default) for Basic Authentication or post for HTTP POST body Authentication",
          default: "",
        },
        {
          type: "switch",
          key: "dangerouslyAllowInsecureHttpRequests",
          label: "Dangerously Allow Insecure Http Requests",
          tooltip_text:
            "ANDROID whether to allow requests over plain HTTP or with self-signed SSL certificates. ⚠️ Can be useful for testing against local server, should not be used in production. This setting has no effect on iOS; to enable insecure HTTP requests, add a NSExceptionAllowsInsecureHTTPLoads exception to your App Transport Security settings.",
          initial_value: false,
        },
        {
          type: "switch",
          key: "useNonce",
          label: "Use Nonce",
          tooltip_text:
            "IOS (default: true) optionally allows not sending the nonce parameter, to support non-compliant providers",
          initial_value: true,
        },
        {
          type: "switch",
          key: "usePKCE",
          label: "Use PKCE",
          tooltip_text:
            "(default: true) optionally allows not sending the code_challenge parameter and skipping PKCE code verification, to support non-compliant providers.",
          initial_value: true,
        },
        {
          type: "switch",
          key: "skipCodeExchange",
          label: "Skip Code Exchange",
          tooltip_text:
            "(default: false) just return the authorization response, instead of automatically exchanging the authorization code. This is useful if this exchange needs to be done manually (not client-side)",
          initial_value: false,
        },
      ],
    },
    {
      group: true,
      label: "Debug",
      tooltip: "Only for developers",
      folded: true,
      fields: [
        {
          type: "tag_select",
          key: "force_authentication_on_all",
          tooltip_text:
            "If On all video entries will be marked as required login",
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
      key: "background_image",
      type: "uploader",
      label: "Background Image",
      label_tooltip:
        "Background image. Please use that can be centered in the different device screens",
    },
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
    {
      key: "action_button_background_color",
      type: "color_picker",
      label: "Action button font color",
      initial_value: "#F1AD12ff",
    },
    {
      key: "back_button_font_ios",
      type: "ios_font_selector",
      label: "iOS back button font",
      initial_value: "Roboto-Bold",
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
    react_packages: ["com.rnappauth.RNAppAuthPackage"],
    proguard_rules:
      "-keep public class * extends com.facebook.react.ReactPackage {*;} -keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;} -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; } -keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }",
  },
};

const url_custom_configuration_fields = {
  apple: [
    {
      type: "text",
      key: "redirectUrl",
      label: "Redirect URL",
      tooltip_text:
        "REQUIRED: the url that links back to your app with the auth code. Note: URL has to follow the app url schemes structure 'myapp://'",
      default: "",
    },
  ],
  android: [
    {
      type: "text",
      key: "redirectUrl",
      label: "Redirect URL",
      tooltip_text:
        "REQUIRED: the url that links back to your app with the auth code. Note: URL scheme must be app url scheme with prefix 'com.oauth2.': 'com.oauth2.myapp://'",
      default: "",
    },
  ],
  default: [],
};

const project_dependencies = {
  default: [],
  android: [
    {
      "react-native-app-auth": "node_modules/react-native-app-auth/android",
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
        ":path => 'node_modules/react-native-app-auth/react-native-app-auth.podspec'",
    },
    {
      ZappOAuth:
        ":path => 'node_modules/@applicaster/zapp_login_plugin_oauth_2_0/apple/ZappOAuth.podspec'",
    },
  ],
  default: [],
};

function npm_dependencies(version) {
  return {
    default: [
      "@react-native-community/blur@3.4.1",
      "react-native-app-auth@6.0.1",
      `@applicaster/zapp_login_plugin_oauth_2_0@${version}`,
    ],
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

  custom_configuration_fields = withFallback(
    url_custom_configuration_fields,
    basePlatform
  ).concat(baseManifest.custom_configuration_fields);

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
