package com.applicaster.plugin.didomi

import android.app.Application
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.util.APLogger
import com.google.gson.JsonElement
import io.didomi.sdk.Didomi


// todo: RN bridge
// todo: callbacks? At least for logging

class DidomiPlugin : GenericPluginI, ApplicationLoaderHookUpI {

    private var apiToken: String? = null
    private var presentOnStartup = true

    override fun setPluginModel(plugin: Plugin) {
        val configuration = plugin.getConfiguration()
        if (null == configuration || configuration.isEmpty()) {
            return
        }
        presentOnStartup = asBool(configuration["present_on_startup"])
        apiToken = configuration["api_key"]?.asString
        if (apiToken.isNullOrBlank()) {
            APLogger.error(TAG, "Didomi plugin api_key is not configured")
        }
    }

    // todo: move to Core SDK
    private fun asBool(jsonElement: JsonElement?): Boolean {
        if(null == jsonElement)
            return false
        if(!jsonElement.isJsonPrimitive) {
            APLogger.error(TAG, "Didomi plugin present_on_startup field has unexpected type $jsonElement")
            return false
        }
        if(jsonElement.asJsonPrimitive.isBoolean)
            return jsonElement.asJsonPrimitive.asBoolean
        return jsonElement.asJsonPrimitive.asString.let {
            it == "true" || it == "1"
        }
    }

    override fun executeOnApplicationReady(context: Context, listener: HookListener) {
        if (apiToken.isNullOrBlank()) {
            listener.onHookFinished()
            return
        }

//        if(!OSUtil.hasNetworkConnection(AppContext.get())) {
//            APLogger.error(TAG, "No internet connection, Didomi plugin will skip waiting")
//            listener.onHookFinished()
//            return
//        }

        try {
            Didomi.getInstance().apply {
                initialize(
                        context.applicationContext as Application,
                        apiToken,
                        null,
                        null,
                        null,
                        false
                )
                onReady {
                    APLogger.info(TAG, "Didomi initialized")
                    if (hasAnyStatus() || !presentOnStartup) {
                        APLogger.info(TAG, "User consent was already requested or presentOnStartup is disabled")
                        listener.onHookFinished()
                    } else {
                        APLogger.info(TAG, "User consent requested")
                        this.showNotice(context as AppCompatActivity)
                    }
                }
                onError {
                    APLogger.error(TAG, "Didomi has failed to initialize")
                    listener.onHookFinished()
                }
            }
        } catch (e: Exception) {
            APLogger.error(TAG, "Didomi has failed to initialize", e)
            listener.onHookFinished()
        }
    }

    override fun executeOnStartup(context: Context, listener: HookListener) {
        listener.onHookFinished()
    }

    override fun setPluginConfigurationParams(params: Map<*, *>?) {
        // handled in setPluginModel
    }

    companion object {
        private const val TAG = "Didomi"
    }
}