const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/applicaster-cmp-didomi",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Applicaster Didomi",
  description: "Didomi user consent screen",
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
  identifier: "applicaster-cmp-didomi",
  npm_dependencies: [],
  targets: ["mobile"],
};

const general = {
  fields: [
    // Type text_input
    {
      type: "hidden",
      key: "package_name",
      tooltip_text: "Didomi Package Name",
      default: "DidomiBridge",
    },
    // Type text_input
    {
      type: "hidden",
      key: "method_name",
      tooltip_text: "Default Method to Retreive",
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
    npm_dependencies: [`@applicaster/applicaster-cmp-didomi@${version}`],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    general,
  };
  return manifest;
}

const custom_configuration_fields = [
  {
    key: "present_on_startup",
    type: "checkbox",
    default: 1,
    label: "Present on startup",
    label_tooltip:
      "If enabled, consent screen will be shown on first application launch",
  },
  {
    key: "api_key",
    type: "text",
    label: "API key",
    default: "",
    tooltip_text: "API key",
  }
];

const custom_configuration_fields_apple = custom_configuration_fields.concat(
  [{
    key: "ios_assets_bundle",
    type: "uploader",
    label: "Logo drawables zip",
    label_tooltip: "Please upload a zip file to provide the logo assets for this plugin. File name must match json override in the Didomi web console"
  }]);

const custom_configuration_fields_android = custom_configuration_fields.concat(
    [{
      "key": "android_assets_bundle",
      "type": "uploader",
      "label": "Logo drawables zip",
      "label_tooltip": "Please upload a zip file to provide the logo assets for this plugin. File name must match json override in the Didomi web console"
    }]);

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
  android_tv_for_quickbrick: custom_configuration_fields_android,
  amazon_fire_tv_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "4.0.0",
  android_tv_for_quickbrick: "4.0.0",
  amazon_fire_tv_for_quickbrick: "4.0.0",
};

const extra_dependencies_apple = {
  ZappCMPDidomi:
    ":path => './node_modules/@applicaster/applicaster-cmp-didomi/apple/ZappCMPDidomi.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_qb,
  android_for_quickbrick: ui_frameworks_qb,
  android_tv_for_quickbrick: ui_frameworks_qb,
  amazon_fire_tv_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
};

const project_dependencies_android = [
  {
    "applicaster-cmp-didomi":
      "node_modules/@applicaster/applicaster-cmp-didomi/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
  android_tv_for_quickbrick: project_dependencies_android,
  amazon_fire_tv_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  require_startup_execution: true,
  class_name: "DidomiCMP",
  modules: ["ZappCMPDidomi"],
  plist: {
    NSUserTrackingUsageDescription:
      "This identifier will be used to deliver personalized ads to you.",
  },
};

const api_android = {
  require_startup_execution: true,
  class_name: "com.applicaster.plugin.didomi.DidomiPlugin",
  react_packages: ["com.applicaster.plugin.didomi.reactnative.DidomiPackage"],
};

const api = {
  ios_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  amazon_fire_tv_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios_for_quickbrick: mobileTarget,
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
