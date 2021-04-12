package com.applicaster.crashlog

import android.app.Application
import com.applicaster.plugin_manager.crashlog.CrashlogPlugin
import com.applicaster.util.OSUtil
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.crashes.Crashes;

class AppCenterCrashlog: CrashlogPlugin {

    private var configuration: Map<String, String>? = null

    override fun activate(applicationContext: Application) {
        AppCenter.start(applicationContext, applicationContext.getString(OSUtil.getStringResourceIdentifier("app_center_secret")), Crashes::class.java)
    }

    override fun init(configuration: Map<String, String>?) {
        this.configuration = configuration
    }
}
