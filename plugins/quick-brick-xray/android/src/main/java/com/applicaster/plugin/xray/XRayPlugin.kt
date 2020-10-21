package com.applicaster.plugin.xray

import android.app.Application
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.applicaster.identityservice.UUIDUtil
import com.applicaster.plugin.xray.logadapters.APLoggerAdapter
import com.applicaster.plugin.xray.logadapters.FLogAdapter
import com.applicaster.plugin.xray.logadapters.PrinterAdapter
import com.applicaster.plugin.xray.model.LogLevelSetting
import com.applicaster.plugin.xray.model.Settings
import com.applicaster.plugin.xray.remote.RemoteReporter
import com.applicaster.plugin.xray.ui.LogActivity
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.*
import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.android.sinks.ADBSink
import com.applicaster.xray.android.sinks.PackageFileLogSink
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.core.Logger
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.crashreporter.SendActivity
import com.applicaster.xray.ui.notification.XRayNotification
import com.applicaster.xray.ui.sinks.InMemoryLogSink
import com.facebook.common.logging.FLog
import com.facebook.common.logging.FLogDefaultLoggingDelegate
import com.facebook.debug.holder.NoopPrinter
import com.facebook.debug.holder.PrinterHolder
import com.google.gson.GsonBuilder

// Adapter plugin that configures APLogger to use X-Ray for logging
class XRayPlugin : CrashlogPlugin {

    companion object {
        // keys
        private const val fileSinkKey = "fileLogLevel"
        private const val reportEmailKey = "reportEmail"
        private const val notificationKey = "showNotification"
        private const val debugRNKey = "reactNativeDebugLogging"
        private const val crashReportingKey = "crashReporting"

        // public constants
        const val fileSinkFileName = "xray_log.txt"
        const val inMemorySinkName = "in_memory_sink"

        const val pluginId = "xray_logging_plugin"

        // private constants
        private const val TAG = "XRayPlugin"
        private const val notificationId = 101
        private const val storageKey = "settings"

        private val gson = GsonBuilder().create()
    }

    private var configuration: Map<String, String>? = null
    private var activated = false
    private val context: Context = AppContext.get()
    private val pluginLogger = Logger.get(TAG)

    private var localSettings: Settings = Settings()
    private val pluginSettings: Settings = Settings()

    val effectiveSettingsObservable: MutableLiveData<Settings> = MutableLiveData();

    fun applySettings(settings: Settings) {
        localSettings = settings
        apply(Settings.merge(pluginSettings, localSettings))
        // todo: dirty. Local storage is not initialized yet
        context.getSharedPreferences(pluginId, 0)
                .edit()
                .putString(storageKey, gson.toJson(localSettings))
                .apply()
    }

    fun getEffectiveSettings(): Settings = Settings.merge(pluginSettings, localSettings)

    override fun activate(applicationContext: Application) {

        if (activated) {
            pluginLogger.w(TAG).message("X-Ray logging plugin is already activated")
            return
        }

        // add default ADB sink
        Core.get().addSink("adb", ADBSink())

        // default in memory sink (should be optional and configurable!)
        Core.get().addSink(inMemorySinkName, InMemoryLogSink())

        Core.get().addSink("remote", RemoteReporter(
                "http://applicaster-device-log-prod.herokuapp.com/api/account123/",
                UUIDUtil.getUUID()))

        // override default SDK Logger
        hookApplicasterLogger()

        // todo: dirty.
        val sharedPreferences = context.getSharedPreferences(pluginId, 0)
        sharedPreferences.getString(storageKey, null)?.let {
            try {
                gson.fromJson(it, Settings::class.java)?.let {
                    localSettings = it
                }
            } catch (ex: Exception) {
                // usually format change, just remove stored setting
                ex.printStackTrace()
                sharedPreferences
                        .edit()
                        .remove(storageKey)
                        .apply()
            }
        }

        apply(Settings.merge(pluginSettings, localSettings))

        activated = true
        pluginLogger.i(TAG).message("X-Ray logging was activated")
    }

    private fun hookApplicasterLogger() {
        APLogger.setLogger(APLoggerAdapter())
        pluginLogger.i(TAG).message("Applicaster APLogger is now intercepted by X-Ray")
    }

