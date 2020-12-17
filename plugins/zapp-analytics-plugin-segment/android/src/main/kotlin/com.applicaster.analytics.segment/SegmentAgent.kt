package com.applicaster.analytics.segment

import android.util.Log
import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.identityservice.UUIDUtil
import com.segment.analytics.Analytics
import com.segment.analytics.Properties
import java.text.SimpleDateFormat
import java.util.*

class SegmentAgent : BaseAnalyticsAgent() {

    val TAG = "SegmentAgent"

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.UK)
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
        Log.d(TAG, "eventName $eventName")
        params?.remove("Platform") // Remove param added by the SDK, the OC player is adding it instead
        eventName?.apply {
            val properties = Properties().putMap(params)
                    .putValue("name", eventName)
                    .putValue("timestamp", dateFormat.format(Date()))
                    .putValue("applicaster_device_id", analytics?.analyticsContext?.traits()?.anonymousId())
            analytics?.track(this, properties)
        }
    }

    private fun Properties.putMap(params: Map<String, String>?): Properties {
        params?.apply {
            for ((key, value) in this) {
                put(key, value)
            }
        }
        return this
    }
}