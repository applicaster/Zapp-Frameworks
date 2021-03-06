package com.applicaster.plugin.xray.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager.widget.ViewPager
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.plugin.xray.model.LogLevelSetting
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.ui.adapters.ViewsPagerAdapter

class LogActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
        setContentView(R.layout.xray_activity_main)
        val pager: ViewPager = findViewById(R.id.pager)
        pager.adapter = ViewsPagerAdapter(pager)
        pager.currentItem = 1
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val pluginManager = PluginManager.getInstance()
        val initiatedPlugin = pluginManager.getInitiatedPlugin(XRayPlugin.pluginId)
        val xRayPlugin = initiatedPlugin?.instance as? XRayPlugin ?: return
        val data = intent?.data ?: return

        val settings = xRayPlugin.getEffectiveSettings()

        settings.shortcutEnabled = optBoolean(data, "shortcutEnabled", settings.shortcutEnabled)
        settings.crashReporting = optBoolean(data, "crashReporting", settings.crashReporting)
        settings.showNotification = optBoolean(data, "showNotification", settings.showNotification)
        settings.fileLogLevel = optLogLevel(data, "fileLogLevel", settings.fileLogLevel)
        settings.reactNativeDebugLogging = optBoolean(data, "reactNativeDebugLogging", settings.reactNativeDebugLogging)
        settings.reactNativeLogLevel = optLogLevel(data, "reactNativeLogLevel", settings.reactNativeLogLevel)

        val logzToken = data.getQueryParameter("logzToken")

        if (logzToken.isNullOrEmpty()) {
            // disable even if it was on
            settings.logzToken = null
            xRayPlugin.applySettings(settings)
        } else {
            if (!settings.logzToken.isNullOrEmpty()) {
                // some token is already present, update it
                settings.logzToken = logzToken
                xRayPlugin.applySettings(settings)
            } else {
                // ask user to enable remote logging
                AlertDialog.Builder(this)
                        .setTitle(R.string.dlg_remote_log_title)
                        .setMessage(R.string.dlg_remote_log_message)
                        .setPositiveButton(android.R.string.ok) { _, _ ->
                            settings.logzToken = logzToken
                            xRayPlugin.applySettings(settings)
                        }
                        .setNegativeButton(android.R.string.cancel) { _, _ ->
                            xRayPlugin.applySettings(settings)
                        }.show()
            }
        }
    }

    private fun optBoolean(data: Uri, key: String, default: Boolean?): Boolean? {
        val value = data.getQueryParameter(key)
        if(value.isNullOrEmpty()) {
            return default
        }
        return "true" == value
    }

    private fun optLogLevel(data: Uri, key: String, default: LogLevelSetting?): LogLevelSetting? {
        val value = data.getQueryParameter(key)
        if(value.isNullOrEmpty()) {
            return default
        }
        val logLevel = LogLevel.values().find { it.name == value }
        return if (logLevel != null) LogLevelSetting(logLevel) else default
    }

}
