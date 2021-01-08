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
  const basePlatform = platform.includes("ios") ? "ios" : "android";

  const manifest = {
    ...baseManifest,

    platform,
    dependency_version: version,
    manifest_version: version,
    api: api[basePlatform],
    npm_dependencies: npm_dependencies[basePlatform],
    dependency_repository_url: dependency_repository_url[basePlatform],
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[basePlatform],
    project_dependencies: project_dependencies[basePlatform],
    custom_configuration_fields: custom_configuration_fields[basePlatform],
  };

  return manifest;
}
const api = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
};

const min_zapp_sdk = {
  ios_for_quickbrick: "3.0.0-Dev",
  android_for_quickbrick: "20.0.0",
};

const dependency_repository_url = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
};

const project_dependencies = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
};

const npm_dependencies = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
};

const custom_configuration_fields = {
  ios_for_quickbrick: {},
  android_for_quickbrick: {},
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
