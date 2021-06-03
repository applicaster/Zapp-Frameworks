const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Storing Idfa",
  description: "Add IDFA to session storage",
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
  identifier: "idfa_storing",
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
    npm_dependencies: [`@applicaster/session-storage-idfa@${version}`],
    custom_configuration_fields: custom_configuration_fields[platform],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform]
  };
  return manifest;
}
const min_zapp_sdk = {
  ios: "16.0.0-Dev",
  ios_for_quickbrick: "2.0.2-Dev",
  tvos_for_quickbrick: "2.0.2-Dev",
};

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "plist.NSUserTrackingUsageDescription",
    label: "ATT description",
    default: "This identifier will be used to deliver personalized ads to you.",
    tooltip_text: "Please enter the description for ATT"
  }
];

const extra_dependencies_apple = {
  ZappSessionStorageIdfa:
    ":path => './node_modules/@applicaster/session-storage-idfa/apple/ZappSessionStorageIdfa.podspec'",
};

const extra_dependencies_apple_legacy = {
  "ZappSessionStorageIdfa/Legacy":
    ":path => './node_modules/@applicaster/session-storage-idfa/apple/ZappSessionStorageIdfa.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks_native = ["native"];
const ui_frameworks = {
  ios: ui_frameworks_native,
  ios_for_quickbrick: ui_frameworks_qb,
  tvos_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios: [extra_dependencies_apple_legacy],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
};

const api_apple = {
  require_startup_execution: true,
  class_name: "SessionStorageIdfa",
  modules: ["ZappSessionStorageIdfa"],
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
