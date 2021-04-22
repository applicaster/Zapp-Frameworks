package com.applicaster.opta.statsscreenplugin.utils

import android.content.Context
import com.applicaster.app.CustomApplication
import com.applicaster.opta.statsscreenplugin.PluginConfigurationHandler
import android.content.Context.CONNECTIVITY_SERVICE
import android.net.ConnectivityManager
import android.util.Log
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.util.AppContext


class PluginUtils {
    companion object {

        const val TAG = "PluginUtils"

        var configurationHandler: PluginConfigurationHandler = PluginConfigurationHandler()
        fun goToMatchDetailsScreen(matchId: String) {
            val data: MutableMap<String, String> =
                    hashMapOf("type" to "general",
                            "action" to "stats_open_screen",
                            "screen_id" to "match_details_screen",
                            "match_id" to matchId)
            configurationHandler.handlePluginScheme(AppContext.get(), data)
        }

        fun goToTeamScreen(teamId: String) {
            val data: MutableMap<String, String> =
                    hashMapOf("type" to "general",
                            "action" to "stats_open_screen",
                            "screen_id" to "team_screen",
                            "team_id" to teamId)
            configurationHandler.handlePluginScheme(AppContext.get(), data)
        }

        fun goToPlayerScreen(playerId: String) {
            if (PluginDataRepository.INSTANCE.isPlayerScreenEnabled()) {
                val data: MutableMap<String, String> =
                        hashMapOf("type" to "general",
                                "action" to "stats_open_screen",
                                "screen_id" to "player_screen",
                                "player_id" to playerId)
                configurationHandler.handlePluginScheme(AppContext.get(), data)
            } else {
                Log.d(TAG, "Navigation to Player screen has blocked in the configuration.")
            }
        }

        fun isNetworkConnected(context: Context): Boolean {
            val cm = context.getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
            val info = cm.activeNetworkInfo
            return info != null && info.isConnected

        }
    }
}
