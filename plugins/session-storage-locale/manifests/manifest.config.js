const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Storing Locale",
  description: "Add Locale to session storage",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  identifier: "locale_storing",
  npm_dependencies: [],
  targets: ["mobile"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/session-storage-locale@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform]
  };
  return manifest;
}

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
};

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "supported_languages",
    label: "Supported languages",
    initial_value: "",
    tooltip_text: "List of supported languages separated by comma"
  },
  {
    type: "text",
    key: "default_language",
    label: "Default language",
    initial_value: "en",
    tooltip_text: "Default language"
  },
];

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  tvos_for_quickbrick: "4.1.0-Dev",
};

const extra_dependencies_apple = {
  ZappSessionStorageLocale:
    ":path => './node_modules/@applicaster/session-storage-locale/apple/ZappSessionStorageLocale.podspec'",
};

const extra_dependencies_apple_legacy = {
  "ZappSessionStorageLocale/Legacy":
    ":path => './node_modules/@applicaster/session-storage-locale/apple/ZappSessionStorageLocale.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks_native = ["native"];
const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_qb,
  tvos_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios: [extra_dependencies_apple_legacy],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: true,
  class_name: "ZPSessionStorageLocale",
  modules: ["ZappSessionStorageLocale"]
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
