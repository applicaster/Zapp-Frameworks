package com.theoplayerreactnative

import com.applicaster.plugin_manager.PluginManager

object PluginHelper {

    private const val PLUGIN_ID = "zapp-react-native-theo-player"
    private const val LICENSE_KEY = "theoplayer_license_key"
    private const val CAST_KEY = "chromecast_reciever_application_id"
    private const val MOAT_PARTNER_CODE_KEY = "moat_partner_code";

    @JvmStatic
    fun getLicense() : String {
        val configuration = PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
        return configuration?.get(LICENSE_KEY)?.asJsonPrimitive?.asString?:""
    }

    @JvmStatic
    fun getCastApplicationId() : String? {
        val configuration = PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
        return configuration?.get(CAST_KEY)?.asJsonPrimitive?.asString
    }

    @JvmStatic
    fun getMoat() : String? {
        val configuration = PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
        return configuration?.get(MOAT_PARTNER_CODE_KEY)?.asJsonPrimitive?.asString
    }
}
