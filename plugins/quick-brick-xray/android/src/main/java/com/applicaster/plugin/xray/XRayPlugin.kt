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
import android.util.Printer
import com.applicaster.plugin.xray.ui.LogActivity
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.StringUtil
import com.applicaster.util.logging.IAPLogger
import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.android.sinks.ADBSink
import com.applicaster.xray.android.sinks.PackageFileLogSink
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.core.Logger
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.crashreporter.SendActivity
import com.applicaster.xray.example.sinks.InMemoryLogSink
import com.applicaster.xray.ui.notification.XRayNotification
import com.facebook.common.logging.FLog
import com.facebook.common.logging.LoggingDelegate
import com.facebook.debug.debugoverlay.model.DebugOverlayTag
import com.facebook.debug.holder.NoopPrinter
import com.facebook.debug.holder.PrinterHolder

// Adapter plugin that configures APLogger to use X-Ray for logging
class XRayPlugin : CrashlogPlugin {

    companion object {
        private const val TAG = "XRayPlugin"
        private const val fileSinkKey = "file_sink"
        private const val reportEmailKey = "report_email"
        private const val notificationKey = "notification"
        private const val debugRNKey = "log_react_native_debug"
        private const val crashReportingKey = "report_crashes"

        private const val fileSinkFileName = "xray_log.txt"

        const val inMemorySinkName = "in_memory_sink"
    }

    private var activated = false
    private lateinit var context: Context
    private val pluginLogger = Logger.get(TAG)

    override fun activate(applicationContext: Application) {

        if (activated) {
            pluginLogger.w(TAG).message("X-Ray logging plugin is already activated")
            return
        }

        // don't really need it there, we already had to use AppContext.get() by this point
        context = applicationContext

        // add default ADB sink
        Core.get().addSink("adb", ADBSink())

        // default in memory sink (should be optional and configurable!)
        Core.get().addSink(inMemorySinkName, InMemoryLogSink())

        // override default SDK Logger
        hookApplicasterLogger()

        // override logging from react native
        hookRNLogger()

        activated = true
        pluginLogger.i(TAG).message("X-Ray logging was activated")
    }

    private fun overrideRNPrinter() {
        PrinterHolder.setPrinter(object : Printer, com.facebook.debug.holder.Printer {

            val logger = Logger.get("ReactNative/DebugPrinter")

            override fun println(x: String?) {
                logger.d(TAG).message(x!!)
            }

            override fun logMessage(tag: DebugOverlayTag?, message: String?, vararg args: Any?) {
                logger.d(tag!!.name).message(java.lang.String.format(message!!, *args))
            }

            override fun logMessage(tag: DebugOverlayTag?, message: String?) {
                logger.d(tag!!.name).message(message!!)
            }

            override fun shouldDisplayLogMessage(tag: DebugOverlayTag?): Boolean {
                return true
            }

        })
        pluginLogger.i(TAG).message("React native printer is now intercepted by X-Ray")
    }

    private fun hookRNLogger() {
        FLog.setLoggingDelegate(object : LoggingDelegate {

            val logger = Logger.get("ReactNative")
            var level = Log.DEBUG // log at debug level since we have our own filters

            override fun wtf(tag: String?, msg: String?) {
                this.logger.e(tag!!).message(msg!!)
            }

            override fun wtf(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.e(tag!!).exception(tr!!).message(msg!!)
            }

            override fun getMinimumLoggingLevel(): Int = level

            override fun w(tag: String?, msg: String?) {
                this.logger.w(tag!!).message(msg!!)
            }

            override fun w(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.w(tag!!).exception(tr!!).message(msg!!)
            }

            override fun v(tag: String?, msg: String?) {
                this.logger.v(tag!!).message(msg!!)
            }

            override fun v(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.v(tag!!).exception(tr!!).message(msg!!)
            }

            override fun log(priority: Int, tag: String?, msg: String?) {
                this.logger.e(tag!!).message(msg!!)
            }

            override fun setMinimumLoggingLevel(level: Int) {
                this.level = level
            }

            override fun isLoggable(level: Int): Boolean {
                return this.level >= level
            }

            override fun i(tag: String?, msg: String?) {
                this.logger.i(tag!!).message(msg!!)
            }

            override fun i(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.i(tag!!).exception(tr!!).message(msg!!)
            }

            override fun e(tag: String?, msg: String?) {
                this.logger.e(tag!!).message(msg!!)
            }

            override fun e(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.e(tag!!).exception(tr!!).message(msg!!)
            }

            override fun d(tag: String?, msg: String?) {
                this.logger.d(tag!!).message(msg!!)
            }

            override fun d(tag: String?, msg: String?, tr: Throwable?) {
                this.logger.d(tag!!).exception(tr!!).message(msg!!)
            }

        })
        pluginLogger.i(TAG).message("React native logger is now intercepted by X-Ray")
    }

