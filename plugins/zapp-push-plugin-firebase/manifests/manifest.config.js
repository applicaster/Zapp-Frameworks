const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "Firebase Notifications",
  description:
    "Send high-velocity targeted push via Google's Firebase Notifications Console",
  cover_image:
    "https://res.cloudinary.com/dtiodujtz/image/upload/v1552096080/Plugins/Firebase_Push1.png",
  type: "push_provider",
  identifier: "ZappPushPluginFirebase",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [
    "572a0a65373163000b000000",
    "5a364b49e03b2f000d51a0de",
  ],
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
    npm_dependencies: [`@applicaster/zapp-push-plugin-firebase@${version}`],
    project_dependencies: project_dependencies[platform],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
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
      "Disable plugin if you do not want to use plugin or require enable plugin after application start",
  },
  {
    type: "checkbox",
    key: "allow_enterprise_rich_push_notifications",
    default: 1,
    tooltip_text:
      'When checked, this field enables debug builds to support sending push notifications, but disables other debug functionality. For more details, <a href="https://sites.google.com/applicaster.com/fb-notifications-debug-push/home";>Click Here</a>',
  },
  {
    type: "uploader",
    key: "notification_service_extension_provisioning_profile",
    tooltip_text:
      "Upload Notification Extension Provisioning Profile for Store builds only",
  },
  {
    key: "ios_assets_bundle",
    type: "uploader",
    label: "Custom sound files",
    label_tooltip: "Please upload a zip file to provide the custom sounds mp3 files to be used with FCM custom sound parameter</a>."
  },
  {
    key: "default_topics",
    type: "text",
    label: "Default topics",
    default: "general",
    tooltip_text: "Topics to subscribe to, separated with comma"
  },
  {
    key: "default_localized_topics",
    type: "text",
    label: "Default Localized topics",
    default: "general",
    tooltip_text: "Topics to subscribe to, separated with comma that will have appended language (ex. general-en)"
  },
];

const custom_configuration_fields_android = [
  {
    key: "enabled",
    type: "checkbox",
    default: true,
    label: "Plugin enabled",
    label_tooltip:
      "Disable plugin if you do not want to use plugin or require enable plugin after application start",
  },
  {
    key: "default_topic",
    type: "text",
    label: "Default topics",
    default: "general",
    tooltip_text: "Topics to subscribe to, separated with comma"
  },
  {
    key: "default_localized_topics",
    type: "text",
    label: "Default Localized topics",
    default: "general",
    tooltip_text: "Topics to subscribe to, separated with comma that will have appended language (ex. general-en)"
  },
  {
    key: "notification_channel_name",
    type: "text",
    tooltip_text: "Name of the default notification channel",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound",
    tooltip_text:
      "Sound file name from the application assets for default notification channel",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
    default: "system_default",
  },
  {
    key: "notification_channel_name_1",
    type: "text",
  },
  {
    key: "notification_channel_id_1",
    type: "text",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound_1",
    tooltip_text: "Sound file name from the application assets",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
    default: "push_sound_1",
  },
  {
    type: "dropdown",
    key: "notification_channel_importance_1",
    tooltip_text:
      'Importance of the notification. See <a href="https://developer.android.com/training/notify-user/channels">Android developer documentation</a>',
    multiple: false,
    options: ["high", "default", "low", "min"],
    default: "default",
  },
  {
    key: "notification_channel_name_2",
    type: "text",
  },
  {
    key: "notification_channel_id_2",
    type: "text",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound_2",
    tooltip_text: "Sound file name from the application assets",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
  },
  {
    type: "dropdown",
    key: "notification_channel_importance_2",
    tooltip_text:
      'Importance of the notification. See <a href="https://developer.android.com/training/notify-user/channels">Android developer documentation</a>',
    multiple: false,
    options: ["high", "default", "low", "min"],
  },
  {
    key: "notification_channel_name_3",
    type: "text",
  },
  {
    key: "notification_channel_id_3",
    type: "text",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound_3",
    tooltip_text: "Sound file name from the application assets",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
  },
  {
    type: "dropdown",
    key: "notification_channel_importance_3",
    tooltip_text:
      'Importance of the notification. See <a href="https://developer.android.com/training/notify-user/channels">Android developer documentation</a>',
    multiple: false,
    options: ["high", "default", "low", "min"],
  },
  {
    key: "notification_channel_name_4",
    type: "text",
  },
  {
    key: "notification_channel_id_4",
    type: "text",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound_4",
    tooltip_text: "Sound file name from the application assets",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
  },
  {
    type: "dropdown",
    key: "notification_channel_importance_4",
    tooltip_text:
      'Importance of the notification. See <a href="https://developer.android.com/training/notify-user/channels">Android developer documentation</a>',
    multiple: false,
    options: ["high", "default", "low", "min"],
  },
  {
    key: "notification_channel_name_5",
    type: "text",
  },
  {
    key: "notification_channel_id_5",
    type: "text",
  },
  {
    type: "dropdown",
    key: "notification_channel_sound_5",
    tooltip_text: "Sound file name from the application assets",
    multiple: false,
    options: [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent",
    ],
  },
  {
    type: "dropdown",
    key: "notification_channel_importance_5",
    tooltip_text:
      'Importance of the notification. See <a href="https://developer.android.com/training/notify-user/channels">Android developer documentation</a>',
    multiple: false,
    options: ["high", "default", "low", "min"],
  },
];

const custom_configuration_fields = {
  ios: custom_configuration_fields_apple,
  ios_for_quickbrick: custom_configuration_fields_apple,
  tvos: custom_configuration_fields_apple,
  tvos_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android,
};

const min_zapp_sdk = {
  android_for_quickbrick: "4.0.0",
  ios_for_quickbrick: "3.0.0-Dev",
};

const extra_dependencies_apple = [
  {
    ZappPushPluginFirebase:
      ":path => './node_modules/@applicaster/zapp-push-plugin-firebase/apple/ZappPushPluginFirebase.podspec'",
  },
  {
    NotificationServiceExtension: {
      "ZappPushPluginFirebase/ServiceExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-firebase/apple/ZappPushPluginFirebase.podspec'",
    },
  },
  {
    NotificationContentExtension: {
      "ZappPushPluginFirebase/ContentExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-firebase/apple/ZappPushPluginFirebase.podspec'",
    },
  },
];

const extra_dependencies = {
  ios: extra_dependencies_apple,
  ios_for_quickbrick: extra_dependencies_apple,
  tvos: extra_dependencies_apple,
  tvos_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-push-plugin-firebase":
      "node_modules/@applicaster/zapp-push-plugin-firebase/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
};

const api_android = {
  class_name: "com.applicaster.firebasepushpluginandroid.FirebasePushProvider",
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APPushProviderFirebase",
  modules: ["ZappPushPluginFirebase"],
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
