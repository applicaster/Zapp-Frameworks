const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Apple User Activity",
  description: "Enable user activity object for the presented show screen",
  type: "general",
  identifier: "apple-user-activity",
  dependency_name: "@applicaster/quick-brick-apple-user-activity",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5a364b49e03b2f000d51a0de",
  ],
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    dependency_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies(platform),
    api: api[platform],
    npm_dependencies: [
      `@applicaster/quick-brick-apple-user-activity@${version}`,
    ].concat(extra_npm_dependencies(platform)),
    targets: targets[platform],
  };
  return manifest;
}

const min_zapp_sdk = {
  tvos_for_quickbrick: "1.0.0",
  ios_for_quickbrick: "1.0.0",
};

const extra_dependencies_apple = [
  {
    AppleUserActivity:
      ":path => './node_modules/@applicaster/quick-brick-apple-user-activity/apple/AppleUserActivity.podspec'",
  },
];

function extra_dependencies(platform) {
  if (platform === "ios_for_quickbrick" || platform === "tvos_for_quickbrick") {
    return extra_dependencies_apple;
  }
  return null;
}

function extra_npm_dependencies(platform) {
  return [];
}

const api_apple = {
  class_name: "UserActivityHandler",
  modules: ["AppleUserActivity"],
  plist: {
    NSUserActivityTypes: ["qb.screen.useractivity.details"]
  }
};

const api = {
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
