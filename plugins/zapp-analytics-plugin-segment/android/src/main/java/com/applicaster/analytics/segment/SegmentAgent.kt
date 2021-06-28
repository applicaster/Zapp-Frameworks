package com.applicaster.analytics.segment

import android.content.Context
import androidx.annotation.CallSuper
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.util.APLogger
import com.segment.analytics.Analytics
import com.segment.analytics.Properties
import com.segment.analytics.Traits
import java.text.SimpleDateFormat
import java.util.*

class SegmentAgent : BaseAnalyticsAgent() {

    private var analytics: Analytics? = null
    private var writeKey: String = ""
    private var identity: Identity? = null

    override fun initializeAnalyticsAgent(context: Context) {
        super.initializeAnalyticsAgent(context)
        init(context)
    }

    private fun init(context: Context) {
        if (analytics != null) {
            return
        }
        if (writeKey.isEmpty()) {
            APLogger.error(TAG, "segment_write_key is empty. Analytics agent won't be activated")
            return
        }
        analytics = Analytics.Builder(context, writeKey)
                .trackApplicationLifecycleEvents() // Enable this to record certain application events automatically!
                .recordScreenViews() // Enable this to record screen views automatically!
                .build()
        identity?.let {
            reportIdentity(it, analytics!!)
        }
        APLogger.info(TAG, "Initialization complete")
    }

    override fun setParams(params: MutableMap<Any?, Any?>) {
        super.setParams(params)
        writeKey = params["segment_write_key"]?.toString() ?: ""
        if (writeKey.isEmpty()) {
            APLogger.error(TAG, "segment_write_key is empty. Analytics agent won't be activated")
        }
        params[BLACKLISTED_EVENTS_LIST_KEY]?.let {
            val list = it as? String
            if (!list.isNullOrEmpty()) {
                val events = list
                        .split(BLACKLISTED_EVENTS_LIST_DELIMITER)
                        .map { it.trim().toLowerCase(Locale.ENGLISH) }
                if (events.isNotEmpty()) {
                    blackListEvents.addAll(events)
                }
            }
        }
    }

    override fun logEvent(eventName: String?) {
        super.logEvent(eventName)
        eventName?.apply {
            analytics?.track(this)
        }
    }

    override fun logEvent(eventName: String?, params: TreeMap<String, String>?) {
        super.logEvent(eventName, params)
        if(null == eventName) {
            return
        }
        analytics?.let {
            APLogger.debug(TAG, "eventName $eventName")
            val properties = Properties().putMap(params).apply {
                putValue("name", eventName)
                putValue("timestamp", dateFormat.format(Date()))
                putValue("applicaster_device_id", it.analyticsContext?.traits()?.anonymousId())
                remove("Platform") // Remove param added by the SDK, the OC player is adding it instead
            }
            it.track(eventName, properties)
        }
    }

    private fun Properties.putMap(params: Map<String, String>?): Properties {
        params?.forEach { (key, value) ->
            put(key, value)
        }
        return this
    }

    @CallSuper
    override fun resumeTracking(context: Context) {
        super.resumeTracking(context)
        APLogger.info(TAG, "Resuming tracking")
        init(context)
    }

    @CallSuper
    override fun pauseTracking(context: Context) {
        super.pauseTracking(context)
        analytics?.let {
            APLogger.info(TAG, "Shutting down")
            analytics = null
            it.shutdown()
        }
    }

    data class Identity(val userId: String,
                        val traits: HashMap<String, Any>,
                        val options: HashMap<String, Any>)

    fun setUserIdentify(identity: Identity) {
        this.identity = identity
        val analyticsInstance = analytics
        when {
            null != analyticsInstance && AnalyticsAgentUtil.getInstance().analyticsEnabled -> {
                reportIdentity(identity, analyticsInstance)
            }
            else -> {
                APLogger.info(TAG, "Analytics is disabled or not yet initialized, " +
                        "identifyUser call information will be postponed until reporting is enabled")
            }
        }
    }

    private fun reportIdentity(identity: Identity,
                               analyticsInstance: Analytics) {
        val newTraits = Traits()

        // Add context traits
        //for (trait in analytics.analyticsContext.traits()) {
        //    newTraits.putValue(trait.key, trait.value)
        //}

        // Add additional traits
        for (entry in identity.traits) {
            newTraits.putValue(entry.key, entry.value)
        }

        // Add new options
        val newOptions = analyticsInstance.defaultOptions
        newOptions?.context()?.putAll(identity.options)
        analyticsInstance.identify(identity.userId, newTraits, newOptions)
        APLogger.info(TAG, "User identity information updated")
    }

    companion object {
        private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.UK)
        private const val TAG = "SegmentAgent"

        const val pluginId = "segment_analytics"

        // plugin uses different key and separator from the base class
        private const val BLACKLISTED_EVENTS_LIST_KEY = "blacklisted_events_list"
        private const val BLACKLISTED_EVENTS_LIST_DELIMITER = ","

        @JvmStatic
        fun instance(): SegmentAgent? =
                PluginManager.getInstance().getInitiatedPlugin(pluginId)?.instance as SegmentAgent?
    }
}