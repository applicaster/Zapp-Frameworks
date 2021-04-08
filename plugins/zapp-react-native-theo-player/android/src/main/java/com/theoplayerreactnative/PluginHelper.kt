package com.theoplayerreactnative

import com.applicaster.plugin_manager.PluginManager
import com.google.gson.JsonElement

object PluginHelper {

    private const val PLUGIN_ID = "zapp-react-native-theo-player"
    private const val LICENSE_KEY = "theoplayer_license_key"
    private const val SCALE_MODE_KEY = "theoplayer_scale_mode"
    private const val CAST_KEY = "chromecast_app_id"
    private const val MOAT_PARTNER_CODE_KEY = "moat_partner_code";

    @JvmStatic
    fun getLicense(): String {
        val configuration = getPluginSettings()
        return configuration?.get(LICENSE_KEY)?.asJsonPrimitive?.asString ?: ""
    }

    @JvmStatic
    fun getScaleMode(): String {
        val configuration = getPluginSettings()
        return configuration?.get(SCALE_MODE_KEY)?.asJsonPrimitive?.asString ?: "style-fit"
    }

    @JvmStatic
    fun getCastApplicationId(): String? {
        val configuration = getPluginSettings()
        return configuration?.get(CAST_KEY)?.asJsonPrimitive?.asString
    }

    @JvmStatic
    fun getMoat(): String? {
        val configuration = getPluginSettings()
        return configuration?.get(MOAT_PARTNER_CODE_KEY)?.asJsonPrimitive?.asString
    }

    private fun getPluginSettings(): Map<String, JsonElement>? =
            PluginManager.getInstance().getPlugin(PLUGIN_ID)?.getConfiguration()
}
