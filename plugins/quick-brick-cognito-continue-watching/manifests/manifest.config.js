const min_zapp_sdk = {
  ios_for_quickbrick: "0.1.0-alpha1",
  android_for_quickbrick: "0.1.0-alpha1",
};

const baseManifest = {
  api: {},
  author_name: "Manuel Pretelin",
  author_email: "m.pretelin@applicaster.com",
  name: "Continue Watching with Cognito Sync",
  description: "",
  screenshots: [],
  identifier: "cw-cognito-sync",
  type: "general",
  whitelisted_account_ids: ["5e257a3fa785570008c18abd"],
  general: {
    fields: [],
  },
  react_native: true,
  ui_builder_support: true,
  preload: true,
  screen: true,
  targets: ["mobile"],
  dependency_name: "@applicaster/quick-brick-cognito-continue-watching",
  ui_frameworks: ["quickbrick"],
};

const custom_configuration_fields = [
  {
    type: "text",
    key: "identity_pool_id",
    tooltip_text: "AWS Cognito Identity Pool ID",
    default: "",
  },
  {
    type: "text",
    key: "region",
    tooltip_text: "AWS Cognito Region",
    default: "",
  },
  {
    type: "text",
    key: "cognito_dataset_name",
    tooltip_text: "AWS Dataset Name",
    default: "",
  },
  {
    type: "text",
    key: "cognito_access_token_key",
    tooltip_text: "LocalStorage Key For Cognito Access Token",
    default: "",
  },
  {
    type: "text",
    key: "cognito_access_token",
    tooltip_text: "Cognito Access Token for debug",
    default: "",
  },
  {
    type: "text",
    key: "cognito_auth_provider_key",
    tooltip_text: "LocalStorage Key For Cognito Provider",
    default: "",
  },
  {
    type: "text",
    key: "cognito_auth_provider",
    tooltip_text: "Cognito Provider value for debug",
    default: "",
  },
];

function createManifest({ platform, version }) {
  return {
    ...baseManifest,
    platform,
    manifest_version: version,
    dependency_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    custom_configuration_fields,
  };
}

module.exports = createManifest;
