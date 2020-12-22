const baseManifest = {
  api: {},
  dependency_repository_url: [],
  author_name: "Applicaster",
  author_email: "zapp@applicaster.com",
  name: "UrbanAirship",
  description: "Urban Airship wrapper",
  cover_image: "",
  type: "push_provider",
  identifier: "UrbanAirship-iOS",
  screen: false,
  react_native: true,
  ui_builder_support: true,
  whitelisted_account_ids: [],
  min_zapp_sdk: "0.0.1",
  deprecated_since_zapp_sdk: "",
  unsupported_since_zapp_sdk: "",
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
    npm_dependencies: [`@applicaster/zapp-push-plugin-urban-airship@${version}`],
    targets: targets[platform],
    custom_configuration_fields: custom_configuration_fields[platform],
    project_dependencies: project_dependencies[platform],
    identifier: identifier[platform],
  };
  return manifest;
}

const identifier = {
  ios_for_quickbrick: "UrbanAirship-iOS",
  android_for_quickbrick: "UrbanAirship",
};

const custom_configuration_fields_apple = [
  {
    type: "text",
    key: "store_app_key",
    tooltip_text: "AppStore production App Key"
  },
  {
    type: "text",
    key: "store_app_secret",
    tooltip_text: "AppStore production App Secret"
  },
  {
    type: "text",
    key: "enterprise_app_key",
    tooltip_text: "Enterprise production App Key"
  },
  {
    type: "text",
    key: "enterprise_app_secret",
    tooltip_text: "Enterprise production App Secret"
  },
  {
    type: "text",
    key: "google_analytics_account_id",
    tooltip_text: "Google Analytics Account ID"
  },
  {
    type: "checkbox",
    key: "allow_enterprise_rich_push_notifications",
    "default": 1
  },
  {
    type: "uploader",
    key: "notification_service_extension_provisioning_profile",
    tooltip_text: "Upload Notification Extension Provisioning Profile for Store builds only"
  }
];

const custom_configuration_fields_android = [
  {
    "key":"debug_key",
    "type":"text"
  },
  {
    "key":"debug_secret",
    "type":"text"
  },
  {
    "key":"pro_key",
    "type":"text"
  },
  {
    "key":"pro_secret",
    "type":"text"
  },
  {
    "key":"notificationStyle",
    "type":"text"
  },
  {
    "type":"text",
    "key":"google_analytics_account_id",
    "tooltip_text":"Google Analytics Account ID"
  },
  {
    "key":"notification_channel_name",
    "type":"text",
    "tooltip_text":"Name of the default notification channel"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound",
    "tooltip_text": "Sound file from application assets for default notification channel",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ],
    "default": "system_default"
  },
  {
    "key":"notification_channel_name_1",
    "type":"text"
  },
  {
    "key":"notification_channel_id_1",
    "type":"text"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound_1",
    "tooltip_text": "Sound file from application assets",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ],
    "default": "push_sound_1"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_importance_1",
    "tooltip_text": "Importance of the notification. See <a href=\"https://developer.android.com/training/notify-user/channels\">Android developer documentation</a>",
    "multiple": false,
    "options": [
      "high",
      "default",
      "low",
      "min"
    ],
    "default": "default"
  },
  {
    "key":"notification_channel_name_2",
    "type":"text"
  },
  {
    "key":"notification_channel_id_2",
    "type":"text"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound_2",
    "tooltip_text": "Sound file from application assets",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ]
  },
  {
    "type": "dropdown",
    "key": "notification_channel_importance_2",
    "tooltip_text": "Importance of the notification. See <a href=\"https://developer.android.com/training/notify-user/channels\">Android developer documentation</a>",
    "multiple": false,
    "options": [
      "high",
      "default",
      "low",
      "min"
    ]
  },
  {
    "key":"notification_channel_name_3",
    "type":"text"
  },
  {
    "key":"notification_channel_id_3",
    "type":"text"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound_3",
    "tooltip_text": "Sound file from application assets",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ]
  },
  {
    "type": "dropdown",
    "key": "notification_channel_importance_3",
    "tooltip_text": "Importance of the notification. See <a href=\"https://developer.android.com/training/notify-user/channels\">Android developer documentation</a>",
    "multiple": false,
    "options": [
      "high",
      "default",
      "low",
      "min"
    ]
  },
  {
    "key":"notification_channel_name_4",
    "type":"text"
  },
  {
    "key":"notification_channel_id_4",
    "type":"text"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound_4",
    "tooltip_text": "Sound file from application assets",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ]
  },
  {
    "type": "dropdown",
    "key": "notification_channel_importance_4",
    "tooltip_text": "Importance of the notification. See <a href=\"https://developer.android.com/training/notify-user/channels\">Android developer documentation</a>",
    "multiple": false,
    "options": [
      "high",
      "default",
      "low",
      "min"
    ]
  },
  {
    "key":"notification_channel_name_5",
    "type":"text"
  },
  {
    "key":"notification_channel_id_5",
    "type":"text"
  },
  {
    "type": "dropdown",
    "key": "notification_channel_sound_5",
    "tooltip_text": "Sound file from application assets",
    "multiple": false,
    "options": [
      "system_default",
      "push_sound_1",
      "push_sound_2",
      "push_sound_3",
      "push_sound_4",
      "push_sound_5",
      "silent"
    ]
  },
  {
    "type": "dropdown",
    "key": "notification_channel_importance_5",
    "tooltip_text": "Importance of the notification. See <a href=\"https://developer.android.com/training/notify-user/channels\">Android developer documentation</a>",
    "multiple": false,
    "options": [
      "high",
      "default",
      "low",
      "min"
    ]
  }
]

