const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "X-Ray Logging",
  description: "Enable advanced logging using Applicaster X-Ray",
  type: "error_monitoring",
  identifier: "xray_logging_plugin",
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5a364b49e03b2f000d51a0de"
  ],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
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
    npm_dependencies: [`@applicaster/quick-brick-xray@${version}`],
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
  };
  return manifest;
}

const min_zapp_sdk = {
  android_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = {
};

const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const project_dependencies_android = {
    "xray": "node_modules/@applicaster/x-ray/android/xray",
    "xray-react-native": "node_modules/@applicaster/x-ray/android/react-native",
    "xrayplugin": "node_modules/@applicaster/quick-brick-xray/android",
    "xray-notification": "node_modules/@applicaster/x-ray/android/notification",
    "xray-reporting": "node_modules/@applicaster/x-ray/android/crashreporter"
};

const project_dependencies = {
  android_for_quickbrick: [project_dependencies_android],
};

const api_apple = {
  class_name: "MyPluginManager",
  modules: ["MyPluginModule"],
};

const api_android = {
  class_name: "com.applicaster.plugin.xray.XRayPlugin",
  react_packages: [
    "com.applicaster.xray.reactnative.XRayLoggerPackage",
  ],
};
const api = {
  android_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  android_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
