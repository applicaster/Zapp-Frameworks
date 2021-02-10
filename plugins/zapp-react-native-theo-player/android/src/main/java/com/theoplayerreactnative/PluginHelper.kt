package com.theoplayerreactnative

import com.applicaster.plugin_manager.PluginManager

object PluginHelper {

    private const val PLUGIN_ID = "zapp-react-native-theo-player"

    @JvmStatic
    fun getLicense() : String {
        val configuration = PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
        return configuration?.get("theoplayer_license_key")?.asJsonPrimitive?.asString?:""
    }

    @JvmStatic
    fun getCastApplicationId() : String? {
        val configuration = PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
        return configuration?.get("chromecast_reciever_application_id")?.asJsonPrimitive?.asString
    }
}
