const { updateVersion } = require("./../../Scripts/manifestHelpers.js");

const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Generic Local Notifications",
  description: "Generic Local Notifications",
  type: "general",
  screen: false,
  react_native: false,
  identifier: "generic_local_notifications",
  ui_builder_support: true,
  whitelisted_account_ids: ["5e39259919785a0008225336"],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: true,
  custom_configuration_fields: [],
  npm_dependencies:[],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"]
};

function createManifest({ identifier, version, platform, appleFrameworkName }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: updateParams({identifier, appleFrameworkName}, extra_dependencies[platform]),
    api: api[platform],
    npm_dependencies: updateParams({identifier, version}, npm_dependencies[platform]),
    project_dependencies: updateParams({identifier}, project_dependencies[platform]),
    targets: targets[platform]
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
  "##appleFrameworkName##": ":path => './node_modules/@applicaster/##identifier##/##appleFrameworkName##.podspec'"
};
const extra_dependencies = {
  ios: [
    extra_dependencies_apple
  ],
  ios_for_quickbrick: [
    extra_dependencies_apple
  ],
  tvos: [
    extra_dependencies_apple
  ],
  tvos_for_quickbrick: [
    extra_dependencies_apple
  ]
};

const project_dependencies_android = {
  "generic_local_notifications": "node_modules/@applicaster/##identifier##/Android"
};
const project_dependencies = {
  android: [
    project_dependencies_android
  ],
  android_for_quickbrick: [
    project_dependencies_android
  ]
}

const api_apple = {
  "class_name": "LocalNotificationManager",
  "modules": [
    "ZappLocalNotifications"
  ]
};
const api_android = {
  "class_name": "com.applicaster.reactnative.plugins.APReactNativeAdapter",
  "react_packages": [
    "com.applicaster.localnotifications.reactnative.LocalNotificationPackage"
  ]
};
const api = {
  ios: [
    api_apple
  ],
  ios_for_quickbrick: [
    api_apple
  ],
  tvos: [
    api_apple
  ],
  tvos_for_quickbrick: [
    api_apple
  ],
  android: [
    api_android
  ],
  android_for_quickbrick: [
    api_android
  ]
};

const npm_dependencies_mobile = {
  "@applicaster/##identifier##@##version##"
};
const npm_dependencies = {
  ios: [
    npm_dependencies_mobile
  ],
  ios_for_quickbrick: [
    npm_dependencies_mobile
  ],
  tvos: [
    npm_dependencies_mobile
  ],
  tvos_for_quickbrick: [
    npm_dependencies_mobile
  ],
  android: [
    npm_dependencies_mobile
  ],
  android_for_quickbrick: [
    npm_dependencies_mobile
  ]
};

const mobileTarget = ["mobile"]
const tvTarget = ["tv"]
const targets = {
  ios: [
    mobileTarget
  ],
  ios_for_quickbrick: [
    mobileTarget
  ],
  tvos: [
    tvTarget
  ],
  tvos_for_quickbrick: [
    tvTarget
  ],
  android: [
    mobileTarget
  ],
  android_for_quickbrick: [
    mobileTarget
  ]
};

module.exports = createManifest;
