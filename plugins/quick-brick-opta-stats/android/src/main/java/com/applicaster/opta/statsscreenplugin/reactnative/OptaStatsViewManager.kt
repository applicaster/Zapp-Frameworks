package com.applicaster.opta.statsscreenplugin.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

class OptaStatsViewManager(context: ReactApplicationContext) : SimpleViewManager<OptaStatsView>() {

    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): OptaStatsView =
            OptaStatsView(reactContext)

    companion object {
        const val REACT_CLASS = "OptaStatsContainer"
    }
}