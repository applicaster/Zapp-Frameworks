package com.applicaster.plugin.xray.model

import com.applicaster.xray.core.LogLevel

data class Settings(val dummy: Any? = null) {

    var crashReporting: Boolean? = null

    var fileLogLevel: LogLevel? = null

    var showNotification: Boolean? = null

    // intercept public react native messages from FLog
    var reactNativeLogLevel: LogLevel? = null

    // intercept internal react native messages from Printer
    var reactNativeDebugLogging: Boolean? = null

    companion object {
        fun merge(base: Settings, overrides: Settings): Settings {
            val copy = base.copy()
            copy.crashReporting = overrides.crashReporting ?: base.crashReporting
            copy.fileLogLevel = overrides.fileLogLevel ?: base.fileLogLevel
            copy.showNotification = overrides.showNotification ?: base.showNotification
            copy.reactNativeLogLevel = overrides.reactNativeLogLevel ?: base.reactNativeLogLevel
            copy.reactNativeDebugLogging = overrides.reactNativeDebugLogging ?: base.reactNativeDebugLogging
            return copy
        }

    }
}
