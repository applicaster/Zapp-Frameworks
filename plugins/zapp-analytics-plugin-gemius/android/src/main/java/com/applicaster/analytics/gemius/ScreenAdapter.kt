package com.applicaster.analytics.gemius

import com.applicaster.analytics.adapters.AnalyticsScreenAdapter
import com.applicaster.util.AppContext
import com.gemius.sdk.audience.AudienceEvent
import com.gemius.sdk.audience.BaseEvent
import java.util.*

class ScreenAdapter(private val scriptId: String) : AnalyticsScreenAdapter() {

    override fun onOpenWebpage(url: String, params: TreeMap<String, String>?) {
        super.onOpenWebpage(url, params)
        AudienceEvent(AppContext.get()).apply {
            eventType = BaseEvent.EventType.FULL_PAGEVIEW
            scriptIdentifier = scriptId // not really needed, must be taken from global config
            addExtraParameter("url", url)
            sendEvent()
        }
    }

    override fun onOpenScreen(screenName: String, params: TreeMap<String, String>?) {
        super.onOpenScreen(screenName, params)
        AudienceEvent(AppContext.get()).apply {
            eventType = BaseEvent.EventType.FULL_PAGEVIEW
            scriptIdentifier = scriptId
            addExtraParameter("Screen", screenName)
            sendEvent()
        }
    }

    override fun onOpenHome(eventName: String, params: TreeMap<String, String>?) {
        super.onOpenHome(eventName, params)
        AudienceEvent(AppContext.get()).apply {
            eventType = BaseEvent.EventType.FULL_PAGEVIEW
            scriptIdentifier = scriptId
            addExtraParameter("Screen", "Home")
            sendEvent()
        }
    }

    override fun onBackNav(eventName: String, params: TreeMap<String, String>?) {
        super.onBackNav(eventName, params)
        AudienceEvent(AppContext.get()).apply {
            eventType = BaseEvent.EventType.ACTION
            scriptIdentifier = scriptId
            addExtraParameter("Type", BACK_NAV)
            params?.get(BACK_NAV_KEY_SOURCE)?.let {
                addExtraParameter("Source", it)
            }
            sendEvent()
        }
    }
}