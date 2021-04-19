package com.applicaster.opta.statsscreenplugin.reactnative

import android.content.Context
import android.view.LayoutInflater
import android.widget.FrameLayout
import com.applicaster.opta.statsscreenplugin.R

class OptaStatsView(context: Context) : FrameLayout(context) {

    init {
        LayoutInflater.from(context).inflate(R.layout.fragment_home, this, true)
    }

}
