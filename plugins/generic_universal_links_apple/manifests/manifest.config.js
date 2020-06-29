const { updateVersion } = require("./../../Scripts/manifestHelpers.js");

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
    "57c997a8373538000b000000"],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [
    {
      "type": "text",
      "key": "mapping_url",
      "tooltip_text": "Mapping Url"
    }
  ],
  npm_dependencies:[],
  targets: ["mobile"]
};

function createManifest({ identifier, version, platform, appleFrameworkName }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: updateParams({identifier, appleFrameworkName}, extra_dependencies[platform]),
    api: api[platform],
    npm_dependencies: updateParams({identifier, version}, npm_dependencies[platform])
  };
  return manifest;
}
const min_zapp_sdk = {
  ios: "20.0.0-Dev",
  ios_for_quickbrick: "0.1.0-alpha1"
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
  ]
};

const api_apple = {
  "api": {
    "require_startup_execution": true,
    "class_name": "ZPAppleGenericUniversalLinks",
    "modules": [
      "ZappAppleGenericUniversalLinks"
    ]
  }
};

const api = {
  ios: [
    api_apple,
  ],
  ios_for_quickbrick: [
    api_apple
  ],
  tvos: [
    api_apple
  ],
  tvos_for_quickbrick: [
    api_apple
  ]
};

const npm_dependencies_apple = {
  "@applicaster/##identifier##@##version##"
};
const npm_dependencies = {
  ios: [
    npm_dependencies_apple
  ],
  ios_for_quickbrick: [
    npm_dependencies_apple
  ],
  tvos: [
    npm_dependencies_apple
  ],
  tvos_for_quickbrick: [
    npm_dependencies_apple
  ]
};

module.exports = createManifest;
