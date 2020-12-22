package com.applicaster.analytics.segment

import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.util.APLogger
import com.segment.analytics.Analytics
import com.segment.analytics.Properties
import java.text.SimpleDateFormat
import java.util.*

class SegmentAgent : BaseAnalyticsAgent() {

    private var analytics: Analytics? = null
    private var writeKey: String = ""

    override fun initializeAnalyticsAgent(context: android.content.Context?) {
        super.initializeAnalyticsAgent(context)
        if (analytics != null) return
        analytics = Analytics.Builder(
                context,
                writeKey).trackApplicationLifecycleEvents() // Enable this to record certain application events automatically!
                         .recordScreenViews() // Enable this to record screen views automatically!
                         .build()
        Analytics.setSingletonInstance(analytics)
    }

    override fun setParams(params: MutableMap<Any?, Any?>) {
        super.setParams(params)
        writeKey = params.getOrElse("write_key", {""}).toString()
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

    companion object {
        private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.UK)
        private const val TAG = "SegmentAgent"
    }
}