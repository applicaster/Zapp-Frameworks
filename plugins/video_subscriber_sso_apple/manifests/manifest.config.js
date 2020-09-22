const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Apple Video Subscriber SSO",
  description: "Apple Video Subscriber SSO",
  type: "general",
  screen: true,
  preload: true,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
    "5c20970320f1c500088842dd",
    "5e39259919785a0008225336",
  ],
  min_zapp_sdk: "1.0.0-Dev",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  general: {
    fields: [
      {
        group: true,
        label: "Screen Design and Text",
        tooltip: "These fields affect the design of the main screen plugin.",
        folded: true,
        fields: [
          {
            key: "screen_background_color",
            type: "color_picker",
            label: "Background font color",
            initial_value: "#161b29ff",
          },
          {
            key: "failure_alert_title",
            type: "text_input",
            label: "Failure alert title",
            tooltip: "Failure alert title",
            initial_value: "Unable to connect to TV Provider",
          },
          {
            key: "failure_alert_description",
            type: "text_input",
            label: "Failure alert description",
            tooltip: "Failure alert description",
            initial_value:
              "Please make sure TV Provider is configured in the device settings. As alternative you can login with Applicaster provider.",
          },
          {
            key: "failure_alert_cancel_button_title",
            type: "text_input",
            label: "Failure alert button title",
            tooltip: "Failure alert button title",
            initial_value: "Cancel",
          },
          {
            key: "failure_alert_login_applicaster_button_title",
            type: "text_input",
            label: "Failure alert login applicaster button title",
            tooltip: "Login with Applicaster",
            initial_value: "Login with Applicaster",
          },
          {
            key: "failure_alert_settings_button_title",
            type: "text_input",
            label: "Failure alert settings title",
            tooltip: "Failure alert settings title",
            initial_value: "Open app settings",
          },
          {
            key: "sign_out_alert_settings_button_title",
            type: "text_input",
            label: "SignOut alert settings title",
            tooltip: "SignOut alert settings title",
            initial_value: "Open TV Providers",
          },
          {
            key: "sign_out_settings_path_ios",
            type: "text_input",
            label:
              "SignOut part of message where define pass to the user to settings",
            tooltip:
              "SignOut part of message where define pass to the user to settings",
            initial_value: "Settings > TV Provider > Sign Out",
          },
          {
            key: "sign_out_settings_path_tvos",
            type: "text_input",
            label:
              "SignOut part of message where define pass to the user to settings",
            tooltip:
              "SignOut part of message where define pass to the user to settings",
            initial_value:
              "Settings > Users and Accounts > TV Provider > Sign Out",
          },
          {
            key: "sign_out_alert_title",
            type: "text_input",
            label: "SignOut alert title",
            tooltip: "SignOut alert title",
            initial_value: "SignOut",
          },
          {
            key: "sign_out_alert_message",
            type: "text_input",
            label: "SignOut alert message",
            tooltip: "SignOut alert message",
            initial_value:
              "The app was authenticated through Apple TV Provider Authenticaiton. \nTo Sign Out please navigate to the device Settings App. \n",
          },
          {
            key: "sign_out_alert_ok_button_title",
            type: "text_input",
            label: "Sign out alert ok button title",
            tooltip: "Sign out alert ok button title",
            initial_value: "Ok",
          },
          {
            key: "account_component_instructions_text",
            type: "text_input",
            label: "Account Component Instructions Text",
            label_tooltip: "Text to explain briefly the section context.",
            initial_value: "Connect to your account",
            placeholder: "Connect to your account",
          },
          {
            key: "account_component_separator_text",
            type: "text_input",
            label: "Separator text between buttons",
            label_tooltip: "Text to explain briefly the section context.",
            initial_value: "Or",
            placeholder: "Or",
          },
          {
            key: "account_component_instructions_fontsize",
            type: "number_input",
            label_tooltip: "Font Size for Account Component Instructions Text.",
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
            key: "login_action_button_applicaster_fontsize",
            type: "number_input",
            label_tooltip:
              "Font Size for Login Applicaster Action Button Text.",
            initial_value: "24",
          },
          {
            key: "login_action_button_applicaster_fontcolor",
            type: "color_picker_rgba",
            label_tooltip:
              "Font Color for Login Applicaster Action Button Text.",
            initial_value: "rgb(84, 90, 92)",
          },
          {
            key: "login_action_button_applicaster_background_color",
            type: "color_picker_rgba",
            label: "Login Button Background Color Applicaster",
            label_tooltip: "Background Color for the Login Applicaster Button",
            initial_value: "rgba(241, 173, 18, 1)",
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
  custom_configuration_fields: [
    {
      type: "checkbox",
      key: "is_zso",
      tooltip_text: "Is plugin enabled for Zero Sign On",
      default: 0,
    },
    {
      key: "fallback_login_button_enabled",
      type: "checkbox",
      tooltip_text: "Enable login fallback button",
      default: 0,
    },
    {
      key: "fallback_login_plugin_id",
      type: "text_input",
      label:
        "Add identifier of the login plugin. If no identifier provided will be used first availible login plugin",
      initial_value: "",
      placeholder: "Login plugin identifier id",
    },
    {
      key: "ios_assets_bundle",
      type: "uploader",
      label: "iOS Design Assets",
      label_tooltip:
        "Please upload a zip file to provide the design assets for this plugin. For guidance and proper naming of the assets, please refer to this <a href='https://assets-production.applicaster.com.s3.amazonaws.com/applicaster-employees/marketplace/OPT/Login%20Plugin%20-%20Designer%20Documentation.sketch'>resource</a>.",
    },
    {
      type: "text",
      key: "provider_identifier",
      tooltip_text: "Provider identifier",
    },
    {
      type: "text",
      key: "provider_name",
      tooltip_text: "Provider name",
    },
    {
      type: "text",
      key: "provider_channe_id",
      tooltip_text: "Provider channel id",
    },
    {
      type: "text",
      key: "authentication_endpoint",
      tooltip_text: "AuthN endpoint",
    },
    {
      type: "text",
      key: "authorization_endpoint",
      tooltip_text: "AuthZ endpoint",
    },
    {
      type: "text",
      key: "verification_token_endpoint",
      tooltip_text: "Verification token endpoint",
    },
    {
      type: "text",
      key: "app_level_user_metadata_endpoint",
      tooltip_text: "AppLevel Authentication (user metadata) endpoint",
    },
    {
      type: "text",
      key: "app_level_user_metadata_attributes",
      tooltip_text: "AppLevel Authentication (user metadata) attributes",
    },
  ],
  localizations: {
    fields: [],
  },
  identifier: "video_subscriber_sso_apple",
  npm_dependencies: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    dependency_name: "@applicaster/video_subscriber_sso_apple",
    dependency_version: version,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/video_subscriber_sso_apple@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos: "12.0.0-Dev",
  ios: "20.0.0-Dev",
  tvos_for_quickbrick: "0.1.0-alpha1",
  ios_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = {
  ZappAppleVideoSubscriberSSO:
    ":path => './node_modules/@applicaster/video_subscriber_sso_apple/apple/ZappAppleVideoSubscriberSSO.podspec'",
};
const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: true,
  class_name: "ZPAppleVideoSubscriberSSO",
  modules: ["ZappAppleVideoSubscriberSSO"],
  plist: {
    NSVideoSubscriberAccountUsageDescription:
      "We need to access you TV Provider for Single Sign-On to work.",
  },
  entitlements: {
    "com.apple.developer.video-subscriber-single-sign-on": true,
  },
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  tvos: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
