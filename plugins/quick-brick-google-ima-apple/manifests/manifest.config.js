const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Google Interactive Media Ads QuickBrick",
  description:
    "This plugin allow to add Google Interactive Media Ads to supported players.",
  type: "video_advertisement",
  screen: false,
  react_native: false,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5ae06cef8fba0f00084bd3c6",
  ],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  npm_dependencies: [],
  identifier: "zapp_google_interactive_media_ads",
  targets: ["mobile"],
  custom_configuration_fields: [
    {
      type: "text",
      key: "tag_vmap_url",
      tooltip_text: "VMAP URL",
      default: "",
    },
    {
      type: "text",
      key: "tag_preroll_url",
      tooltip_text: "Preroll URL",
      default: "",
    },
    {
      type: "text",
      key: "tag_postroll_url",
      tooltip_text: "Postroll URL",
      default: "",
    },
    {
      type: "text",
      key: "tag_midroll_url",
      tooltip_text: "Midroll URL",
      default: "",
    },
    {
      type: "text",
      key: "midroll_offset",
      tooltip_text: "Midroll offset",
      default: "",
    },
    {
      type: "checkbox",
      key: "disable_personalized_advertising",
      tooltip_text: "TFUA param to disable personalized advertising",
      default: 0,
    },
  ],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/quick-brick-google-ima-apple@${version}`],
    targets: targets[platform],
  };
  return manifest;
}
const min_zapp_sdk = {
  tvos: "12.0.0-Dev",
  ios: "20.0.0-Dev",
  tvos_for_quickbrick: "0.1.0-alpha1",
  ios_for_quickbrick: "0.1.0-alpha1",
};

const extra_dependencies_apple = {
  ZappGoogleInteractiveMediaAds:
    ":path => './node_modules/@applicaster/quick-brick-google-ima-apple/apple/ZappGoogleInteractiveMediaAds.podspec'",
};
const extra_dependencies = {
  ios: [extra_dependencies_apple],
  ios_for_quickbrick: [extra_dependencies_apple],
  tvos: [extra_dependencies_apple],
  tvos_for_quickbrick: [extra_dependencies_apple],
};

const api_apple = {
  require_startup_execution: false,
  class_name: "GoogleInteractiveMediaAdsAdapter",
  modules: ["ZappGoogleInteractiveMediaAds"],
  plist: {
    "SKAdNetworkItems": [
      {
        "SKAdNetworkIdentifier": "cstr6suwn9.skadnetwork"
      }
    ]
  }
};

const api = {
  ios: api_apple,
  ios_for_quickbrick: api_apple,
  tvos: api_apple,
  tvos_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];
const targets = {
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos: tvTarget,
  tvos_for_quickbrick: tvTarget,
};

module.exports = createManifest;
