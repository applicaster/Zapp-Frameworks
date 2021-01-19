package com.applicaster.plugin.dimanager

import android.content.Context
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.delayedplugin.DelayedPlugin
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.storage.LocalStorage
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.OSUtil
import com.applicaster.util.server.ConnectionManager
import com.google.gson.JsonElement
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject

class DIManager : GenericPluginI, ApplicationLoaderHookUpI, DelayedPlugin {

    private var serverUrl: String? = null
    private var waitForCompletion = true

    override fun setPluginModel(plugin: Plugin) {
        val configuration = plugin.getConfiguration()
        if (null == configuration || configuration.isEmpty()) {
            return
        }
        waitForCompletion = asBool(configuration["wait_for_completion"])
        serverUrl = configuration["di_server_url"]?.asString
        if (serverUrl.isNullOrBlank()) {
            APLogger.error(TAG, "DIManager plugin di_server_url url is not configured")
        }
    }

    private fun asBool(jsonElement: JsonElement?): Boolean {
        if(null == jsonElement)
            return false
        return jsonElement.toString().let {
            it == "true" || it == "1"
        }
    }

    override fun executeOnApplicationReady(context: Context, listener: HookListener) {
        if (serverUrl.isNullOrBlank()) {
            listener.onHookFinished()
            return
        }
        if(!OSUtil.hasNetworkConnection(AppContext.get())) {
            APLogger.error(TAG, "No internet connection, DIManager plugin will skip token fetching")
            listener.onHookFinished()
            return
        }
        fetchUrl(if (waitForCompletion) listener else null)
        if (!waitForCompletion) {
            listener.onHookFinished()
        }
    }

    private fun fetchUrl(listener: HookListener?) {
        GlobalScope.launch {
            try {
                val result = ConnectionManager.doGet(serverUrl, null)
                APLogger.debug(TAG, "Fetched DI result: $result")
                val json = JSONObject(result)
                val token = json.optString(jwtJsonKey)
                if (token.isNullOrBlank()) {
                    APLogger.error(TAG, "DIManager plugin received empty token")
                } else {
                    LocalStorage.set(jwtStorageKey, token)
                }
            } catch (e: Exception) {
                APLogger.error(TAG, "DIManager plugin failed to fetch $serverUrl", e)
            } finally {
                listener?.onHookFinished()
            }
        }
    }

    override fun executeOnStartup(context: Context, listener: HookListener) {
        listener.onHookFinished()
    }

    override fun setPluginConfigurationParams(params: Map<*, *>?) {
        // handled in setPluginModel
    }

    companion object {
        private const val jwtJsonKey = "jwt"
        private const val jwtStorageKey = "signedDeviceInfoToken"
        private const val TAG = "DIManager"
    }

    override fun disable(): Boolean {
        LocalStorage.remove(jwtStorageKey)
        return true
    }
}