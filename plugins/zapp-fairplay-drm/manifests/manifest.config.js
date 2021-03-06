const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "FairPlay DRM",
  description: "FairPlay DRM provider",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "5ae06cef8fba0f00084bd3c6",
  ],
  ui_frameworks: ["quickbrick"],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [
    {
      type: "text",
      key: "certificate_url",
      tooltip_text: "Certificate Url",
    },
    {
      type: "text",
      key: "license_server_url",
      tooltip_text: "License Server Url",
    },
    {
      type: "text",
      key: "license_server_request_content_type",
      tooltip_text: "License server request content type",
      default: "application/json",
    },
    {
      type: "text",
      key: "license_server_request_json_object_key",
      tooltip_text: "License server request json object key",
      default: "server_playback_context",
    },
  ],
  identifier: "generic_drm_apple",
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
    npm_dependencies: [`@applicaster/zapp-fairplay-drm@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  ios_for_quickbrick: "3.0.0-Dev",
  tvos_for_quickbrick: "3.0.0-Dev",
};

const extra_dependencies_apple = {
  ZappFairPlayDrm:
    ":path => './node_modules/@applicaster/zapp-fairplay-drm/apple/ZappFairPlayDrm.podspec'",
};
const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "ZPFairPlayDrm",
  modules: ["ZappFairPlayDrm"],
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
