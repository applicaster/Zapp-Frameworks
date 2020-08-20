const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Firebase Notifications",
  description: "Send high-velocity targeted push via Google's Firebase Notifications Console",
  cover_image: "https://res.cloudinary.com/dtiodujtz/image/upload/v1552096080/Plugins/Firebase_Push1.png",
  type: "push_provider",
  identifier: "ZappPushPluginFirebase",
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
    npm_dependencies: [`@applicaster/zapp-push-plugin-firebase@${version}`],
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [];

const custom_configuration_fields_android = [];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  android_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = [];

const extra_dependencies = {
  ios: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
  tvos: extra_dependencies_apple,
  tvos_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-push-plugin-firebase": "node_modules/@applicaster/zapp-push-plugin-firebase/android",
  }
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
};


const api_android = {
  class_name: "com.applicaster.firebasepushpluginandroid.FirebasePushProvider",
};

const api = {
  android_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];
const targets = {
  android_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
