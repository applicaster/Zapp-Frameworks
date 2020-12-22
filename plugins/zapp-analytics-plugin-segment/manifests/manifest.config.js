const baseManifest = {
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Segment Analytics",
  identifier: "segment_analytics",
  description: "Segment Analytics",
  type: "analytics",
  react_native: true,
  custom_configuration_fields: [
    {
      section: "configuration",
      type: "text",
      key: "write_key",
      tooltip_text: "The key used for connecting with segment analytics",
      default: "",
    },
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
      `@applicaster/zapp-analytics-plugin-segment@${version}`,
    ]
  };
  return manifest;
}

const min_zapp_sdk = {
  amazon_fire_tv_for_quickbrick: "2.0.0",
  android_tv_for_quickbrick: "2.0.0",
  android_for_quickbrick: "2.0.0",
  ios_for_quickbrick: "2.0.2-Dev",
  tvos_for_quickbrick: "2.0.2-Dev"
};

const extra_dependencies_apple = [
  {
    SegmentAnalytics:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-segment/apple/SegmentAnalytics.podspec'",
  },
];

const extra_dependencies = {
  tvos_for_quickbrick: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
};

const android_project_dependencies = [
  {
    "zapp-analytics-plugin-segment":
      "node_modules/@applicaster/zapp-analytics-plugin-segment/android",
  },
]

const project_dependencies = {
  android_for_quickbrick: android_project_dependencies,
  android_tv_for_quickbrick: android_project_dependencies,
  amazon_fire_tv_for_quickbrick: android_project_dependencies
};

const api_android = {
  "require_startup_execution": false,
  "class_name": "com.applicaster.analytics.segment.SegmentAgent",
  "react_packages": [
    "com.applicaster.analytics.segment.CustomSegmentAPIPackage"
  ]
}

const api_apple = {
  require_startup_execution: false,
  class_name: "SegmentAnalytics",
  modules: ["SegmentAnalytics"]
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
