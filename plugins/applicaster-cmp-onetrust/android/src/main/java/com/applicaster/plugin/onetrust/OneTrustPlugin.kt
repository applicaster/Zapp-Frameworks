package com.applicaster.plugin.onetrust

import android.content.Context
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.session.SessionStorage
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.AppData
import com.google.gson.JsonElement
import com.onetrust.otpublishers.headless.Public.OTCallback
import com.onetrust.otpublishers.headless.Public.OTEventListener
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK
import com.onetrust.otpublishers.headless.Public.Response.OTResponse

class OneTrustPlugin : GenericPluginI, ApplicationLoaderHookUpI {

    private var storageLocation: String? = null
    private var domainIdentifier: String? = null
    private var presentOnStartup = true

    private lateinit var sdk: OTPublishersHeadlessSDK

    override fun setPluginModel(plugin: Plugin) {
        val configuration = plugin.getConfiguration()
        if (null == configuration || configuration.isEmpty()) {
            return
        }
        presentOnStartup = asBool(configuration["present_on_startup"])
        domainIdentifier = configuration["domain_identifier"]?.asString
        if (!isDomainIdValid()) {
            APLogger.error(TAG, "OneTrust plugin domain_identifier is not configured")
        }
        storageLocation = configuration["storage_location"]?.asString
        if (!isStorageValid()) {
            APLogger.error(TAG, "OneTrust plugin storage_location is not configured")
        }
    }

    // todo: move to Core SDK
    private fun asBool(jsonElement: JsonElement?): Boolean {
        if(null == jsonElement)
            return false
        if(!jsonElement.isJsonPrimitive) {
            APLogger.error(TAG, "OneTrust plugin present_on_startup field has unexpected type $jsonElement")
            return false
        }
        if(jsonElement.asJsonPrimitive.isBoolean)
            return jsonElement.asJsonPrimitive.asBoolean
        return jsonElement.asJsonPrimitive.asString.let {
            it == "true" || it == "1"
        }
    }

    private var callback: (() -> Unit)? = null
    // there is no unsubscribe method, so have to sue single listener
    private val eventRouter = EventListener()

    inner class EventListener : OTEventListener() {

        override fun onShowBanner() = Unit

        override fun onHideBanner() = Unit

        override fun onBannerClickedAcceptAll() = enableAnalytics(true)

        override fun onBannerClickedRejectAll() = enableAnalytics(false)

        override fun onShowPreferenceCenter() = Unit

        override fun onHidePreferenceCenter() = Unit

        override fun onPreferenceCenterAcceptAll() = enableAnalytics(true)

        override fun onPreferenceCenterRejectAll() = enableAnalytics(false)

        override fun onPreferenceCenterConfirmChoices() = Unit

        override fun onShowVendorList() = Unit

        override fun onHideVendorList() = Unit

        override fun onVendorConfirmChoices() = Unit

        override fun allSDKViewsDismissed(p0: String?) {
            storeConsent(true)
            callback?.let {
                it()
                callback = null
            }
        }

        override fun onVendorListVendorConsentChanged(p0: String?, p1: Int) = Unit

        override fun onVendorListVendorLegitimateInterestChanged(p0: String?, p1: Int) = Unit

        override fun onPreferenceCenterPurposeConsentChanged(p0: String?, p1: Int) = Unit

        override fun onPreferenceCenterPurposeLegitimateInterestChanged(p0: String?, p1: Int) = Unit
    }

    override fun executeOnApplicationReady(context: Context,
                                           listener: HookListener) {
        if (!isDomainIdValid() || !isStorageValid()) {
            listener.onHookFinished() // we've already complained
            return
        }

        val language = AppData.getLocale()?.language ?: "en"

        try {
            sdk = OTPublishersHeadlessSDK(context.applicationContext)
            sdk.startSDK(storageLocation!!, domainIdentifier!!, language, null, object : OTCallback{
                override fun onSuccess(otResponse: OTResponse) {
                    isReady = true
                    APLogger.info(TAG, "OneTrust initialized: $otResponse")
                    sdk.addEventListener(eventRouter)
                    if (!sdk.shouldShowBanner()) {
                        APLogger.info(TAG, "User consent was already requested or not needed")
                        storeConsent(true) // update values just in case
                        listener.onHookFinished()
                    } else if (!presentOnStartup) {
                        APLogger.info(TAG, "User consent presentOnStartup is disabled")
                        storeConsent(false)
                        listener.onHookFinished()
                    } else {
                        APLogger.info(TAG, "User consent requested")
                        showNotice(context as AppCompatActivity) { listener.onHookFinished() }
                    }
                }

                override fun onFailure(otResponse: OTResponse) {
                    APLogger.error(TAG, "OneTrust has failed to initialize: $otResponse")
                    listener.onHookFinished()
                }

            })
        } catch (e: Exception) {
            APLogger.error(TAG, "OneTrust has failed to initialize", e)
            listener.onHookFinished()
        }
    }

    override fun executeOnStartup(context: Context,
                                  listener: HookListener) = listener.onHookFinished()

    override fun setPluginConfigurationParams(params: Map<*, *>?) {
        // handled in setPluginModel
    }

    private fun isDomainIdValid() = !domainIdentifier.isNullOrBlank()
    private fun isStorageValid() = !storageLocation.isNullOrBlank()

    var isReady: Boolean = false
        private set

    fun showPreferences(activity: AppCompatActivity,
                        eventListener: () -> Unit) =
            checkedCall(eventListener) { sdk.showPreferenceCenterUI(activity) }

    fun showNotice(activity: AppCompatActivity,
                   eventListener: () -> Unit) =
            checkedCall(eventListener) { sdk.showBannerUI(activity) }

    private fun checkedCall(eventListener: () -> Unit,
                            sdkCall: () -> Unit) {
        if (!isReady) {
            // should not happen, we have a check on the bridge
            APLogger.info(TAG, "showPreferences call failed: OneTrust library is not ready or failed to init.")
            eventListener()
            return
        }
        if(null != callback) {
            APLogger.error(TAG, "Another call is in progress, it will be overridden")
        }
        callback = eventListener
        sdkCall()
    }

    private fun storeConsent(shouldWarn: Boolean) {
        PreferenceManager.getDefaultSharedPreferences(AppContext.get()).apply {
            val allKeys = all
            for (key in requiredKeys) {
                when (val v = allKeys[key]) {
                    null -> if(shouldWarn) APLogger.error(TAG, "$key is not found in preferences")
                    else -> {
                        SessionStorage.set(key, v.toString(), PluginId)
                        APLogger.info(TAG, "Saved $key $v")
                    }
                }
            }
        }
    }

    private fun enableAnalytics(enable: Boolean) {
        AppContext.get().let {
            if (enable) {
                AnalyticsAgentUtil.getInstance().setAnalyticsEnabled(true, it)
                AnalyticsAgentUtil.resumeTracking(it)
            } else {
                AnalyticsAgentUtil.pauseTracking(it)
                AnalyticsAgentUtil.getInstance().setAnalyticsEnabled(false, it)
            }
        }
    }

    companion object {
        private const val TAG = "OneTrust"

        const val PluginId = "applicaster-cmp-onetrust"

        val requiredKeys = setOf("IABTCF_gdprApplies", "IABUSPrivacy_String")
    }
}
