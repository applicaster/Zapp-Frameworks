const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Applicaster DI",
  description: "The DI plugin allows, when enabled, to send the device country for Pipes2 endpoints that  require it. Its main purpose is to hide/show content on feed according to the user's country (Geo-Blocking).",
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
  identifier: "di_manager_call",
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
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/applicaster-di-manager@${version}`],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    react_native: isAndroidPlatform(platform), // hack since otherwise rake won't add project
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
    key: "wait_for_completion",
    type: "checkbox",
    default: 1,
    label: "Block UI until completed",
    label_tooltip:
      "Disable if you don't want to block UI until process completions",
  },
  {
    key: "di_server_url",
    type: "text",
    label: "Di Server url",
    default: "https://di.applicaster.com",
    tooltip_text: "Set Di Server Url"
  }
];

const custom_configuration_fields_android = custom_configuration_fields_apple

const custom_configuration_fields = {
  ios_for_quickbrick: [custom_configuration_fields_apple],
  tvos_for_quickbrick: [custom_configuration_fields_apple],
  android_for_quickbrick: custom_configuration_fields_android,
  android_tv_for_quickbrick: custom_configuration_fields_android,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "3.0.0-Dev",
  tvos_for_quickbrick: "3.0.0-Dev",
  android_for_quickbrick: "2.0.0",
  android_tv_for_quickbrick: "2.0.0",
  amazon_fire_tv_for_quickbrick: "2.0.0",
};

const extra_dependencies_apple = {
  ZappDiManager:
    ":path => './node_modules/@applicaster/applicaster-di-manager/apple/ZappDiManager.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks_native = ["native"];
const ui_frameworks = {
  ios: ui_frameworks_native,
  ios_for_quickbrick: ui_frameworks_qb,
  tvos_for_quickbrick: ui_frameworks_qb,
  android_for_quickbrick: ui_frameworks_qb,
  android_tv_for_quickbrick: ui_frameworks_qb,
  amazon_fire_tv_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const project_dependencies_android = [
  {
    "applicaster-di-manager": "node_modules/@applicaster/applicaster-di-manager/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "ZPDiManager",
  modules: ["ZappDiManager"],
};

const api_android = {
    require_startup_execution: true,
    class_name: "com.applicaster.plugin.dimanager.DIManager",
}

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
    android_for_quickbrick: api_android,
    android_tv_for_quickbrick: api_android,
    amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

function isAndroidPlatform(platform) {
  return (
    "android_for_quickbrick" === platform ||
    "android_tv_for_quickbrick" === platform ||
    "amazon_fire_tv_for_quickbrick" === platform
  );
}

module.exports = createManifest;
