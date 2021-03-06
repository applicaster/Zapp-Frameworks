package com.applicaster.plugin.didomi

import android.app.Activity
import android.app.Application
import android.content.Context
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.plugin_manager.cmp.IUserConsent
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.session.SessionStorage
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.google.gson.JsonElement
import io.didomi.sdk.Didomi
import io.didomi.sdk.events.ConsentChangedEvent
import io.didomi.sdk.events.EventListener
import io.didomi.sdk.events.HideNoticeEvent


class DidomiPlugin : GenericPluginI
        , ApplicationLoaderHookUpI
        , IUserConsent
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
                    listener.onHookFinished()
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
                                storeConsent()
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
                    storeConsent()
                    eventListener()
                }
            })
            forceShowNotice(activity)
        }
    }

    // not been called for some reason
    override fun consentChanged(event: ConsentChangedEvent?) {
        super.consentChanged(event)
        storeConsent()
    }

    private fun storeConsent() {
        PreferenceManager.getDefaultSharedPreferences(AppContext.get()).apply {
            getInt(didomiGDPRApplies, 0).let {
                SessionStorage.set(didomiGDPRApplies, it.toString(), PluginId)
                APLogger.info(TAG, "$didomiGDPRApplies $it")
            }
            getString(didomiIABConsent, null)?.let {
                SessionStorage.set(didomiIABConsent, it, PluginId)
                APLogger.info(TAG, "$didomiIABConsent $it")
            }
        }
    }

    private fun validateLogo() {
        val plugin = PluginManager.getInstance().getPlugin(PluginId)
        val bundleValue = plugin.getConfiguration()?.get(pluginAssetsKey) ?: return
        if (!bundleValue.isJsonPrimitive
                || !bundleValue.asJsonPrimitive.isString
                || bundleValue.asJsonPrimitive.asString.isEmpty()) {
            return
        }
        if (0 != Didomi.getInstance().logoResourceId) return
        APLogger.error(TAG, "Logo asset bundle zip is present, but logo image file did not match provided one provided in the console")
    }

    companion object {
        private const val TAG = "Didomi"

        const val PluginId = "applicaster-cmp-didomi"

        const val didomiGDPRApplies = "IABTCF_gdprApplies"
        const val didomiIABConsent = "IABTCF_TCString"

        private const val pluginAssetsKey = "android_assets_bundle"
    }

    override fun presentStartupNotice(activity: Activity, listener: IUserConsent.IListener) {
        Didomi.getInstance().apply {
            if (!shouldConsentBeCollected()) {
                APLogger.info(TAG, "User consent was already requested or not needed")
                storeConsent() // update values just in case
                listener.onComplete()
            } else if (!presentOnStartup) {
                APLogger.info(TAG, "User consent presentOnStartup is disabled")
                listener.onComplete()
            } else {
                APLogger.info(TAG, "User consent requested")
                addEventListener(object : EventListener() {
                    override fun hideNotice(event: HideNoticeEvent?) {
                        super.hideNotice(event)
                        removeEventListener(this)
                        storeConsent()
                        // Do the logo validation check after the notice was presented,
                        // since sometimes it's not yet initialized before that,
                        // and it's still ok to inform the user a bit later.
                        validateLogo()
                        listener.onComplete()
                    }
                })
                // force show since otherwise we don't know if it was actually shown (in an easy way), and can't unsubscribe
                forceShowNotice(activity as AppCompatActivity)
            }
        }
    }
}
