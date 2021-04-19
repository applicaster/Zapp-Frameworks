const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "App Center Crashlogs",
  description: "Zapp Crashlogs Plugin App Center",
  type: "error_monitoring",
  screen: false,
  react_native: true, // needed for android rake
  identifier: "crashlogs_appcenter",
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "4.0.0",
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
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [
      `@applicaster/crash-logs-ms-app-center-android@${version}`,
    ],
    targets: targets[platform],
  };
  return manifest;
}

const min_zapp_sdk = {
  android_for_quickbrick: "4.0.0",
  android_tv_for_quickbrick: "4.0.0",
  amazon_fire_tv_for_quickbrick: "4.0.0",
};

const project_dependencies_android = [
  {
    "crash-logs-ms-app-center-android": "node_modules/@applicaster/crash-logs-ms-app-center-android/android",
  }
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_android = {
  class_name: "com.applicaster.crashlog.AppCenterCrashlog",
};

const api = {
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;

