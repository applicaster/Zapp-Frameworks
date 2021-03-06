const baseManifest = {
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Apple Video Subscription Registration.",
  description: "Apple Video Subscription Registration",
  type: "general",
  identifier: "video_subscription_registration_apple",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
    "5c20970320f1c500088842dd",
    "5e39259919785a0008225336",
  ],
  ui_frameworks: ["quickbrick"],
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
      key: "access_level",
      tooltip_text:
        "Access Level (0 - free, 1 - account, 2 - paid subscription)",
      default: "0",
    },
    {
      type: "text",
      key: "tier_identifiers",
      tooltip_text:
        "Supported tiers (abc,def,ghi)",
      default: "",
    },
    {
      type: "text",
      key: "billing_identifier",
      tooltip_text:
        "Hashed billing identifier if supported",
      default: "",
    },
  ],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [
      `@applicaster/video_subscription_registration_apple@${version}`,
    ],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos_for_quickbrick: "2.0.2-Dev",
  ios_for_quickbrick: "2.0.2-Dev",
};

const extra_dependencies_apple = {
  ZappAppleVideoSubscriptionRegistration:
    ":path => './node_modules/@applicaster/video_subscription_registration_apple/apple/ZappAppleVideoSubscriptionRegistration.podspec'",
};

const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "ZPAppleVideoSubscriptionRegistration",
  modules: ["ZappAppleVideoSubscriptionRegistration"],
  plist: {
    UISupportsTVApp: true,
  },
  entitlements: {
    "com.apple.smoot.subscriptionservice": true,
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
