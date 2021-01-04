package com.applicaster.plugin.xray.model

data class Settings(val dummy: Any? = null) {

    var shortcutEnabled: Boolean? = null

    var crashReporting: Boolean? = null

    var fileLogLevel: LogLevelSetting? = null

    var showNotification: Boolean? = null

    // intercept public react native messages from FLog
    var reactNativeLogLevel: LogLevelSetting? = null

    // intercept internal react native messages from Printer
    var reactNativeDebugLogging: Boolean? = null

    // enable TimingSink csv output
    var timingLogging: Boolean? = null

    companion object {
        fun merge(base: Settings, overrides: Settings): Settings {
            val merged = base.copy()
            merged.shortcutEnabled = overrides.shortcutEnabled ?: base.shortcutEnabled
            merged.crashReporting = overrides.crashReporting ?: base.crashReporting
            merged.fileLogLevel = overrides.fileLogLevel ?: base.fileLogLevel
            merged.showNotification = overrides.showNotification ?: base.showNotification
            merged.reactNativeLogLevel = overrides.reactNativeLogLevel ?: base.reactNativeLogLevel
            merged.reactNativeDebugLogging = overrides.reactNativeDebugLogging ?: base.reactNativeDebugLogging
            merged.timingLogging = overrides.timingLogging ?: base.timingLogging
            return merged
        }

    }
}
