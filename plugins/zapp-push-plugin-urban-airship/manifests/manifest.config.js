const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Firebase Notifications",
  description:
    "Urban Airship wrapper",
  cover_image:
    "",
  type: "push_provider",
  identifier: "UrbanAirship",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-push-plugin-urban-airship@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "store_app_key",
    tooltip_text: "AppStore production App Key"
  },
  {
    type: "text",
    key: "store_app_secret",
    tooltip_text: "AppStore production App Secret"
  },
  {
    type: "text",
    key: "enterprise_app_key",
    tooltip_text: "Enterprise production App Key"
  },
  {
    type: "text",
    key: "enterprise_app_secret",
    tooltip_text: "Enterprise production App Secret"
  },
  {
    type: "text",
    key: "google_analytics_account_id",
    tooltip_text: "Google Analytics Account ID"
  },
  {
    type: "checkbox",
    key: "allow_enterprise_rich_push_notifications",
    "default": 1
  },
  {
    type: "uploader",
    key: "notification_service_extension_provisioning_profile",
    tooltip_text: "Upload Notification Extension Provisioning Profile for Store builds only"
  }
];

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "1.1.0-Dev",
};

const extra_dependencies_apple = [
  {
    ZappPushPluginUrbanAirship:
      ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
  },
  {
    NotificationServiceExtension: {
      "ZappPushPluginFirebase/ServiceExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
    },
  },
  {
    NotificationContentExtension: {
      "ZappPushPluginFirebase/ContentExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
    },
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APPushProviderUrbanAirship",
  modules: ["ZappPushPluginUrbanAirship"],
  plist: {
    "NSLocationAlwaysAndWhenInUseUsageDescription": "Your current location will be used to enable location based push notifications.",
    "NSLocationWhenInUseUsageDescription": "Your current location will be used to enable location based push notifications.",
    "NSLocationAlwaysUsageDescription": "Your current location will be used to enable location based push notifications."
  }
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];

const targets = {
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
