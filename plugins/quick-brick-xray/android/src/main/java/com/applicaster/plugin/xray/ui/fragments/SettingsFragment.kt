package com.applicaster.plugin.xray.ui.fragments

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import androidx.appcompat.widget.SwitchCompat
import androidx.fragment.app.Fragment
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.TimingSink
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.plugin.xray.model.LogLevelSetting
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
        if(null != xRayPlugin) {
            val settings = xRayPlugin.getEffectiveSettings()

            // Notification
            view.findViewById<SwitchCompat>(R.id.switchNotification).let {
                it.isChecked = true == settings.showNotification
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.showNotification = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            // Crash reporting
            view.findViewById<SwitchCompat>(R.id.switchCrashReporting).let {
                it.isChecked = true == settings.crashReporting
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.crashReporting = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            view.findViewById<SwitchCompat>(R.id.switchShortcut).let {
                it.isChecked = true == settings.shortcutEnabled
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.shortcutEnabled = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }


            // File logging level
            bindLogLevel(view.findViewById(R.id.cbFileLogLevel),
                    settings.fileLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            settings.fileLogLevel = asLogLevelSetting(position)
                            xRayPlugin.applySettings(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })

            // RN logging level
            bindLogLevel(view.findViewById(R.id.cbReactLogLevel),
                    settings.reactNativeLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            settings.reactNativeLogLevel = asLogLevelSetting(position)
                            xRayPlugin.applySettings(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })

            // RN Printer logging
            view.findViewById<SwitchCompat>(R.id.switchReactNativeDebugLogging).let {
                it.isChecked = true == settings.reactNativeDebugLogging
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.reactNativeDebugLogging = isChecked
                    xRayPlugin.applySettings(settings)
                }
            }

            // RN Printer logging
            view.findViewById<SwitchCompat>(R.id.switchTimingLogging).let {
                it.isChecked = true == settings.timingLogging
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.timingLogging = isChecked
                    xRayPlugin.applySettings(settings)
                    updateTimingsState()
                }
            }
        }

        btnShareTimings = view.findViewById(R.id.btn_share_timings)
        btnShareTimings.setOnClickListener { Reporting.sendLogReport(activity!!, TimingSink.file) }

        return view
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
