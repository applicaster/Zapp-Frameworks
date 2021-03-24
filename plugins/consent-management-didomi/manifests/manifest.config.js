const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Didomi Consent Management",
  description: "Didomi Consent Management",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  core_plugin: true,
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  identifier: "consent_management_didomi",
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
    npm_dependencies: [`@applicaster/consent-management-didomi@${version}`],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    react_native: false, 
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    key: "enabled",
    type: "checkbox",
    default: 1,
    label: "Plugin enabled",
    label_tooltip:
      "Disable plugin if you do not want to use plugin",
  },
  {
    key: "api_key",
    type: "text",
    label: "Api Key",
    default: "",
    tooltip_text: "Set Didomi Api Key"
  }
];

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
};

const extra_dependencies_apple = {
  ConsentManagementDidomi:
    ":path => './node_modules/@applicaster/consent-management-didomi/apple/ConsentManagementDidomi.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: true,
  class_name: "DidomiCM",
  modules: ["ConsentManagementDidomi"],
};

const api = {
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const targets = {
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
