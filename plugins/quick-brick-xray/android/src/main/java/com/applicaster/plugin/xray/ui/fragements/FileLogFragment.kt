package com.applicaster.plugin.xray.ui.fragements

import android.os.Bundle
import android.os.FileObserver
import android.text.TextUtils
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.xray.crashreporter.Reporting
import java.io.File

class FileLogFragment : Fragment() {

    private var observer: FileObserver? = null
    private var logView: TextView? = null
    private var file: File? = null
    private var btnClear: Button? = null
    private var btnSend: Button? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_log, container, false)
        file = activity!!.getFileStreamPath(XRayPlugin.fileSinkFileName)
        logView = view.findViewById(R.id.lbl_log)
        btnSend = view.findViewById(R.id.btn_send)
        btnSend?.setOnClickListener { send() }
        btnClear = view.findViewById(R.id.btn_clear)
        btnClear?.setOnClickListener { clear() }
        @Suppress("DEPRECATION")
        observer = object : FileObserver(file?.absolutePath, CLOSE_WRITE or DELETE_SELF) {
            override fun onEvent(event: Int, path: String?) {
                reloadLog()
            }
        }
        view.setTag(R.id.fragment_title_tag, file!!.name)
        return view
    }

    private fun reloadLog() {
        if(null == logView) {
            return
        }
        var hasLog = false
        if (!file!!.exists()) {
            logView?.text = "[Not found]"
        } else {
            observer?.startWatching() // can be called multiple times, no problem
            val log = file!!.readText(Charsets.UTF_8)
            hasLog = !TextUtils.isEmpty(log)
            logView?.text = if (hasLog) log else "[Empty]"
        }
        btnSend?.isEnabled = hasLog
        btnClear?.isEnabled = hasLog
    }

    override fun onPause() {
        super.onPause()
        observer?.stopWatching()
    }

    override fun onResume() {
        super.onResume()
        reloadLog()
    }

    private fun send() {
        if(file!!.exists()) {
            Reporting.sendLogReport(activity!!, file)
        }
    }

    private fun clear() {
        if(file!!.delete()) {
            logView!!.text = "[Not found]"
            btnSend?.isEnabled = false
            btnClear?.isEnabled = false
        }
    }

    companion object {
        @JvmStatic
        fun newInstance() = FileLogFragment()
    }
}
