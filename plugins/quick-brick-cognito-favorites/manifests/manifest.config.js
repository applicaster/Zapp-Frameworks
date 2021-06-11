const min_zapp_sdk = {
  ios_for_quickbrick: "4.0.0-rc",
  android_for_quickbrick: "4.0.0",
};

const baseManifest = {
  api: {},
  dependency_repository_url: [],
  dependency_name: "@applicaster/quick-brick-cognito-favorites",
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Quick Brick Cognito Favorites",
  description: "Quick Brick plugin for Cognito Favorites",
  type: "general",
  react_native: true,
  identifier: "cognito-favorites",
  ui_builder_support: true,
  whitelisted_account_ids: ["5e132c906663330008c0f8ab"],
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  general: {},
  ui_frameworks: ["quickbrick"],
  custom_configuration_fields: [
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
      key: "cognito_dataset_key",
      tooltip_text: "AWS Favorites Dataset Key",
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
  ],
};

const MOBILE_PLATFORMS = ["ios_for_quickbrick", "android_for_quickbrick"];

const target = (platform) =>
  MOBILE_PLATFORMS.includes(platform) ? ["mobile"] : ["tv"];

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    dependency_version: version,
    manifest_version: version,
    targets: target(platform),
    min_zapp_sdk: min_zapp_sdk[platform] || "1.0.0",
  };

  return manifest;
}

module.exports = createManifest;
