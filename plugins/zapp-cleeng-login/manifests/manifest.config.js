const baseManifest = {
  dependency_name: "@applicaster/zapp-cleeng-login",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Quick Brick Cleeng login",
  description: "Quick Brick Cleeng login",
  type: "login",
  react_native: true,
  identifier: "zapp-cleeng-login",
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
  android_for_quickbrick: {},
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.1.0-Dev",
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
  ios_for_quickbrick: [],
  android_for_quickbrick: [],
};
const extra_dependencies = {
  ios_for_quickbrick: [
    {
    },
  ],
  android_for_quickbrick: null,
};
module.exports = createManifest;
