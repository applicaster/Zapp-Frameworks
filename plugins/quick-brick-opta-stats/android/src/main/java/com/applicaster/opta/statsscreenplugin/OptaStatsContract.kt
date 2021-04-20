package com.applicaster.opta.statsscreenplugin

import android.content.Context
import android.util.Log
import androidx.fragment.app.Fragment
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.error.ErrorFragment
import com.applicaster.opta.statsscreenplugin.screens.home.HomeFragment
import com.applicaster.opta.statsscreenplugin.utils.Constants
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.util.APLogger
import com.google.gson.internal.LinkedTreeMap
import java.io.Serializable
import java.util.*
import kotlin.collections.ArrayList

class OptaStatsContract : /*PluginScreen, PluginSchemeI,*/ GenericPluginI {

    companion object {
        private const val TAG: String = "COPAOptaStatsContract"
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

    private var configurationHandler: PluginConfigurationHandler = PluginConfigurationHandler()

    /*override*/ fun generateFragment(screenMap: HashMap<String, Any>?, dataSource: Serializable?): Fragment {
        Log.d(TAG, "generateFragment ${screenMap?.get("name").toString()}")
        screenMap?.let {
            PluginDataRepository.INSTANCE.setAppId(it["name"].toString())
            // this piece of code is really unstable because is doing a lot of casts and
            // the access to the assets are not friendly enough to trust
            // that's why it's surrounded by a try catch block
            getNavigationAssets(it)
            return if (setPluginConfiguration(it["general"] as LinkedTreeMap<*, *>)) HomeFragment()
            else ErrorFragment()
        }
        return ErrorFragment()
    }

    private fun getNavigationAssets(screenMap: HashMap<String, Any>) {
        try {
            // get navigation assets (logo and back button)
            if (screenMap["navigations"] is ArrayList<*>) {
                getNavigationAssets(screenMap["navigations"] as ArrayList<*>)
            }
        } catch (exception: Exception) {
            Log.e(this.javaClass.simpleName, exception.message)
        }
    }

    private fun getNavigationAssets(navigationsParams: ArrayList<*>) {
        for (navigation in navigationsParams) {
            if ((navigation is LinkedTreeMap<*, *>) &&
                    (navigation["assets"] as LinkedTreeMap<*, *>).isNotEmpty()) {
                val assets: LinkedTreeMap<*, *> = navigation["assets"] as LinkedTreeMap<*, *>
                PluginDataRepository.INSTANCE.setLogoUrl(assets["app_logo"].toString())
                PluginDataRepository.INSTANCE.setBackButtonUrl(assets["back_button"].toString())
            }
        }
    }

    /*override*/ fun handlePluginScheme(context: Context, data: Map<String, String>): Boolean {
        return configurationHandler.handlePluginScheme(context, data)
    }

    // since the plugin can be opened through url scheme, in case the user opens the plugin a screen
    // that is launch with url scheme, the plugin will not be initialized and the app will crash.
    // the "nasty" solution for this is having parameters in standard configuration and plugin
    // screen configuration
    override fun setPluginModel(plugin: Plugin?) {
        if (setPluginConfiguration(plugin?.configuration as? Map<*, *>?)) {
            Log.d(this.javaClass.simpleName, "plugin initialized")
        } else {
            Log.d(this.javaClass.simpleName, "plugin not initialized")
        }
    }

    private fun setPluginConfiguration(params: Map<*, *>?): Boolean {
        // first check if any of the params are null
        if (!checkParamsAreSet(params))
            return false

        params?.let {
            val baseUrl = params[Constants.PARAM_IMAGE_BASE_URL] as String
            PluginDataRepository.INSTANCE.setShieldImageBaseUrl("$baseUrl/shields/")
            PluginDataRepository.INSTANCE.setFlagImageBaseUrl("$baseUrl/flags/")
            PluginDataRepository.INSTANCE.setPersonImageBaseUrl(baseUrl)
            PluginDataRepository.INSTANCE.setShirtImageBaseUrl("$baseUrl/shirts/")
            PluginDataRepository.INSTANCE.setPartidosImageBaseUrl("$baseUrl/partidos/")

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

            val playerScreen = params[Constants.PARAM_ENABLE_PLAYER_SCREEN] ?: "1"
            PluginDataRepository.INSTANCE.enablePlayerScreen(playerScreen == "1" || playerScreen == true)
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

    /*override*/ fun present(context: Context?, screenMap: HashMap<String, Any>?, dataSource: Serializable?, isActivity: Boolean) {
        // do nothing
    }
}
