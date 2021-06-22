const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/applicaster-cmp-onetrust",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Applicaster OneTrust",
  description: "OneTrust user consent screen",
  type: "general",
  screen: true,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  identifier: "applicaster-cmp-onetrust",
  npm_dependencies: [],
  targets: ["mobile"],
};

const general = {
  fields: [
    // Type text_input
    {
      type: "hidden",
      key: "package_name",
      tooltip_text: "OneTrust Package Name",
      default: "OneTrustBridge",
    },
    // Type text_input
    {
      type: "hidden",
      key: "method_name",
      tooltip_text: "Default Method to Retrieve",
      default: "showPreferences",
    },
    // Type select
    {
      type: "hidden",
      key: "on_dismiss",
      label: "On Dismiss",
      label_tooltip: "On dismiss of native screen do this",
      rules: "conditional",
      options: [
        {
          text: "Navigate to screen",
          value: "screen",
        },
        {
          text: "Navigate to Home",
          value: "home",
        },
        {
          text: "Navigate back",
          value: "back",
        },
      ],
      initial_value: "back",
    },
    // Type screen_selector
    {
      type: "hidden",
      key: "to_screen",
      label: "Dismiss to Screen",
      tooltip_text: "Fallback or navigate to this screen after dismiss of native",
      conditional_fields: [
        {
          key: "styles/title_text_data_key",
          condition_value: "screen",
        },
      ],
    },
  ],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    dependency_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/applicaster-cmp-onetrust@${version}`],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    general,
  };
  return manifest;
}

const custom_configuration_fields_shared = [
  {
    key: "present_on_startup",
    type: "checkbox",
    default: 1,
    label: "Present on startup",
    label_tooltip:
      "If enabled, consent screen will be shown on first application launch",
  },
  {
    key: "domain_identifier",
    type: "text",
    label: "Domain Identifier",
    default: "",
    tooltip_text: "Domain Identifier",
  },
  {
    key: "storage_location",
    type: "text",
    label: "Storage Location",
    default: "cdn.cookielaw.org",
    tooltip_text: "Storage Location",
  }
];

const custom_configuration_fields_apple = custom_configuration_fields_shared.concat(
  [{
    type: "text",
    key: "plist.NSUserTrackingUsageDescription",
    label: "ATT description",
    default: "This identifier will be used to deliver personalized ads to you.",
    tooltip_text: "Please enter the description for ATT"
  }]);

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_shared,
  android_tv_for_quickbrick: custom_configuration_fields_shared,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_shared,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  tvos_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "4.0.0",
  android_tv_for_quickbrick: "4.0.0",
  amazon_fire_tv_for_quickbrick: "4.0.0",
};

const extra_dependencies_apple = {
  ZappCmpOneTrust:
    ":path => './node_modules/@applicaster/applicaster-cmp-onetrust/apple/ZappCmpOneTrust.podspec'",
};

const project_dependencies_android = [
  {
    "applicaster-cmp-didomi":
      "node_modules/@applicaster/applicaster-cmp-onetrust/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_qb,
  tvos_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: true,
  class_name: "OneTrustCmp",
  modules: ["ZappCmpOneTrust"],
};

const api_android = {
  require_startup_execution: true,
  class_name: "com.applicaster.plugin.onetrust.OneTrustPlugin",
  react_packages: ["com.applicaster.plugin.onetrust.reactnative.OneTrustPackage"],
};

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

module.exports = createManifest;
