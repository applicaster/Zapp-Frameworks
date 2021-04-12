package com.applicaster.crashlog

import android.app.Application
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.APLogger
import com.applicaster.util.OSUtil
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.crashes.Crashes;

class AppCenterCrashlog : CrashlogPlugin {

    private var configuration: Map<String, String>? = null

    override fun activate(applicationContext: Application) {
        val secret = applicationContext.getString(OSUtil.getStringResourceIdentifier("app_center_secret"))
        if (DEBUG_SECRET == secret) {
            APLogger.warn(TAG, "MS AppCenter secret is not defined, plugin will be disabled")
            return
        }
        AppCenter.start(applicationContext, secret, Crashes::class.java)
    }

    override fun init(configuration: Map<String, String>?) {
        this.configuration = configuration
    }

    companion object {
        private const val TAG = "AppCenterCrashlog"
        private const val DEBUG_SECRET = "debug_app_center_secret"
    }
}