    private fun apply(settings: Settings) {

        Core.get().removeSink(fileSinkKey)

        val reportEmail = configuration?.get(reportEmailKey)

        val fileLogLevel = settings.fileLogLevel?.level
        if(null != fileLogLevel) {
            val fileSink = PackageFileLogSink(context, fileSinkFileName)
            Core.get()
                    .addSink(fileSinkKey, fileSink)
                    .setFilter(fileSinkKey, "", DefaultSinkFilter(fileLogLevel))
            // enable our own crash reports sending, but do not handle crashes
            Reporting.init(reportEmail ?: "", fileSink.file)
        } else {
            // enable basic reporting without file (not very useful)
            Reporting.init(reportEmail ?: "", null)
        }

        @Suppress("ControlFlowWithEmptyBody")
        if(true == settings.crashReporting) {
            Reporting.enableForCurrentThread(AppContext.get(), true)
        } else {
            // can't disable it right now, since previous exception handler is lost,
            // and this code could be called multiple times
        }

        if(true == settings.showNotification) {
            setupNotification(null != fileLogLevel)
        } else {
            XRayNotification.hide(context)
        }

        hookRNLogger(settings.reactNativeLogLevel?.level)

        if(true == settings.reactNativeDebugLogging) {
            PrinterHolder.setPrinter(PrinterAdapter())
            pluginLogger.i(TAG).message("React native printer is now intercepted by X-Ray")
        } else {
            PrinterHolder.setPrinter(NoopPrinter.INSTANCE)
        }

        // add shortcut
        setupShortcut(true == settings.shortcutEnabled)

        effectiveSettingsObservable.postValue(settings)
    }

    private fun hookRNLogger(level: LogLevel?) {
        if(null == level){
            FLog.setLoggingDelegate(FLogDefaultLoggingDelegate.getInstance())
            pluginLogger.i(TAG).message("React native logger is not intercepted by X-Ray anymore")
        } else {
            FLog.setLoggingDelegate(FLogAdapter(Log.VERBOSE + level.level))
            pluginLogger.i(TAG).message("React native logger is now intercepted by X-Ray at ${level.name} level")
        }
    }

    override fun init(configuration: Map<String, String>?) {
        this.configuration = configuration

        val fileLogLevel = configuration?.get(fileSinkKey)
        // Try to parse log level. "off" will be resolved as null.
        pluginSettings.fileLogLevel = when {
            !fileLogLevel.isNullOrEmpty() -> LogLevelSetting(enumValues<LogLevel>().find { it.name == fileLogLevel })
            else -> null
        }

        pluginSettings.crashReporting = APDebugUtil.getIsInDebugMode()
                && StringUtil.booleanValue(configuration?.get(crashReportingKey))

        pluginSettings.reactNativeLogLevel = if(APDebugUtil.getIsInDebugMode()) LogLevelSetting(LogLevel.debug) else null

        pluginSettings.reactNativeDebugLogging = if(StringUtil.booleanValue(configuration?.get(debugRNKey))) true else null

        pluginSettings.showNotification = APDebugUtil.getIsInDebugMode() && !OSUtil.isTv()
                && StringUtil.booleanValue(configuration?.get(notificationKey))

        pluginSettings.shortcutEnabled = APDebugUtil.getIsInDebugMode()
    }

    private fun setupShortcut(showNotification: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }
        context.getSystemService<ShortcutManager>(ShortcutManager::class.java)?.let { shortcutManager ->
            if (!showNotification) {
                shortcutManager.removeDynamicShortcuts(listOf("xray"))
            } else {
                if (!shortcutManager.dynamicShortcuts.stream().anyMatch { it.id == "xray" }) {
                    val shortcut = ShortcutInfo.Builder(context, "xray")
                            .setShortLabel("XRay")
                            .setLongLabel("Open XRay log")
                            .setIcon(Icon.createWithResource(context, R.drawable.ic_xray_settings_24))
                            .setIntent(Intent(context, LogActivity::class.java).setAction(Intent.ACTION_VIEW))
                            .build()
                    shortcutManager.addDynamicShortcuts(listOf(shortcut))
                }
            }
        }
    }

    private fun setupNotification(enableLogSharing: Boolean) {
        val showLogIntent = PendingIntent.getActivity(
                context,
                0,
                Intent(context, LogActivity::class.java)
                        .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_CANCEL_CURRENT
        )!!

        // actions order is kept in the UI
        val actions: HashMap<String, PendingIntent> = linkedMapOf("Show" to showLogIntent)

        if (enableLogSharing) {
            // add report sharing button to notification
            // if we have file logging enabled, allow to send it
            val shareLogIntent = SendActivity.getSendPendingIntent(context)
            actions["Send"] = shareLogIntent
        }

        // here we show Notification UI with custom actions
        XRayNotification.show(
                context,
                notificationId,
                actions
        )
    }

}