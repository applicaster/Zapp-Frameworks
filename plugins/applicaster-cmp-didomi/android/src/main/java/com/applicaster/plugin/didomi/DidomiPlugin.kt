package com.applicaster.plugin.didomi

import android.app.Application
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.storage.LocalStorage
import com.applicaster.util.APLogger
import com.google.gson.JsonElement
import io.didomi.sdk.Didomi
import io.didomi.sdk.events.ConsentChangedEvent
import io.didomi.sdk.events.EventListener
import io.didomi.sdk.events.HideNoticeEvent


class DidomiPlugin : GenericPluginI
        , ApplicationLoaderHookUpI
        , EventListener() {

    private var apiToken: String? = null
    private var presentOnStartup = true

    override fun setPluginModel(plugin: Plugin) {
        val configuration = plugin.getConfiguration()
        if (null == configuration || configuration.isEmpty()) {
            return
        }
        presentOnStartup = asBool(configuration["present_on_startup"])
        apiToken = configuration["api_key"]?.asString
        if (!isAPITokenValid()) {
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

    override fun executeOnApplicationReady(context: Context,
                                           listener: HookListener) {
        if (!isAPITokenValid()) {
            listener.onHookFinished() // we've already complained
            return
        }

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
                addEventListener(this@DidomiPlugin)
                onReady {
                    APLogger.info(TAG, "Didomi initialized")
                    if (hasAnyStatus()) {
                        APLogger.info(TAG, "User consent was already requested")
                        listener.onHookFinished()
                    } else if (!presentOnStartup) {
                        APLogger.info(TAG, "User consent presentOnStartup is disabled")
                        listener.onHookFinished()
                    } else {
                        APLogger.info(TAG, "User consent requested")
                        addEventListener(object : EventListener() {
                            override fun hideNotice(event: HideNoticeEvent?) {
                                super.hideNotice(event)
                                removeEventListener(this)
                                listener.onHookFinished()
                            }
                        })
                        // force show since otherwise we don't know if it was actually shown (in an easy way), and can't unsubscribe
                        forceShowNotice(context as AppCompatActivity)
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

    override fun executeOnStartup(context: Context,
                                  listener: HookListener) = listener.onHookFinished()

    override fun setPluginConfigurationParams(params: Map<*, *>?) {
        // handled in setPluginModel
    }

    private fun isAPITokenValid() = !apiToken.isNullOrBlank()

    fun isReady() = Didomi.getInstance().isReady

    fun showPreferences(eventListener: () -> Unit,
                        activity: AppCompatActivity) {
        Didomi.getInstance().showPreferences(activity).let {
            // hack since there is no event coming from Didomi when user presses back without doing anything
            activity.supportFragmentManager.apply {
                registerFragmentLifecycleCallbacks(
                        object : FragmentManager.FragmentLifecycleCallbacks() {
                            override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
                                super.onFragmentDetached(fm, f)
                                if (f != it)
                                    return
                                unregisterFragmentLifecycleCallbacks(this)
                                eventListener()
                            }
                        }, false)
            }
        }
    }

    fun showNotice(eventListener: () -> Unit,
                   activity: AppCompatActivity) {
        Didomi.getInstance().apply {
            addEventListener(object : EventListener() {
                override fun hideNotice(event: HideNoticeEvent?) {
                    super.hideNotice(event)
                    removeEventListener(this)
                    eventListener()
                }
            })
            forceShowNotice(activity)
        }
    }

    override fun consentChanged(event: ConsentChangedEvent?) {
        super.consentChanged(event)
        LocalStorage.set(JSPreferencesKey, Didomi.getInstance().javaScriptForWebView, PluginId)
        // todo: store enabled/disabled vendors/purposes
    }

    companion object {
        private const val TAG = "Didomi"
        const val PluginId = "applicaster-cmp-didomi"
        const val JSPreferencesKey = "javaScriptForWebView"
    }
}
