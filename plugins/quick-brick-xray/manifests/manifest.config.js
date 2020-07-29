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
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/quick-brick-xray@${version}`],
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "dropdown",
    key: "file_sink",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    key: "report_email",
    type: "text",
    tooltip_text: "Email to send reports to. Empty is allowed.",
  },
];

const custom_configuration_fields_android = [
  {
    type: "dropdown",
    key: "file_sink",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    key: "report_email",
    type: "text",
    tooltip_text: "Email to send reports to. Empty is allowed.",
  },
  {
    type: "checkbox",
    label: "Notification controls",
    key: "notification",
    default: 1,
    tooltip_text: "Enable notification controls",
  },
  {
    type: "checkbox",
    label: "Report crashes",
    key: "report_crashes",
    default: 1,
    tooltip_text: "Enable crash reporting",
  },
  {
    type: "checkbox",
    label: "Log react native debug messages",
    key: "log_react_native_debug",
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
  android_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  tvos: "12.1.0-dev",
  ios: "20.1.0-dev",
  tvos_for_quickbrick: "0.1.0-alpha1",
  ios_for_quickbrick: "0.1.0-alpha1",
  android_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = {
  QickBrickXray:
    ":path => './node_modules/@applicaster/x-ray/apple/QickBrickXray.podspec'",
  XrayLogger:
    "git: 'https://github.com/applicaster/x-ray.git', :tag => '0.0.2-alpha'",
  "XrayLogger/ReactNative":
    "git: 'https://github.com/applicaster/x-ray.git', :tag => '0.0.2-alpha'",
  Reporter:
    "git: 'https://github.com/applicaster/x-ray.git', :tag => '0.0.2-alpha'",
  LoggerInfo:
    "git: 'https://github.com/applicaster/x-ray.git', :tag => '0.0.2-alpha'",
};

const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const project_dependencies_android = {
  xray: "node_modules/@applicaster/x-ray/android/xray",
  "xray-react-native": "node_modules/@applicaster/x-ray/android/react-native",
  xrayplugin: "node_modules/@applicaster/quick-brick-xray/android",
  "xray-notification": "node_modules/@applicaster/x-ray/android/notification",
  "xray-reporting": "node_modules/@applicaster/x-ray/android/crashreporter",
};

const project_dependencies = {
  android_for_quickbrick: [project_dependencies_android],
};

const api_apple = {
  class_name: "QickBrickXray",
  modules: ["QickBrickXray"],
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
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  android_for_quickbrick: mobileTarget,
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