    private fun hookApplicasterLogger() {
        APLogger.setLogger(object : IAPLogger {

            private val logger = Logger.get("ApplicasterSDK")

            override fun verbose(tag: String, msg: String) = logger.v(tag).message(msg)

            override fun debug(tag: String, msg: String) = logger.d(tag).message(msg)

            override fun info(tag: String, msg: String) = logger.i(tag).message(msg)

            override fun warn(tag: String, msg: String) = logger.w(tag).message(msg)

            override fun error(tag: String, msg: String) = logger.e(tag).message(msg)

            override fun error(tag: String, msg: String, t: Throwable) =
                    logger.e(tag).exception(t).message(msg)
        })
        pluginLogger.i(TAG).message("Applicaster APLogger is now intercepted by X-Ray")
    }

    override fun init(configuration: Map<String, String>?) {
        context = AppContext.get()

        Core.get().removeSink(fileSinkKey)

        val fileLogLevel = configuration?.get(fileSinkKey)
        // Try to parse log level. "off" will be resolved as null.
        val eFileLogLevel = when {
            !fileLogLevel.isNullOrEmpty() -> enumValues<LogLevel>().find { it.name == fileLogLevel }
            else -> null
        }
        val reportEmail = configuration?.get(reportEmailKey)

        if(null != eFileLogLevel) {
            val fileSink = PackageFileLogSink(context, fileSinkFileName)
            Core.get()
                    .addSink(fileSinkKey, fileSink)
                    .setFilter(fileSinkKey, "", DefaultSinkFilter(eFileLogLevel))
            // enable our own crash reports sending, but do not handle crashes
            Reporting.init(reportEmail?:"", fileSink.file)
        } else {
            // enable basic reporting without file (not very useful)
            Reporting.init(reportEmail?:"", null)
        }

        // todo: we need immediate crash reporting mode in zapp: show share intent right after the crash
        val reportCrashes = StringUtil.booleanValue(configuration?.get(crashReportingKey))
        if(reportCrashes) {
            Reporting.enableForCurrentThread(AppContext.get(), true)
        } else {
            // can't disable it right now, since previous exception handler is lost, and this code could be called twice
        }

        val showNotification = StringUtil.booleanValue(configuration?.get(notificationKey))

        if(showNotification) {
            val showLogIntent = PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, LogActivity::class.java)
                            .setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_CLEAR_TASK),
                    PendingIntent.FLAG_CANCEL_CURRENT
            )!!

            // actions order is kept in the UI
            val actions: HashMap<String, PendingIntent> = linkedMapOf("Show" to showLogIntent)

            if(fileLogLevel != null) {
                // add report sharing button to notification
                // if we have file logging enabled, allow to send it
                val shareLogIntent = SendActivity.getSendPendingIntent(context)
                actions.put("Send", shareLogIntent)
            }

            // here we show Notification UI with custom actions
            XRayNotification.show(
                    context,
                    101,
                    actions
            )
        }

        val logRNPrinter =  StringUtil.booleanValue(configuration?.get(debugRNKey))
        if(logRNPrinter) {
            overrideRNPrinter()
        } else {
            PrinterHolder.setPrinter(NoopPrinter.INSTANCE)
        }

        // add shortcut
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            context.getSystemService<ShortcutManager>(ShortcutManager::class.java)?.let { shortcutManager ->
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
        // todo: update filters configuration
    }

}