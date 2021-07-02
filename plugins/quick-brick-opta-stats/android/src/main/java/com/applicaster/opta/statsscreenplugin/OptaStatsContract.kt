package com.applicaster.opta.statsscreenplugin

import android.graphics.Color
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.utils.Constants
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext

class OptaStatsContract : GenericPluginI {

    companion object {
        const val TAG: String = "COPAOptaStatsContract"
        private val REQUIRED_KEYS = arrayOf(
                //Constants.PARAM_SHIELD_IMAGE_BASE_URL,
                //Constants.PARAM_FLAG_IMAGE_BASE_URL,
                //Constants.PARAM_PERSON_IMAGE_BASE_URL,
                //Constants.PARAM_SHIRT_IMAGE_BASE_URL,
                //Constants.PARAM_PARTIDOS_IMAGE_BASE_URL,
                Constants.PARAM_TOKEN,
                Constants.PARAM_COMPETITION_ID,
                Constants.PARAM_CALENDAR_ID,
                Constants.PARAM_REFERER,
                Constants.PARAM_NUMBER_OF_MATCHES);
    }

    // since the plugin can be opened through url scheme, in case the user opens the plugin a screen
    // that is launch with url scheme, the plugin will not be initialized and the app will crash.
    // the "nasty" solution for this is having parameters in standard configuration and plugin
    // screen configuration
    override fun setPluginModel(plugin: Plugin?) {
        if (setPluginConfiguration(plugin?.configuration as? Map<*, *>?)) {
            APLogger.debug(TAG, "plugin initialized")
        } else {
            APLogger.error(TAG, "plugin not initialized")
        }
    }

    fun setPluginConfiguration(params: Map<*, *>?): Boolean {
        // first check if any of the params are null
        if (!checkParamsAreSet(params))
            return false

        params?.let {
            val baseUrl = params[Constants.PARAM_IMAGE_BASE_URL] as String
            PluginDataRepository.INSTANCE.setShieldImageBaseUrl("$baseUrl/SHIELD-")
            PluginDataRepository.INSTANCE.setFlagImageBaseUrl("$baseUrl/flag-")
            PluginDataRepository.INSTANCE.setPersonImageBaseUrl(baseUrl)
            PluginDataRepository.INSTANCE.setShirtImageBaseUrl("$baseUrl/SHIRT-")
            PluginDataRepository.INSTANCE.setPartidosImageBaseUrl("$baseUrl/all-matches-2021-") // todo: make suffix a settings

//            PluginDataRepository.INSTANCE.setShieldImageBaseUrl(params[Constants.PARAM_SHIELD_IMAGE_BASE_URL].toString())
//            PluginDataRepository.INSTANCE.setFlagImageBaseUrl(params[Constants.PARAM_FLAG_IMAGE_BASE_URL].toString())
//            PluginDataRepository.INSTANCE.setPersonImageBaseUrl(params[Constants.PARAM_PERSON_IMAGE_BASE_URL].toString())
//            PluginDataRepository.INSTANCE.setPartidosImageBaseUrl(params[Constants.PARAM_PARTIDOS_IMAGE_BASE_URL].toString())
//            PluginDataRepository.INSTANCE.setShirtImageBaseUrl(params[Constants.PARAM_SHIRT_IMAGE_BASE_URL].toString())

            PluginDataRepository.INSTANCE.setToken(params[Constants.PARAM_TOKEN].toString())
            PluginDataRepository.INSTANCE.setCompetitionId(params[Constants.PARAM_COMPETITION_ID].toString())
            PluginDataRepository.INSTANCE.setCalendarId(params[Constants.PARAM_CALENDAR_ID].toString())
            PluginDataRepository.INSTANCE.setReferer(params[Constants.PARAM_REFERER].toString())
            PluginDataRepository.INSTANCE.setNumberOfMatches(params[Constants.PARAM_NUMBER_OF_MATCHES].toString())
            PluginDataRepository.INSTANCE.setShowTeam(params[Constants.PARAM_SHOW_TEAM])
            PluginDataRepository.INSTANCE.setTeamsCount(params[Constants.PARAM_TEAMS_COUNT].toString().toIntOrNull())

            PluginDataRepository.INSTANCE.setLogoUrl(params[Constants.PARAM_LOGO_URL].toString())

            (params[Constants.PARAM_NAV_BAR_COLOR] as? String)?.let {
                try {
                    val color = Color.parseColor(it)
                    PluginDataRepository.INSTANCE.setNavBarColor(color)
                } catch (e: Exception){
                    APLogger.error(TAG, "Failed to parse nav bar color $it", e)
                    PluginDataRepository.INSTANCE.setNavBarColor(AppContext.get().resources.getColor(R.color.bg_toolbar))
                }
            }

            val playerScreen = params[Constants.PARAM_ENABLE_PLAYER_SCREEN] ?: "1"
            PluginDataRepository.INSTANCE.enablePlayerScreen(playerScreen == "1" || playerScreen == true)

            PluginDataRepository.INSTANCE.setMainScreenMode(params[Constants.PARAM_MAIN_SCREEN_MODE].toString())
            PluginDataRepository.INSTANCE.setAllMatchesBannerPosition(params[Constants.PARAM_ALL_MATCHES_BANNER_POSITION].toString())

            return true
        }

        return false
    }

    private fun checkParamsAreSet(params: Map<*, *>?): Boolean {
        if(null == params)
            return false
        REQUIRED_KEYS.forEach {
            if((params[it] as? String).isNullOrEmpty()) {
                APLogger.warn(TAG, "Parameter $it is missing in plugin configuration")
                return false
            }
        }
        return true
    }

}
