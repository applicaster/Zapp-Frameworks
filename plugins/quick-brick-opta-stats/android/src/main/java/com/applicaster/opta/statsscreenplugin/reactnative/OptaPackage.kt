package com.applicaster.opta.statsscreenplugin.reactnative

import com.applicaster.opta.statsscreenplugin.OptaStatsContract
import com.applicaster.opta.statsscreenplugin.utils.Constants
import com.applicaster.plugin_manager.PluginManager
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class OptaPackage : ReactPackage {

    init {
        // hack to force update params
        PluginManager.getInstance().getInitiatedPlugin(Constants.PLUGIN_ID)?.let {
            (it.instance as OptaStatsContract).setPluginConfiguration(it.plugin.configuration)
        }
    }

    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
            listOf<NativeModule>(OptaBridge(reactContext))

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> =
            listOf(OptaStatsViewManager(reactContext), OptaTeamViewManager(reactContext))
}