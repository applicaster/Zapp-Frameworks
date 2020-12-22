const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Generic Universal Links",
  description: "Generic Universal Links plugin",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
    "5c20970320f1c500088842dd",
    "57c997a8373538000b000000",
  ],
  ui_frameworks: ["quickbrick"],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [
    {
      type: "text",
      key: "mapping_url",
      tooltip_text: "Mapping Url",
    },
  ],
  identifier: "generic_universal_links_apple",
  npm_dependencies: [],
  targets: ["mobile"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/generic_universal_links_apple@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  ios_for_quickbrick: "2.0.2-Dev",
  tvos_for_quickbrick: "2.0.2-Dev",
};

const extra_dependencies_apple = {
  ZappAppleGenericUniversalLinks:
    ":path => './node_modules/@applicaster/generic_universal_links_apple/apple/ZappAppleGenericUniversalLinks.podspec'",
};
const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: true,
  class_name: "ZPAppleGenericUniversalLinks",
  modules: ["ZappAppleGenericUniversalLinks"],
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
