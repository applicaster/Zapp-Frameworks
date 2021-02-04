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
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,

    platform,
    dependency_version: version,
    manifest_version: version,
    api: api[platform],
    npm_dependencies: npm_dependencies[platform],
    dependency_repository_url: dependency_repository_url[platform],
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    project_dependencies: project_dependencies[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };

  return manifest;
}

const api = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {
    class_name: "com.applicaster.reactnative.plugins.APReactNativeAdapter",
    react_packages: [
      "com.theoplayerreactnative.TheoPlayerPackage",
    ],
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
    { "zapp-react-native-theo-player": "./quick_brick/node_modules/@applicaster/zapp-react-native-theo-player/android"},
  ],
};

const npm_dependencies = {
  ios_for_quickbrick: [],
  android_for_quickbrick: []
};

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
