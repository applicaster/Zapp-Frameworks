const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Applicaster Maven S3",
  description: "Plugin allows to use Applicaster S3-hosted Maven artifacts repository to older SDKs",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  core_plugin: false,
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "6.1.0-dev",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  identifier: "applicaster-maven-s3",
  npm_dependencies: [],
  targets: ["mobile", "tv"],
  dependency_repository_url: [{
        url: "https://assets-production.applicaster.com/artifacts/public/",
        content: { includeGroup: "com.applicaster" }
    }, {
      url: "https://assets-production.applicaster.com/artifacts/legacy/maven/",
      content: { includeGroup: "com.applicaster" }
    }
  ]
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
  };
  return manifest;
}

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks_native = ["native"];
const ui_frameworks = {
  android_for_quickbrick: ui_frameworks_qb,
  android_tv_for_quickbrick: ui_frameworks_qb,
  amazon_fire_tv_for_quickbrick: ui_frameworks_qb,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  android_for_quickbrick: mobileTarget,
  android_tv_for_quickbrick: tvTarget,
  amazon_fire_tv_for_quickbrick: tvTarget,
};

module.exports = createManifest;
