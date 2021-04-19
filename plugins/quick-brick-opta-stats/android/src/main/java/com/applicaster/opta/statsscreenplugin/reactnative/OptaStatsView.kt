package com.applicaster.opta.statsscreenplugin.reactnative

import android.content.Context
import android.view.LayoutInflater
import android.widget.FrameLayout
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.util.APLogger

class OptaStatsView(context: Context) : FrameLayout(context) {

    init {
        APLogger.info(TAG, "OptaStatsView created")
        LayoutInflater.from(context).inflate(R.layout.fragment_home, this, true)
    }

    companion object {
        private const val TAG = "OptaStatsView"
    }
}
