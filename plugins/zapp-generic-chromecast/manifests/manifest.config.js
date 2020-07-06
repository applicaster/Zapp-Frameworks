const npmDependency = "@applicaster/zapp-generic-chromecast";
const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Chromecast (QB)",
  description:
    "A react native plugin that allows you to add chromecast support to a QuickBrick based project",
  type: "general",
  screen: true,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
    "572a0a65373163000b000000",
  ],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  custom_configuration_fields: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
  identifier: "chromecast_qb",
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    dependency_name: "npmDependency",
    dependency_version: version,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: `${npmDependency}@${version}`,
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos: "12.1.0-dev",
  ios: "20.1.0-dev",
  android: "20.0.0",
  tvos_for_quickbrick: "0.1.0-alpha1",
  ios_for_quickbrick: "0.1.0-alpha1",
  android_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = {
  ZappChromecast: `:path => './node_modules/${npmDependency}/ZappChromecast.podspec'`,
};
const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  class_name: "ChromecastAdapter",
  modules: ["ZappChromecast"],
};
const api_android = {
  class_name: "com.applicaster.chromecast.ChromeCastPlugin",
  react_packages: ["com.reactnative.googlecast.GoogleCastPackage"],
};
const api = {
  ios: [api_apple],
  ios_for_quickbrick: [api_apple],
  tvos: [api_apple],
  tvos_for_quickbrick: [api_apple],
  android: [api_android],
  android_for_quickbrick: [api_android],
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios: [mobileTarget],
  ios_for_quickbrick: [mobileTarget],
  tvos: [tvTarget],
  tvos_for_quickbrick: [tvTarget],
  android: [mobileTarget],
  android_for_quickbrick: [mobileTarget],
};

const project_dependencies_android = {
  "react-native-google-cast": `./node_modules/${npmDependency}/android`,
};
const project_dependencies = {
  android: [project_dependencies_android],
  android_for_quickbrick: [project_dependencies_android],
};

module.exports = createManifest;
