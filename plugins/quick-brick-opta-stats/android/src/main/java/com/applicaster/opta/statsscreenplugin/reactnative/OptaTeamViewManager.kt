package com.applicaster.opta.statsscreenplugin.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

class OptaTeamViewManager(context: ReactApplicationContext) : SimpleViewManager<OptaTeamView>() {

    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): OptaTeamView =
            OptaTeamView(reactContext.currentActivity!!)

    @ReactMethod
    fun setTeam(view: OptaTeamView, teamId: String) = view.setTeam(teamId)

    companion object {
        const val REACT_CLASS = "OptaTeamContainer"
    }
}