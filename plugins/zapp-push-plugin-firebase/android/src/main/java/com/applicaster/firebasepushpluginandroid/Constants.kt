package com.applicaster.firebasepushpluginandroid

// matches default_notification_channel_id in strings.xml
const val FIREBASE_DEFAULT_CHANNEL_ID = "firebase_default_channel"

const val PLUGIN_ID = "ZappPushPluginFirebase"

object ChannelSettings {
    // per-channel settings keys

    const val CHANNEL_NAME_KEY = "notification_channel_name"
    const val CHANNEL_ID_KEY = "notification_channel_id"
    const val CHANNEL_SOUND_KEY = "notification_channel_sound"
    const val CHANNEL_IMPORTANCE_KEY = "notification_channel_importance"
    const val DEFAULT_CHANNEL_NAME = "Push Notifications"

    // notification channel priorities
    const val PRIORITY_HIGH = "high"
    const val PRIORITY_DEFAULT = "default"
    const val PRIORITY_LOW = "low"
    const val PRIORITY_MIN = "min"
}
