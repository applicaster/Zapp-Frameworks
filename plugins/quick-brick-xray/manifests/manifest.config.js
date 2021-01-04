const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "X-Ray Logging",
  description: "Enable advanced logging using Applicaster X-Ray",
  type: "error_monitoring",
  identifier: "xray_logging_plugin",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5a364b49e03b2f000d51a0de",
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
    extra_dependencies: extra_dependencies(platform),
    api: api[platform],
    npm_dependencies: [`@applicaster/quick-brick-xray@${version}`].concat(
      extra_npm_dependencies(platform)
    ),
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "dropdown",
    key: "fileLogLevel",
    label: "Log Level",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    label: "Report Email",
    key: "reportEmail",
    type: "text",
    tooltip_text: "Email to send reports to. Empty is allowed.",
  },
  {
    label: "Log File size",
    type: "number_input",
    key: "maxLogFileSizeInMb",
    default: 20,
    tooltip_text: "Max log file size in MB",
  },
];

const custom_configuration_fields_android_mobile = [
  {
    type: "dropdown",
    key: "fileLogLevel",
    label: "Log Level",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    label: "Log File size",
    type: "number_input",
    key: "maxLogFileSizeInMb",
    default: 1,
    tooltip_text: "Max log file size in MB",
  },
  {
    label: "Report Email",
    key: "reportEmail",
    type: "text",
    tooltip_text: "Email to send reports to. Empty is allowed.",
  },
  {
    type: "checkbox",
    label: "Notification controls",
    key: "showNotification",
    default: 1,
    tooltip_text: "Enable notification controls in debug builds",
  },
  {
    type: "checkbox",
    label: "Report crashes",
    key: "crashReporting",
    default: 1,
    tooltip_text: "Enable crash reporting in debug builds",
  },
  {
    type: "checkbox",
    label: "Log react native debug messages",
    key: "reactNativeDebugLogging",
    default: 0,
    tooltip_text:
      "Enable logging or react native internal debug messages. Very verbose!",
  },
];

const custom_configuration_fields_android_tv = [
  {
    type: "dropdown",
    key: "fileLogLevel",
    label: "Log Level",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    key: "reportEmail",
    label: "Report Email",
    type: "text",
    tooltip_text: "Email to send reports to. Empty is allowed.",
  },
  {
    type: "checkbox",
    label: "Report crashes",
    key: "crashReporting",
    default: 1,
    tooltip_text: "Enable crash reporting in debug builds",
  },
  {
    type: "checkbox",
    label: "Log react native debug messages",
    key: "reactNativeDebugLogging",
    default: 0,
    tooltip_text:
      "Enable logging or react native internal debug messages. Very verbose!",
  },
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android_mobile,
  android_tv_for_quickbrick: custom_configuration_fields_android_tv,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_android_tv,
};

const min_zapp_sdk = {
  tvos_for_quickbrick: "2.0.2-dev",
  ios_for_quickbrick: "2.0.2-dev",
  android_for_quickbrick: "0.1.0-alpha1",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = [
  {
    QuickBrickXray:
      ":path => './node_modules/@applicaster/quick-brick-xray/apple/QuickBrickXray.podspec'",
  },
  {
    XrayLogger:
      ":path => './node_modules/@applicaster/x-ray/apple/XrayLogger.podspec'",
  },
  {
    Reporter:
      ":path => './node_modules/@applicaster/x-ray/apple/Reporter.podspec'",
  },
  {
    LoggerInfo:
      ":path => './node_modules/@applicaster/x-ray/apple/LoggerInfo.podspec'",
  },
];

function extra_dependencies(platform) {
  if (
    platform === "ios" ||
    platform === "ios_for_quickbrick" ||
    platform === "tvos" ||
    platform === "tvos_for_quickbrick"
  ) {
    return extra_dependencies_apple;
  }
  return null;
}

function extra_npm_dependencies(platform) {
  if (
    platform === "android_for_quickbrick" ||
    platform === "android_tv_for_quickbrick" ||
    platform === "amazon_fire_tv_for_quickbrick"
  ) {
    return ["@applicaster/x-ray@0.1.3"];
  }
  return [];
}

const project_dependencies_android = [
  {
    "xray-core": "node_modules/@applicaster/x-ray/android/xray-core",
  },
  {
    "xray-react-native":
      "node_modules/@applicaster/x-ray/android/xray-react-native",
  },
  {
    "xray-notification":
      "node_modules/@applicaster/x-ray/android/xray-notification",
  },
  {
    "xray-crashreporter":
      "node_modules/@applicaster/x-ray/android/xray-crashreporter",
  },
  {
    "xray-ui": "node_modules/@applicaster/x-ray/android/xray-ui",
  },
  {
    xrayplugin: "node_modules/@applicaster/quick-brick-xray/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  class_name: "QuickBrickXray",
  modules: ["QuickBrickXray"],
};

const api_android = {
  class_name: "com.applicaster.plugin.xray.XRayPlugin",
  react_packages: ["com.applicaster.xray.reactnative.XRayLoggerPackage"],
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  tvos: api_apple,
  tvos_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  android_for_quickbrick: mobileTarget,
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
