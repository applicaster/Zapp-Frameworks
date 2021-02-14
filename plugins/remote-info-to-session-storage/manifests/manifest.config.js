const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Store Remote Info in Session Storage",
  description: "Store remote info (key/value (s)) into session storage for specified namespace",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  core_plugin: true,
  min_zapp_sdk: "1.0.0",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [],
  identifier: "remote_info_to_session_storage",
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
    project_dependencies: project_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/remote-info-to-session-storage@${version}`],
    targets: targets[platform],
    ui_frameworks: ui_frameworks[platform],
    custom_configuration_fields: custom_configuration_fields[platform]
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    key: "enabled",
    type: "checkbox",
    default: 1,
    label: "Plugin enabled",
    label_tooltip:
      "Disable plugin if you do not want to use plugin",
  },
  {
    key: "wait_for_completion",
    type: "checkbox",
    default: 1,
    label: "Block UI until completed",
    label_tooltip:
      "Disable if you don't want to block UI until process completions",
  },
  {
    key: "remote_url",
    type: "text",
    label: "Remote Url",
    default: "",
    tooltip_text: "Set Remote Url"
  },
  {
    key: "namespace",
    type: "text",
    label: "Namespace",
    default: "",
    tooltip_text: "Set namespace for the remote content"
  }
];

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
};

const min_zapp_sdk = {
  ios_for_quickbrick: "4.0.0-Dev",
  tvos_for_quickbrick: "4.0.0-Dev",
};

const extra_dependencies_apple = {
  ZappRemoteInfoToSessionStorage:
    ":path => './node_modules/@applicaster/remote-info-to-session-storage/apple/ZappRemoteInfoToSessionStorage.podspec'",
};

const ui_frameworks_qb = ["quickbrick"];
const ui_frameworks_native = ["native"];
const ui_frameworks = {
  ios_for_quickbrick: ui_frameworks_qb,
  tvos_for_quickbrick: ui_frameworks_qb,
};

const extra_dependencies = {
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "ZPRemoteInfoToSessionStorage",
  modules: ["ZappRemoteInfoToSessionStorage"],
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
