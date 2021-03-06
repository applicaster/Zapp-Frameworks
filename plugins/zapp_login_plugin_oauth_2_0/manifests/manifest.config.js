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
  general: {
    fields: [
      {
        type: "switch",
        label: "Show full screen",
        tooltip: "Enabling this setting will hide both the nav bar and the menu on the screen",
        key: "allow_screen_plugin_presentation",
        initial_value: true,
      }
    ]
  },
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
      label: "Background",
      folded: true,
      fields: [
        {
          key: "background_image",
          type: "uploader",
          label: "Background Image",
          label_tooltip:
            "Background image. It is recommended to use an image that could be centered in the different screen sizes.",
        },
        {
          key: "background_color",
          type: "color_picker",
          label: "Background color",
          initial_value: "#161b29ff",
        },
      ],
    },
    {
      group: true,
      label: "Logo",
      folded: true,
      fields: [
        {
          key: "client_logo_position",
          type: "tag_select",
          initial_value: "middle",
          label: "Logo position",
          label_tooltip: "Position of the logo on the screen",
          options: [
            {
              text: "Top",
              value: "top",
            },
            {
              text: "Middle",
              value: "middle",
            },
          ],
        },
        {
          key: "client_logo",
          type: "uploader",
          label: "Logo",
          label_tooltip: "Logo image. Dimension 200x44 pixels.",
          placeholder: "W 200px x H 44px",
        },
      ],
    },
    {
      group: true,
      label: "Title",
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
          initial_value: 15,
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
      label: "Sub title",
      folded: true,
      fields: [
        {
          key: "subtitle",
          type: "switch",
          initial_value: false,
          label: "Display subtitle",
        },
        {
          key: "subtitle_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
          conditional_fields: [
            {
              key: "styles/subtitle",
              condition_value: true,
            },
          ],
        },
        {
          key: "subtitle_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
          conditional_fields: [
            {
              key: "styles/subtitle",
              condition_value: true,
            },
          ],
        },
        {
          key: "subtitle_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 15,
          conditional_fields: [
            {
              key: "styles/subtitle",
              condition_value: true,
            },
          ],
        },
        {
          key: "subtitle_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#ffffffff",
          conditional_fields: [
            {
              key: "styles/subtitle",
              condition_value: true,
            },
          ],
        },
      ],
    },
    {
      group: true,
      label: "Back button",
      folded: true,
      fields: [
        {
          key: "back_button_force_display",
          type: "switch",
          initial_value: false,
          label: "Force display",
          label_tooltip: "If true, then the button will always be displayed. If false, then only on the player's hook",
        },
        {
          key: "back_button_position",
          type: "tag_select",
          initial_value: "top",
          label: "Back button position",
          label_tooltip: "Position of the back button on the screen",
          options: [
            {
              text: "Top & Left",
              value: "top",
            },
            {
              text: "Bottom",
              value: "bottom",
            },
          ],
        },
        {
          key: "back_button_font_ios",
          type: "ios_font_selector",
          label: "iOS font family",
          initial_value: "Helvetica-Bold",
        },
        {
          key: "back_button_font_android",
          type: "android_font_selector",
          label: "Android font family",
          initial_value: "Roboto-Bold",
        },
        {
          key: "back_button_font_size",
          type: "number_input",
          label: "Font size",
          initial_value: 15,
        },
        {
          key: "back_button_font_color",
          type: "color_picker",
          label: "Color",
          initial_value: "#ffffffff",
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
          initial_value: "#ffffffff",
        },
        {
          key: "action_button_background_color",
          type: "color_picker",
          label: "Background color",
          initial_value: "#F1AD12ff",
        },
        {
          key: "action_button_border_radius",
          type: "number_input",
          label: "Border radius",
          initial_value: 10,
        },
      ],
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
        "REQUIRED: The url that links back to your app with the auth code. Note: URL has to follow the app url schemes structure 'myapp://', and must be declared in the app settings.",
      default: "",
      conditional_fields: [
        {
          condition_value: ["aws_cognito", "other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
  ],
  android: [
    {
      type: "text",
      key: "redirectUrl",
      label: "Redirect URL",
      tooltip_text:
        "REQUIRED: The url that links back to your app with the auth code. Note: URL scheme as to follow the app url scheme with prefix 'com.oauth2.': 'com.oauth2.myapp://'",
      default: "",
      conditional_fields: [
        {
          condition_value: ["aws_cognito", "other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
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

  const custom_configuration_fields = [
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
      key: "clientId",
      label: "Client ID",
      tooltip_text: "REQUIRED: Client id on the auth server",
      default: "",
      conditional_fields: [
        {
          condition_value: ["aws_cognito", "other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "domainName",
      label: "Domain Name",
      tooltip_text: "REQUIRED: Domain name",
      default: "",
      conditional_fields: [
        {
          condition_value: ["aws_cognito"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "issuer",
      label: "Issuer",
      tooltip_text:
        "Base URI of the authentication server. Issuer is a mandatory field in case you do not provide Authoriztion, Token and Revocation endpoints, so that the configuration can be fetched from the issuer's OIDC discovery endpoint.",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    ...withFallback(url_custom_configuration_fields, basePlatform),
    {
      type: "text_input",
      key: "authorizationEndpoint",
      label: "Authorization Endpoint",
      tooltip_text:
        "REQUIRED: Fully formed url to the OAuth authorization endpoint",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "tokenEndpoint",
      label: "Token Endpoint",
      tooltip_text:
        "REQUIRED: Fully formed url to the OAuth token exchange endpoint",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "revocationEndpoint",
      label: "Revocation Endpoint",
      tooltip_text:
        "Fully formed url to the OAuth token revocation endpoint. If you want to be able to revoke a token and no issuer is specified, this field is mandatory.",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "registrationEndpoint",
      label: "Registration Endpoint",
      tooltip_text:
        "Fully formed url to your OAuth/OpenID Connect registration endpoint. Only necessary for servers that require client registration.",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "clientSecret",
      label: "Client Secret",
      tooltip_text: "Client secret to pass to token exchange requests. It is recommended not to be used in side mobile apps. Please consult your autorization provider.",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "scopes",
      label: "Scopes",
      tooltip_text:
        "The scopes for your token, use comma seperated like email,offline_access",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "checkbox",
      key: "useNonce",
      label: "Use Nonce",
      tooltip_text:
        "IOS (default: true) optionally allows not sending the nonce parameter, to support non-compliant providers",
      default: true,
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "checkbox",
      key: "usePKCE",
      label: "Use PKCE",
      tooltip_text:
        "(default: true) optionally allows not sending the code_challenge parameter and skipping PKCE code verification, to support non-compliant providers.",
      default: true,
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "additionalParameters",
      multiline: true,
      label: "Additional Parameters",
      tooltip_text:
        "Additional parameters that will be passed in the authorization request. Must be string values. E.g. setting additionalParameters: { hello: 'world', foo: 'bar' } would add hello=world&foo=bar to the authorization request. Add in this field data in json format",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "text_input",
      key: "clientAuthMethod",
      label: "Client Auth Method",
      tooltip_text:
        "ANDROID ONLY: Client Authentication Method. Can be either basic (default) for Basic Authentication or post for HTTP POST body Authentication",
      default: "",
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "checkbox",
      key: "dangerouslyAllowInsecureHttpRequests",
      label: "Dangerously Allow Insecure Http Requests",
      tooltip_text:
        "ANDROID Only: whether to allow requests over plain HTTP or with self-signed SSL certificates. ⚠️ Can be useful for testing against local server, should not be used in production. This setting has no effect on iOS; to enable insecure HTTP requests, add a NSExceptionAllowsInsecureHTTPLoads exception to your App Transport Security settings.",
      default: false,
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
    },
    {
      type: "checkbox",
      key: "skipCodeExchange",
      label: "Skip Code Exchange",
      tooltip_text:
        "(default: false) just return the authorization response, instead of automatically exchanging the authorization code. This is useful if this exchange needs to be done manually (not client-side)",
      default: false,
      conditional_fields: [
        {
          condition_value: ["other"],
          key: "custom_configuration_fields/provider_selector",
        },
      ],
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
