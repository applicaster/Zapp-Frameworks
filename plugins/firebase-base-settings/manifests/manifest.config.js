const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Firebase Base Settings 2.0",
  description:
    "Firebase Base Settings 2.0",
  cover_image:
    "",
  type: "general",
  identifier: "firebase_base_settings",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "3.0.0",
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
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "uploader",
    key: "enterprise_app_config",
    tooltip_text: "Upload GoogleService-Info.plist of enterprise app"
  },
  {
    type: "uploader",
    key: "production_app_config",
    tooltip_text: "Upload GoogleService-Info.plist of production app"
  },
  {
    key: "plist.FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED",
    type: "select",
    options: [
        {
            "text": "Deactivate",
            "value": "YES"
        },
        {
            "text": "Enabled",
            "value": "NO"
        }
    ],
    label: "Deactivate analytics collection",
    initial_value: "NO",
    tooltip_text: "If you need to deactivate Analytics collection permanently in a version of your app set value to Deactivate"
  }
];

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "3.0.0-Dev",
  tvos_for_quickbrick: "3.0.0-Dev",
};

const extra_dependencies_apple = [
  {
    Firebase: "= '6.25.0'"
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
  tvos_for_quickbrick: extra_dependencies_apple,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "",
  modules: [],
};

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
