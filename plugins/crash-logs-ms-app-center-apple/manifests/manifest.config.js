const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "App Center Crashlogs",
  description: "Zapp Crashlogs Plugin App Center",
  type: "error_monitoring",
  screen: false,
  react_native: false,
  identifier: "crashlogs_appcenter",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  npm_dependencies: [],
  identifier: "crashlogs_appcenter",
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
    npm_dependencies: [
      `@applicaster/crash-logs-ms-app-center-apple@${version}`,
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
  ZappCrashlogsMsAppCenter:
    ":path => './node_modules/@applicaster/crash-logs-ms-app-center-apple/apple/ZappCrashlogsMsAppCenter.podspec'",
};
const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "ZappCrashlogsMsAppCenter",
  modules: ["ZappCrashlogsMsAppCenter"],
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
