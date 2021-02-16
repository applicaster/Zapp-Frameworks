package com.applicaster.plugin.remoteinfo

import android.content.Context
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.delayedplugin.DelayedPlugin
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.session.SessionStorage
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.OSUtil
import com.applicaster.util.server.ConnectionManager
import com.google.gson.JsonElement
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject

class RemoteInfoFetcher : GenericPluginI, ApplicationLoaderHookUpI, DelayedPlugin {

    private var namespace: String? = null
    private var serverUrl: String? = null
    private var waitForCompletion = true

    override fun setPluginModel(plugin: Plugin) {
        val configuration = plugin.getConfiguration()
        if (null == configuration || configuration.isEmpty()) {
            return
        }
        waitForCompletion = asBool(configuration["wait_for_completion"])
        serverUrl = configuration["remote_url"]?.asString
        if (serverUrl.isNullOrBlank()) {
            APLogger.error(TAG, "RemoteInfoFetcher plugin remote_url url is not configured")
        }
        namespace = configuration["namespace"]?.asString
        if (namespace.isNullOrBlank()) {
            APLogger.error(TAG, "RemoteInfoFetcher plugin namespace is not configured")
        }
    }

    private fun asBool(jsonElement: JsonElement?): Boolean {
        if(null == jsonElement)
            return false
        if(!jsonElement.isJsonPrimitive) {
            APLogger.error(TAG, "RemoteInfoFetcher plugin wait_for_completion field has unexpected type $jsonElement")
            return false
        }
        if(jsonElement.asJsonPrimitive.isBoolean)
            return jsonElement.asJsonPrimitive.asBoolean
        return jsonElement.asJsonPrimitive.asString.let {
            it == "true" || it == "1"
        }
    }

    override fun executeOnApplicationReady(context: Context, listener: HookListener) {
        if (serverUrl.isNullOrBlank()) {
            listener.onHookFinished()
            return
        }
        if (namespace.isNullOrBlank()) {
            listener.onHookFinished()
            return
        }
        if(!OSUtil.hasNetworkConnection(AppContext.get())) {
            APLogger.warn(TAG, "No internet connection, RemoteInfoFetcher plugin will skip config fetching")
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
                APLogger.debug(TAG, "Fetched result: $result")
                val json = JSONObject(result)
                putToStorage(json)
            } catch (e: Exception) {
                APLogger.error(TAG, "RemoteInfoFetcher plugin failed to fetch $serverUrl", e)
            } finally {
                listener?.onHookFinished()
            }
        }
    }

    private fun putToStorage(json: JSONObject) {
        val keys = json.keys()
        while(keys.hasNext()) {
            val key = keys.next()
            val value = json.opt(key)
            SessionStorage.set(key, value?.toString(), namespace!!)
        }
    }

    override fun executeOnStartup(context: Context, listener: HookListener) {
        listener.onHookFinished()
    }

    override fun setPluginConfigurationParams(params: Map<*, *>?) {
        // handled in setPluginModel
    }

    companion object {
        private const val TAG = "RemoteInfoFetcher"
    }

    override fun disable(): Boolean {
        return true
    }
}