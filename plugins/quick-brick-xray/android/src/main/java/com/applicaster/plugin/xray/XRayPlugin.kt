package com.applicaster.plugin.xray

import android.app.Application
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.logging.IAPLogger
import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.android.sinks.ADBSink
import com.applicaster.xray.android.sinks.PackageFileLogSink
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Logger
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.crashreporter.SendActivity
import com.applicaster.xray.ui.notification.XRayNotification

// Adapter plugin that configures APLogger to use X-Ray for logging
class XRayPlugin : CrashlogPlugin {

    companion object {
        private const val TAG = "XRayPlugin"
        private const val fileSinkKey = "file_sink"
    }

    private var activated = false
    private lateinit var context: Context

    override fun activate(applicationContext: Application) {
        val logger = Logger.get(TAG)

        if (activated) {
            logger.w(TAG).message("X-Ray logging plugin is already activated")
            return
        }

        // dont really need it there, we already had to use AppContext.get() by this point
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

        // todo: update sinks configuration based on settings
        Core.get().removeSink(fileSinkKey)
        val errorFile = PackageFileLogSink(context, "errors_log.txt")
        Core.get()
                .addSink(fileSinkKey, errorFile)
                .setFilter(fileSinkKey, "", DefaultSinkFilter(Log.ERROR))

        // enable our own crash reports sending, but do not handle crashes
        Reporting.init("crash@example.com", errorFile.file)

        // add report sharing button to notification
        val shareLogIntent = PendingIntent.getActivity(
                AppContext.get(),
                0,
                Intent(AppContext.get(), SendActivity::class.java)
                        .setAction("com.applicaster.xray.send"),
                PendingIntent.FLAG_CANCEL_CURRENT
        )

        val actions: HashMap<String, PendingIntent> = hashMapOf("Send" to shareLogIntent)

        // here we show Notification UI with custom actions
        XRayNotification.show(
                AppContext.get(),
                101,
                actions
        )

        // todo: update filters configuration
    }

}