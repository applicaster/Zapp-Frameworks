const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Google Analytics for Firebase",
  description:
    "Google's free, deep, and broadly integrated analytics system designed specifically for mobile. Please do not populate the user id field unless your app is legally authorised (for further information, please reach support).",
  cover_image:
    "https://res.cloudinary.com/dtiodujtz/image/upload/v1553522185/Plugins/GAforFirebase.jpg",
  type: "analytics",
  identifier: "firebase",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
  preload: false,
  custom_configuration_fields: [],
  targets: ["mobile"],
  ui_frameworks: ["quickbrick"],
};

function createManifest({ version, platform }) {
  const manifest = {
    ...baseManifest,
    platform,
    manifest_version: version,
    min_zapp_sdk: min_zapp_sdk[platform],
    extra_dependencies: extra_dependencies[platform],
    api: api[platform],
    npm_dependencies: [`@applicaster/zapp-analytics-plugin-firebase@${version}`],
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    ui_frameworks: ui_frameworks[platform],
  };
  return manifest;
}

const custom_configuration_fields_apple = [
  {
    type: "checkbox",
    key: "Send_User_Data",
    label: "Send User Data",
    default: 1,
    tooltip_text: "Sends any user data collected in the app. Per Google&apos;s policies, we will not send any user data identified as PII (Personally Identifiable Information)."
  },
  {
    type: "text",
    key: "user_id",
    label: "User ID",
    tooltip_text: "Please do not populate the user id field unless your app is legally authorised (for further information, please reach support)."
  }
];

const custom_configuration_fields_android = [
  {
    type: "checkbox",
    label: "Send User Data",
    key: "Send_User_Data",
    default: 1,
    tooltip_text: "Sends any user data collected in the app. Per Google&apos;s policies, we will not send any user data identified as PII (Personally Identifiable Information)."
  },
  {
    type: "text",
    label: "User Id",
    key: "user_id",
    tooltip_text: "Please do not populate the user id field unless your app is legally authorised (for further information, please reach support)."
  }
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
};

const ui_frameworks_native = ["native"];
const ui_frameworks_quickbrick = ["quickbrick"];

const ui_frameworks = {
  ios: ui_frameworks_native,
  ios_for_quickbrick: ui_frameworks_quickbrick,
  android_for_quickbrick: ui_frameworks_quickbrick,
};

const min_zapp_sdk = {
  android_for_quickbrick: "1.0.0",
  ios_for_quickbrick: "2.0.2-Dev"
};

const extra_dependencies_apple = [
  {
    ZappAnalyticsPluginFirebase:
      ":path => './node_modules/@applicaster/zapp-analytics-plugin-firebase/apple/ZappAnalyticsPluginFirebase.podspec'",
  },
];

const extra_dependencies = {
  ios: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-analytics-plugin-firebase":
      "node_modules/@applicaster/zapp-analytics-plugin-firebase/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
};

const api_android = {
  class_name: "applicaster.analytics.firebase.FirebaseAgent",
  proguard_rules: "-keep public class applicaster.analytics.firebase.FirebaseAgent{public \u003cfields\u003e;public \u003cmethods\u003e;} -keep public class com.akamai.** {public \u003cfields\u003e; public \u003cmethods\u003e;}",
  require_startup_execution: false
};

const api_apple = {
  require_startup_execution: true,
  class_name: "APAnalyticsProviderFirebase",
  modules: ["ZappAnalyticsPluginFirebase"],
  plist: {
    NSUserTrackingUsageDescription:
      "This identifier will be used to deliver personalized ads to you.",
  },
};

const api = {
  android_for_quickbrick: api_android,
  ios: api_apple,
  ios_for_quickbrick: api_apple,
};

const mobileTarget = ["mobile"];

const targets = {
  android_for_quickbrick: mobileTarget,
  ios: mobileTarget,
  ios_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
