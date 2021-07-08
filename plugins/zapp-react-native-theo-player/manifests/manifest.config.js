const baseManifest = {
  dependency_name: "@applicaster/zapp-react-native-theo-player",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "THEOplayer QuickBrick",
  description: "Quick Brick THEOplayer plugin",
  type: "player",
  react_native: true,
  identifier: "zapp-react-native-theo-player",
  ui_builder_support: true,
  whitelisted_account_ids: [""],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
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
            initial_value: [],
          },
        ],
      },
    ],
  },
  screen: true,
  custom_configuration_fields: [
    {
      type: "text_input",
      key: "theoplayer_license_key",
      tooltip_text: "Theoplayer licence key",
      default: "",
    },
    {
      type: "tag_select",
      key: "theoplayer_scale_mode",
      tooltip_text: "Set player scale mode",
      options: [
        {
          text: "scale to fit",
          value: "style-fit",
        },
        {
          text: "scale to fill",
          value: "style-fill",
        },
      ],
      initial_value: "style-fit",
    },
    {
      type: "uploader",
      key: "css_url",
      tooltip_text: "Additional CSS file",
    },
    {
      type: "select",
      key: "poster_image_enabled",
      tooltip_text: "Disable poster image if needed",
      options: [
        {
          text: "ENABLED",
          value: "ENABLED",
        },
        {
          text: "DISABLED",
          value: "DISABLED",
        },
      ],
      initial_value: "ENABLED",
    },
    {
      group: true,
      label: "Google IMA",
      tooltip: "Google IMA Settings",
      folded: true,
      fields: [
        {
          text: "ENABLED",
          value: "ENABLED",
        },
        {
          text: "DISABLED",
          value: "DISABLED",
        },
      ],
    },
    {
      group: true,
      label: "Chromecast",
      tooltip: "Chromecast Settings",
      folded: true,
      fields: [
        {
          type: "text_input",
          key: "chromecast_app_id",
          tooltip_text: "Chromecast application ID",
          default: "",
        },
        {
          type: "hidden",
          key: "plist.array.NSBonjourServices",
          initial_value:
            "_[chromecast_app_id]._googlecast._tcp, _googlecast._tcp",
        },
      ],
    },
    {
      group: true,
      label: "Moat Analytics",
      tooltip: "Moat Analytics",
      folded: true,
      fields: [
        {
          type: "text_input",
          key: "moat_partner_code",
          tooltip_text: "Moad partner code",
          default: "",
        },
      ],
    },
    {
      group: true,
      label: "DRM",
      tooltip: "DRM Settings",
      folded: true,
      fields: [
        {
          type: "select",
          key: "drm_enabled",
          tooltip_text: "Disable DRM across the app",
          options: [
            {
              text: "ENABLED",
              value: "ENABLED",
            },
            {
              text: "DISABLED",
              value: "DISABLED",
            },
          ],
          initial_value: "ENABLED",
        },
      ],
    },
  ],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,

    platform,
    dependency_version: version,
    manifest_version: version,
    api: api[platform],
    npm_dependencies: npm_dependencies(version)[platform],
    dependency_repository_url: dependency_repository_url[platform],
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    project_dependencies: project_dependencies[platform],
    custom_configuration_fields: [
      ...baseManifest.custom_configuration_fields,
      ...custom_configuration_fields[platform],
    ],
  };

  return manifest;
}

const api = {
  ios_for_quickbrick: {
    class_name: "THEOplayerAdapter",
    modules: ["ZappTHEOplayer"],
    plist: {
      NSLocalNetworkUsageDescription:
        "App uses the local network to discover Cast-enabled devices on your WiFi network.",
    },
    entitlements: {
      "com.apple.developer.networking.wifi-info": true,
    },
  },
  android_for_quickbrick: {
    class_name: "com.applicaster.reactnative.plugins.APReactNativeAdapter",
    react_packages: ["com.theoplayerreactnative.TheoPlayerPackage"],
  },
};

const min_zapp_sdk = {
  ios_for_quickbrick: "3.0.0-Dev",
  android_for_quickbrick: "3.0.0-dev",
};

const dependency_repository_url = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
};

const project_dependencies = {
  ios_for_quickbrick: {},
  android_for_quickbrick: [
    {
      "zapp-react-native-theo-player":
        "./quick_brick/node_modules/@applicaster/zapp-react-native-theo-player/android",
    },
  ],
};

function npm_dependencies(version) {
  return {
    ios_for_quickbrick: [
      `@applicaster/zapp-react-native-theo-player@${version}`,
    ],
    android_for_quickbrick: [],
  };
}

const custom_configuration_fields = {
  ios_for_quickbrick: [],
  android_for_quickbrick: [],
};

const extra_dependencies = {
  ios_for_quickbrick: [
    {
      ZappTHEOplayer:
        ":path => './node_modules/@applicaster/zapp-react-native-theo-player/apple/ZappTHEOplayer.podspec'",
    },
  ],
  android_for_quickbrick: null,
};

module.exports = createManifest;
