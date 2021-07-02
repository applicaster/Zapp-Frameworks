package com.applicaster.opta.statsscreenplugin.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

class OptaStatsViewManager(context: ReactApplicationContext) : SimpleViewManager<OptaHomeView>() {

    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): OptaHomeView =
            OptaHomeView(reactContext.currentActivity!!)

    companion object {
        const val REACT_CLASS = "OptaStatsContainer"
    }
}