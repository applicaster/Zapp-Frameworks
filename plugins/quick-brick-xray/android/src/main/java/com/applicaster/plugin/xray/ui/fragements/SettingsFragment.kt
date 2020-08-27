package com.applicaster.plugin.xray.ui.fragements

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
import androidx.lifecycle.Observer
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.plugin.xray.model.Settings
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.xray.core.LogLevel

class SettingsFragment : Fragment(), Observer<Settings> {

    @SuppressLint("UseSwitchCompatOrMaterialCode")
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_settings, container, false)
        view.setTag(R.id.fragment_title_tag, "Settings")

        val pluginManager = PluginManager.getInstance()
        val initiatedPlugin = pluginManager.getInitiatedPlugin("xray_logging_plugin")
        val xRayPlugin = initiatedPlugin?.instance as? XRayPlugin
        if(null != xRayPlugin) {
            val settings = xRayPlugin.getEffectiveSettings()

            // Notification
            view.findViewById<SwitchCompat>(R.id.switchNotification).let {
                it.isChecked = true == settings.showNotification
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.showNotification = isChecked
                    xRayPlugin.update(settings)
                }
            }

            // Crash reporting
            view.findViewById<SwitchCompat>(R.id.switchCrashReporting).let {
                it.isChecked = true == settings.crashReporting
                it.setOnCheckedChangeListener { _, isChecked ->
                    settings.crashReporting = isChecked
                    xRayPlugin.update(settings)
                }
            }

            // File logging level
            bindLogLevel(view.findViewById(R.id.cbFileLogLevel),
                    settings.fileLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            settings.fileLogLevel =
                                    if (LogLevel.values().size <= position) null
                                    else LogLevel.values()[position]
                            xRayPlugin.update(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })

            // RN logging level
            bindLogLevel(view.findViewById(R.id.cbReactLogLevel),
                    settings.reactNativeLogLevel,
                    object : AdapterView.OnItemSelectedListener {
                        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                            settings.reactNativeLogLevel =
                                    if (LogLevel.values().size <= position) null
                                    else LogLevel.values()[position]
                            xRayPlugin.update(settings)
                        }

                        override fun onNothingSelected(parent: AdapterView<*>?) {
                        }
                    })
        }

        return view
    }

    private fun bindLogLevel(spinner: Spinner,
                             logLevel: LogLevel?,
                             listener: AdapterView.OnItemSelectedListener) {
        spinner.adapter = ArrayAdapter(
                spinner.context,
                android.R.layout.simple_list_item_1,
                listOf(*(LogLevel.values().map { it.name }.toTypedArray()), "off"))
        if (null == logLevel) {
            spinner.setSelection(LogLevel.values().size) // "off" position
        } else {
            spinner.setSelection(logLevel.level)
        }
        spinner.post { spinner.onItemSelectedListener = listener }
    }

    companion object {
        @JvmStatic
        fun newInstance() = SettingsFragment()
    }

    override fun onChanged(t: Settings?) {

    }
}
