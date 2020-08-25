package com.applicaster.plugin.xray.ui.fragements

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.applicaster.plugin.xray.R

class SettingsFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_settings, container, false)
        view.setTag(R.id.fragment_title_tag, "Settings")
        return view
    }

    companion object {
        @JvmStatic
        fun newInstance() = SettingsFragment()
    }
}
