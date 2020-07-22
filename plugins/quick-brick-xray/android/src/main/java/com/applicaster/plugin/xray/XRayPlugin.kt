package com.applicaster.plugin.xray

import android.app.Application
import android.content.Context
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
import com.applicaster.xray.ui.notification.XRayNotification

// Adapter plugin that configures APLogger to use X-Ray for logging
class XRayPlugin : CrashlogPlugin {

    companion object {
        private const val TAG = "XRayPlugin"
        private const val fileSinkKey = "file_sink"
        private const val reportEmailKey = "report_email"
        private const val notificationKey = "notification"
        private const val crashReportingKey = "report_crashes"
    }

    private var activated = false
    private lateinit var context: Context

    override fun activate(applicationContext: Application) {
        val logger = Logger.get(TAG)

        if (activated) {
            logger.w(TAG).message("X-Ray logging plugin is already activated")
            return
        }

        // don't really need it there, we already had to use AppContext.get() by this point
        context = applicationContext

        Core.get().addSink("adb", ADBSink())

        // override default SDK Logger
        APLogger.setLogger(object : IAPLogger {

            private val rootLogger = Logger.get()

            override fun verbose(tag: String, msg: String) = rootLogger.v(tag).message(msg)

            override fun debug(tag: String, msg: String) = rootLogger.d(tag).message(msg)

            override fun info(tag: String, msg: String) = rootLogger.i(tag).message(msg)

            override fun warn(tag: String, msg: String) = rootLogger.w(tag).message(msg)

            override fun error(tag: String, msg: String) = rootLogger.e(tag).message(msg)

            override fun error(tag: String, msg: String, t: Throwable) =
                    rootLogger.e(tag).exception(t).message(msg)
        })
        activated = true
        logger.i(TAG).message("X-Ray logging was activated")
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
            val errorFile = PackageFileLogSink(context, "errors_log.txt")
            Core.get()
                    .addSink(fileSinkKey, errorFile)
                    .setFilter(fileSinkKey, "", DefaultSinkFilter(eFileLogLevel))
            // enable our own crash reports sending, but do not handle crashes
            Reporting.init(reportEmail?:"", errorFile.file)
        } else {
            // enable basic reporting without file (not very useful)
            Reporting.init(reportEmail?:"", null)
        }

        // todo: we need immediate crash reporting mode in zapp: show share intent right after the crash
        val reportCrashes = StringUtil.booleanValue(configuration?.get(crashReportingKey))
        if(reportCrashes) {
            Reporting.enableForCurrentThread(AppContext.get())
        } else {
            // can't disable it right now, since previous exception handler is lost, and this code could be called twice
        }

        val showNotification = StringUtil.booleanValue(configuration?.get(notificationKey))

        if(showNotification) {
            // add report sharing button to notification
            val shareLogIntent = SendActivity.getSendPendingIntent(AppContext.get())

            // if we have file logging enabled, allow to send it
            val actions = if(fileLogLevel != null) hashMapOf("Send" to shareLogIntent) else null

            // here we show Notification UI with custom actions
            XRayNotification.show(
                    AppContext.get(),
                    101,
                    actions
            )
        }

        // todo: update filters configuration
    }

}