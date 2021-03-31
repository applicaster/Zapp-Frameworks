const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Quick Brick Player Plugin Background Mode",
  description:
    "This plugin enables background mode in quick brick default player plugin",
  type: "general",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  ui_frameworks: ["quickbrick"],
  core_plugin: true,
  min_zapp_sdk: "3.0.0-Dev",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  custom_configuration_fields: [
    {
      key: "nowPlayingEnabled",
      label: "Now Playing enabled",
      initial_value: true,
      type: "checkbox",
      label_tooltip: "Disable if you do not want audio on background",
    },
    {
      key: "pictureInPictureEnabled",
      label: "Picture and picture enabled",
      initial_value: false,
      type: "checkbox",
      label_tooltip:
        "Disable if you don't want to present video when application on background",
    },
  ],
  export: {
    allowed_list: [
      {
        identifier: "QuickBrickPlayerPlugin",
        section: "custom_configuration_fields",
        allowed_fields: [
          {
            section: "custom_configuration_fields",
            key: "nowPlayingEnabled",
          },
          {
            section: "custom_configuration_fields",
            key: "pictureInPictureEnabled",
          },
        ],
      },
    ],
  },
  identifier: "zapp-default-player-background-mode",
  npm_dependencies: [],
  targets: ["mobile"],
};

function createManifest({ version, platform }) {
  console.log({ version, platform });
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
  };
  return manifest;
}

module.exports = createManifest;
