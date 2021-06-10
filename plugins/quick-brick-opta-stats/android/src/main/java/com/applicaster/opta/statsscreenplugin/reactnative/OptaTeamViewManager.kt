package com.applicaster.opta.statsscreenplugin.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class OptaTeamViewManager(context: ReactApplicationContext) : SimpleViewManager<OptaTeamView>() {

    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(reactContext: ThemedReactContext): OptaTeamView =
            OptaTeamView(reactContext.currentActivity!!)

    @ReactProp(name = "team")
    fun setTeam(view: OptaTeamView, teamId: String) = view.setTeam(teamId)

    companion object {
        const val REACT_CLASS = "OptaTeamContainer"
    }
}