const baseManifest = {
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Gemius Analytics",
  identifier: "gemius_analytics",
  description: "Gemius Analytics",
  type: "analytics",
  react_native: true,
  custom_configuration_fields: [
    {
      section: "configuration",
      type: "text",
      key: "script_identifier",
      tooltip_text: "Script Identifier",
      default: "",
    },
    {
      section: "configuration",
      type: "text",
      key: "hit_collector_host",
      tooltip_text: "Collector Host",
      default: "",
    }
  ],
  whitelisted_account_ids: [],
  ui_builder_support: false,
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    min_zapp_sdk: min_zapp_sdk[platform],
    manifest_version: version,
    project_dependencies: project_dependencies[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    targets: targets[platform],
    npm_dependencies: [
      `@applicaster/zapp-analytics-plugin-gemius@${version}`,
    ]
  };
  return manifest;
}

const min_zapp_sdk = {
  amazon_fire_tv_for_quickbrick: "4.0.0",
  android_tv_for_quickbrick: "4.0.0",
  android_for_quickbrick: "4.0.0",
  ios_for_quickbrick: "4.1.0-Dev",
  tvos_for_quickbrick: "4.1.0-Dev"
};

const extra_dependencies_apple = [
  {
    GemiusAnalytics:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-gemius/apple/GemiusAnalytics.podspec'",
  },
];

const extra_dependencies = {
  tvos_for_quickbrick: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
};

const android_project_dependencies = [
  {
    "zapp-analytics-plugin-gemius":
      "node_modules/@applicaster/zapp-analytics-plugin-gemius/android",
  },
]

const project_dependencies = {
  android_for_quickbrick: android_project_dependencies,
  android_tv_for_quickbrick: android_project_dependencies,
  amazon_fire_tv_for_quickbrick: android_project_dependencies
};

const api_android = {
  "class_name": "com.applicaster.analytics.gemius.GemiusAgent",
}

const api_apple = {
  require_startup_execution: false,
  class_name: "GemiusAnalytics",
  modules: ["GemiusAnalytics"]
};

const api = {
  amazon_fire_tv_for_quickbrick: api_android,
  android_tv_for_quickbrick: api_android,
  android_for_quickbrick: api_android,
  ios_for_quickbrick: api_apple,
  tvos_for_quickbrick: api_apple
};

const mobileTarget = ["mobile"];
const tvTarget = ["tv"];

const targets = {
  amazon_fire_tv_for_quickbrick: tvTarget,
  android_tv_for_quickbrick: tvTarget,
  android_for_quickbrick: mobileTarget,
  ios_for_quickbrick: mobileTarget,
  tvos_for_quickbrick: tvTarget
};

module.exports = createManifest;
