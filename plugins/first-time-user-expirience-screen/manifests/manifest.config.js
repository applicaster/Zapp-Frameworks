const R = require("ramda");

const baseManifest = {
  dependency_name: "@applicaster/first-time-user-expirience-screen",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "First time user expirience screen",
  description: "Hook to present one time",
  type: "General",
  react_native: true,
  screen: true,
  identifier: "first-time-user-expirience-screen",
  ui_builder_support: true,
  whitelisted_account_ids: [""],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  preload: true,
  custom_configuration_fields: [],
  hooks: {
    fields: [
      {
        group: true,
        label: "Before Load",
        folded: true,
        fields: [
          {
            key: "preload_plugins",
            type: "preload_plugins_selector",
            label: "Select Plugins",
          },
        ],
      },
    ],
  },
  ui_frameworks: ["quickbrick"],
};

const styles = {
  fields: [
    {
      key: "background_color",
      type: "color_picker",
      label: "Background font color",
      initial_value: "#161b29ff",
    },
  ],
};

const androidPlatforms = [
  "android_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
];

const webPlatforms = ["samsung_tv", "lg_tv"];

const applePlatforms = ["ios_for_quickbrick", "tvos_for_quickbrick"];

const tvPlatforms = [
  "tvos_for_quickbrick",
  "android_tv_for_quickbrick",
  "amazon_fire_tv_for_quickbrick",
  "samsung_tv",
];

const api = {
  default: {},
  web: {
    excludedNodeModules: [],
  },
  android: {},
};

const project_dependencies = {
  default: [],
  android: [],
};

const extra_dependencies = {
  apple: [],
  default: [],
};

const npm_dependencies = {
  default: [],
  web: [],
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
  android_for_quickbrick: "0.1.0-alpha1",
  tvos_for_quickbrick: "4.1.0-Dev",
  android_tv_for_quickbrick: "0.1.0-alpha1",
  amazon_fire_tv_for_quickbrick: "0.1.0-alpha1",
  samsung_tv: "1.2.2",
  lg_tv: "1.0.0",
};

const isApple = R.includes(R.__, applePlatforms);
const iAndroid = R.includes(R.__, androidPlatforms);
const isWeb = R.includes(R.__, webPlatforms);

const withFallback = (obj, platform) => obj[platform] || obj["default"];

function createManifest({ version, platform }) {
  const basePlatform = R.cond([
    [isApple, R.always("apple")],
    [iAndroid, R.always("android")],
    [isWeb, R.always("web")],
  ])(platform);

  const isTV = R.includes(platform, tvPlatforms);

  return {
    ...baseManifest,
    platform,
    dependency_version: version,
    manifest_version: version,
    api: withFallback(api, basePlatform),
    project_dependencies: withFallback(project_dependencies, basePlatform),
    extra_dependencies: withFallback(extra_dependencies, basePlatform),
    min_zapp_sdk: withFallback(min_zapp_sdk, platform),
    npm_dependencies: withFallback(npm_dependencies, basePlatform),
    styles: styles,
    targets: isTV ? ["tv"] : ["mobile"],
    data: {
      fields: [
        {
          key: "source",
          type: "text_input",
        },
        {
          key: "type",
          type: "select",
          options: [],
        },
      ],
    },
    general: {
      fields: [
        {
          key: "identifier",
          type: "text_input",
          disableField: true,
        },
        {
          type: "text_input",
          key: "transition_type",
          initial_value: "modal",
          disableField: true,
        },
        {
          type: "switch",
          key: "show_hook_once",
          tooltip_text:
            "Define if hook should be presented on time or each time screen will open",
          initial_value: true,
        },
        {
          type: "screen_selector",
          key: "fallback",
          tooltip_text: "Screen that will be presented",
        },
      ],
    },
  };
}
module.exports = createManifest;
