package com.applicaster.plugin.xray

import android.app.Application
import android.content.Context
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.APLogger
import com.applicaster.util.logging.IAPLogger
import com.applicaster.xray.android.sinks.ADBSink
import com.applicaster.xray.android.sinks.PackageFileLogSink
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Logger

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
        // todo: update sinks configuration
        val fileSink = configuration?.get(fileSinkKey)
        if(null != fileSink && !fileSink.isEmpty()) {
            Core.get().removeSink(fileSinkKey)
            Core.get().addSink(fileSinkKey, PackageFileLogSink(context, "application_log.txt"))
        }
        // todo: update filters configuration
    }

}