const custom_configuration_fields = {
  ios_for_quickbrick: custom_configuration_fields_apple,
  android_for_quickbrick: custom_configuration_fields_android
};

const min_zapp_sdk = {
  ios_for_quickbrick: "2.0.2-Dev",
  android_for_quickbrick: "1.0.0",
};

const extra_dependencies_apple = [
  {
    ZappPushPluginUrbanAirship:
      ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
  },
  {
    NotificationServiceExtension: {
      "ZappPushPluginUrbanAirship/ServiceExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
    },
  },
  {
    NotificationContentExtension: {
      "ZappPushPluginUrbanAirship/ContentExtension":
        ":path => './node_modules/@applicaster/zapp-push-plugin-urban-airship/apple/ZappPushPluginUrbanAirship.podspec'",
    },
  },
];

const extra_dependencies = {
  ios_for_quickbrick: extra_dependencies_apple,
};

const project_dependencies_android = [
  {
    "zapp-push-plugin-urban-airship":
    "node_modules/@applicaster/zapp-push-plugin-urban-airship/android",
  },
];

const project_dependencies = {
  android_for_quickbrick: project_dependencies_android,
};

const api_apple = {
  require_startup_execution: false,
  class_name: "APPushProviderUrbanAirship",
  modules: ["ZappPushPluginUrbanAirship"],
  plist: {
    "NSLocationAlwaysAndWhenInUseUsageDescription": "Your current location will be used to enable location based push notifications.",
    "NSLocationWhenInUseUsageDescription": "Your current location will be used to enable location based push notifications.",
    "NSLocationAlwaysUsageDescription": "Your current location will be used to enable location based push notifications."
  }
};

const api_android = {
  class_name: "com.app.urbanairshippushplugin.UrbanAirshipPushProvider",
};

const api = {
  ios_for_quickbrick: api_apple,
  android_for_quickbrick: api_android,
};

const mobileTarget = ["mobile"];

const targets = {
  ios_for_quickbrick: mobileTarget,
  android_for_quickbrick: mobileTarget,
};

module.exports = createManifest;
