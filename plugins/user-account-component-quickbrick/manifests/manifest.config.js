const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Quick Brick User Account Component",
  description: "User Account Component",
  type: "ui_component",
  identifier: "quick-brick-user-account",
  screen: true,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5a364b49e03b2f000d51a0de",
  ],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  custom_configuration_fields: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  dependency_name: "@applicaster/quick-brick-user-account",
};

function createManifest({ version, platform }) {
  console.log({ version, platform });
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    dependency_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    general: {
      fields: [
        {
          key: "custom_screen_id",
          type: "text_input",
          label: "Screen Id to open from comoponent",
          label_tooltip: "Screen Id to open from comoponent",
          initial_value: "",
          placeholder: "Screen id",
        },
        {
          group: true,
          label: "Screen Design and Text",
          tooltip: "These fields affect the design of the main screen plugin.",
          folded: true,
          fields: [
            {
              key: "account_component_instructions_text",
              type: "text_input",
              label: "Account Component Instructions Text",
              label_tooltip: "Text to explain briefly the section context.",
              initial_value: "Connect to your account",
              placeholder: "Connect to your account",
            },
            {
              key: "account_component_instructions_fontsize",
              type: "number_input",
              label_tooltip:
                "Font Size for Account Component Instructions Text.",
              initial_value: "26",
            },
            {
              key: "account_component_instructions_fontcolor",
              type: "color_picker_rgba",
              label_tooltip:
                "Font Color for Account Component Instructions Text.",
              initial_value: "rgb(84, 90, 92)",
            },
            {
              key: "account_component_greetings_text",
              type: "text_input",
              label: "Account Component Greetings Text",
              label_tooltip: "Text to greet the user.",
              initial_value: "Welcome",
              placeholder: "Welcome",
            },
            {
              key: "account_component_greetings_fontsize",
              type: "number_input",
              label_tooltip: "Font Size for Account Component Greetings Text.",
              initial_value: "26",
            },
            {
              key: "account_component_greetings_fontcolor",
              type: "color_picker_rgba",
              label_tooltip: "Font Color for Account Component Greetings Text.",
              initial_value: "rgb(84, 90, 92)",
            },
            {
              key: "login_action_button_text",
              type: "text_input",
              label: "Login Action Button Text",
              label_tooltip: "Text for the Login Button.",
              initial_value: "Log In",
              placeholder: "Log In",
            },
            {
              key: "login_action_button_fontsize",
              type: "number_input",
              label_tooltip: "Font Size for Login Action Button Text.",
              initial_value: "24",
            },
            {
              key: "login_action_button_fontcolor",
              type: "color_picker_rgba",
              label_tooltip: "Font Color for Login Action Button Text.",
              initial_value: "rgb(84, 90, 92)",
            },
            {
              key: "login_action_button_background_color",
              type: "color_picker_rgba",
              label: "Login Button Color for Samsung TV",
              label_tooltip:
                "Background Color for the Login Action Button for Samsung TV.",
              initial_value: "rgba(39, 218, 134, 1)",
            },
            {
              key: "logout_action_button_text",
              type: "text_input",
              label: "Logout Action Button Text",
              label_tooltip: "Text for the Logout Button.",
              initial_value: "Log Out",
              placeholder: "Log Out",
            },
            {
              key: "logout_action_button_fontsize",
              type: "number_input",
              label_tooltip: "Font Size for Logout Action Button Text.",
              initial_value: "24",
            },
            {
              key: "logout_action_button_fontcolor",
              type: "color_picker_rgba",
              label_tooltip: "Font Color for Logout Action Button Text.",
              initial_value: "rgb(84, 90, 92)",
            },
            {
              key: "logout_action_button_background_color",
              type: "color_picker_rgba",
              label: "Logout Button Color for Samsung TV",
              label_tooltip:
                "Background Color for the Logout Action Button for Samsung TV.",
              initial_value: "rgba(39, 218, 134, 1)",
            },
            {
              key: "authorization_provider_title_fontsize",
              type: "number_input",
              label_tooltip: "Font Size for authorization provider title.",
              initial_value: "24",
            },
            {
              key: "authorization_provider_title_fontcolor",
              type: "color_picker_rgba",
              label_tooltip: "Font Color for authorization provider title.",
              initial_value: "rgb(84, 90, 92)",
            },
          ],
        },
      ],
    },
  };
  return manifest;
}
const custom_configuration_fields_android = [
  {
    key: "android_assets_bundle",
    type: "uploader",
    label: "Android Design Assets",
    label_tooltip:
      "Please upload a zip file to provide the design assets for this plugin. For guidance and proper naming of the assets, please refer to this <a href='https://assets-production.applicaster.com.s3.amazonaws.com/applicaster-employees/marketplace/OPT/Login%20Plugin%20-%20Designer%20Documentation.sketch'>resource</a>.",
  },
];

const custom_configuration_fields_apple = [
  {
    key: "ios_assets_bundle",
    type: "uploader",
    label: "iOS Design Assets",
    label_tooltip:
      "Please upload a zip file to provide the design assets for this plugin. For guidance and proper naming of the assets, please refer to this <a href='https://assets-production.applicaster.com.s3.amazonaws.com/applicaster-employees/marketplace/OPT/Login%20Plugin%20-%20Designer%20Documentation.sketch'>resource</a>.",
  },
];

const custom_configuration_fields = {
  tvos_for_quickbrick: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
  android_tv_for_quickbrick: custom_configuration_fields_android,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  tvos_for_quickbrick: "4.1.0-dev",
  ios_for_quickbrick: "4.1.0-dev",
  android_for_quickbrick: "0.1.0-alpha1",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
  lg_tv: "2.0.0-dev",
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  android_for_quickbrick: mobileTarget,
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
