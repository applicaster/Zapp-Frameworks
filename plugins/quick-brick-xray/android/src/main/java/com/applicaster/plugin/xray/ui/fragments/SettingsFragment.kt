package com.applicaster.plugin.xray.ui.fragments

import android.annotation.SuppressLint
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.widget.SwitchCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.analytics.AnalyticsAgentUtil.ToastLevel
import com.applicaster.identityservice.UUIDUtil
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.plugin.xray.model.LogLevelSetting
import com.applicaster.plugin.xray.model.Settings
import com.applicaster.plugin.xray.sinks.TimingSink
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.crashreporter.Reporting

class SettingsFragment : Fragment() {

    private lateinit var btnShareTimings: View

    @SuppressLint("UseSwitchCompatOrMaterialCode")
    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        val view = inflater.inflate(R.layout.xray_fragment_settings, container, false)
        view.setTag(R.id.fragment_title_tag, "Settings")

        val pluginManager = PluginManager.getInstance()
        val initiatedPlugin = pluginManager.getInitiatedPlugin(XRayPlugin.pluginId)
        val xRayPlugin = initiatedPlugin?.instance as? XRayPlugin
        if (null != xRayPlugin) {
            val effectiveSettings = xRayPlugin.getEffectiveSettings()

            // Notification
            view.findViewById<SwitchCompat>(R.id.switchNotification).let {
                it.isChecked = true == effectiveSettings.showNotification
                it.setOnCheckedChangeListener { _, isChecked ->
                    val settings = xRayPlugin.getEffectiveSettings()
                    settings.showNotification = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            // Crash reporting
            view.findViewById<SwitchCompat>(R.id.switchCrashReporting).let {
                it.isChecked = true == effectiveSettings.crashReporting
                it.setOnCheckedChangeListener { _, isChecked ->
                    val settings = xRayPlugin.getEffectiveSettings()
                    settings.crashReporting = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            view.findViewById<SwitchCompat>(R.id.switchShortcut).let {
                it.isChecked = true == effectiveSettings.shortcutEnabled
                it.setOnCheckedChangeListener { _, isChecked ->
                    val settings = xRayPlugin.getEffectiveSettings()
                    settings.shortcutEnabled = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }


            // File logging level
            bindLogLevel(view.findViewById(R.id.cbFileLogLevel),
                    effectiveSettings.fileLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            val settings = xRayPlugin.getEffectiveSettings()
                            settings.fileLogLevel = asLogLevelSetting(position)
                            xRayPlugin.applySettings(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })

            // RN logging level
            bindLogLevel(view.findViewById(R.id.cbReactLogLevel),
                    effectiveSettings.reactNativeLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            val settings = xRayPlugin.getEffectiveSettings()
                            settings.reactNativeLogLevel = asLogLevelSetting(position)
                            xRayPlugin.applySettings(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })

            // RN Printer logging
            view.findViewById<SwitchCompat>(R.id.switchReactNativeDebugLogging).let {
                it.isChecked = true == effectiveSettings.reactNativeDebugLogging
                it.setOnCheckedChangeListener { _, isChecked ->
                    val settings = xRayPlugin.getEffectiveSettings()
                    settings.reactNativeDebugLogging = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            // Analytics toast
            view.findViewById<Spinner>(R.id.cbAnalyticsToasts).let {
                val analytics = AnalyticsAgentUtil.getInstance()
                it.adapter = ArrayAdapter.createFromResource(
                        it.context,
                        R.array.xray_analytics_toasts_levels,
                        android.R.layout.simple_spinner_dropdown_item)
                it.setSelection(analytics.toastLevel.ordinal)
                it.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
                    override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                        analytics.toastLevel = ToastLevel.values().getOrElse(position) { ToastLevel.none }
                    }

                    override fun onNothingSelected(parent: AdapterView<*>?) {

                    }
                }
            }

            // Timings
            view.findViewById<SwitchCompat>(R.id.switchTimingLogging).let {
                it.isChecked = true == effectiveSettings.timingLogging
                it.setOnCheckedChangeListener { _, isChecked ->
                    val settings = xRayPlugin.getEffectiveSettings()
                    settings.timingLogging = isChecked
                    xRayPlugin.applySettings(settings)
                    updateTimingsState()
                }
            }

            // Remote logging
            view.findViewById<ViewGroup>(R.id.cnt_remoteLog).let { viewGroup: ViewGroup ->
                viewGroup.visibility = if (effectiveSettings.logzToken.isNullOrEmpty()) View.GONE else View.VISIBLE
                viewGroup.findViewById<TextView>(R.id.lbl_uuid).apply {
                    text = UUIDUtil.getUUID()
                    setOnClickListener {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        clipboard.setPrimaryClip(ClipData.newPlainText("UUID", UUIDUtil.getUUID()))
                        Toast.makeText(context, R.string.msg_uuid_copied, Toast.LENGTH_LONG).show()
                    }
                }
                view.findViewById<View>(R.id.btnRemoteLogDisable).setOnClickListener { disableRemoteLog(xRayPlugin) }

                xRayPlugin.observeEffectiveSettings().observe(
                        this@SettingsFragment,
                        Observer<Settings> { t -> viewGroup.visibility = if (t.logzToken.isNullOrEmpty()) View.GONE else View.VISIBLE })

            }
        }

        btnShareTimings = view.findViewById(R.id.btn_share_timings)
        btnShareTimings.setOnClickListener { Reporting.sendLogReport(activity!!, TimingSink.file) }

        return view
    }

    private fun disableRemoteLog(xRayPlugin: XRayPlugin) {
        val settings = xRayPlugin.getEffectiveSettings()
        settings.logzToken = null
        xRayPlugin.applySettings(settings)
    }

    private fun asLogLevelSetting(position: Int) =
            if (LogLevel.values().size <= position) LogLevelSetting()
            else LogLevelSetting(LogLevel.values()[position])

    private fun bindLogLevel(spinner: Spinner,
                             logLevel: LogLevelSetting?,
                             listener: AdapterView.OnItemSelectedListener) {
        spinner.adapter = ArrayAdapter(
                spinner.context,
                android.R.layout.simple_list_item_1,
                listOf(*(LogLevel.values().map { it.name }.toTypedArray()), "off"))
        if (logLevel?.level == null) {
            spinner.setSelection(LogLevel.values().size) // "off" position
        } else {
            spinner.setSelection(logLevel.level!!.level)
        }
        spinner.post { spinner.onItemSelectedListener = listener }
    }

    override fun onResume() {
        super.onResume()
        updateTimingsState()
    }

    private fun updateTimingsState() {
        btnShareTimings.visibility = if (TimingSink.file.exists()) View.VISIBLE else View.GONE
    }

    companion object {
        @JvmStatic
        fun newInstance() = SettingsFragment()
    }
}
