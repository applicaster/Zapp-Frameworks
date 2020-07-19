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
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [
    {
      type: "checkbox",
      key: "enabled",
      tooltip_text: "Is plugin enabled on app start",
      default: 0,
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
  identifier: "video_subscriber_sso_apple",
  npm_dependencies: [],
  targets: ["mobile"],
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
  require_startup_execution: false,
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
