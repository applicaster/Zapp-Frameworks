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
    key: "fileLogLevel",
    tooltip_text: "Minimum message level to log to the file",
    multiple: false,
    options: ["off", "error", "warning", "info", "debug", "verbose"],
    default: "error",
  },
  {
    key: "reportEmail",
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
    tooltip_text: "Enable notification controls in debug builds",
  },
  {
    type: "checkbox",
    label: "Report crashes",
    key: "report_crashes",
    default: 1,
    tooltip_text: "Enable crash reporting in debug builds",
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
function extra_dependencies_apple(xrayLoggerDependency) {
  return [
    {
      QickBrickXray:
        ":path => './node_modules/@applicaster/quick-brick-xray/apple/QickBrickXray.podspec'",
    },
    {
      XrayLogger: xrayLoggerDependency,
    },
    {
      Reporter: xrayLoggerDependency,
    },
    {
      LoggerInfo: xrayLoggerDependency,
    },
  ];
}

function extra_dependencies() {
  const xrayLoggerDependency =
    ":git => 'https://github.com/applicaster/x-ray.git', :tag => '0.0.5-alpha'";
  return {
    ios: extra_dependencies_apple(xrayLoggerDependency),
    ios_for_quickbrick: extra_dependencies_apple(xrayLoggerDependency),
    tvos: extra_dependencies_apple(xrayLoggerDependency),
    tvos_for_quickbrick: extra_dependencies_apple(xrayLoggerDependency),
  };
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
    "xray-reporting":
      "node_modules/@applicaster/x-ray/android/xray-crashreporter",
  },
  {
    xrayplugin: "node_modules/@applicaster/quick-brick-xray/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
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
