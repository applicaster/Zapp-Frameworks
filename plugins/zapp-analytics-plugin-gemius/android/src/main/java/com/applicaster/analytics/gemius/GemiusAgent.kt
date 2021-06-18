package com.applicaster.analytics.gemius

import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.analytics.adapters.IAnalyticsAdapter
import com.applicaster.util.APDebugUtil
import com.applicaster.util.APLogger
import com.applicaster.util.OSUtil
import com.gemius.sdk.Config
import com.gemius.sdk.audience.AudienceConfig
import java.util.*


class GemiusAgent : BaseAnalyticsAgent() {

    private var scriptIdentifier: String = ""

    private var serverHost = "https://main.hit.gemius.pl"

    private var adapters: MutableList<IAnalyticsAdapter> = mutableListOf()

    override fun initializeAnalyticsAgent(context: android.content.Context?) {
        super.initializeAnalyticsAgent(context)

        if (scriptIdentifier.isEmpty()) {
            APLogger.error(TAG, "scriptIdentifier is empty. Analytics agent won't be activated")
            return
        }

        synchronized(adapters) {
            adapters.clear()
            adapters.add(PlayerAdapter(playerID, serverHost, scriptIdentifier))
            adapters.add(ScreenAdapter())

        }

        Config.setLoggingEnabled(APDebugUtil.getIsInDebugMode())
        Config.setAppInfo(OSUtil.getPackageName(), OSUtil.getZappAppVersion())

        //global config for Audience/Prism hits
        AudienceConfig.getSingleton().hitCollectorHost = serverHost
        AudienceConfig.getSingleton().scriptIdentifier = scriptIdentifier
    }

    override fun setParams(params: MutableMap<Any?, Any?>) {
        super.setParams(params)
        scriptIdentifier = params["script_identifier"]?.toString() ?: ""
        if (scriptIdentifier.isEmpty()) {
            APLogger.error(TAG, "script_identifier is empty. Analytics agent won't be activated")
        }

        params["hit_collector_host"]?.toString().let {
            when {
                !it.isNullOrEmpty() -> serverHost = it
                else -> APLogger.info(TAG, "hit_collector_host is empty, default host will $serverHost be used")
            }
        }
    }

    override fun logEvent(eventName: String?) {
        super.logEvent(eventName)
        logEvent(eventName, null)
    }

    override fun startTimedEvent(eventName: String?) {
        super.startTimedEvent(eventName)
        startTimedEvent(eventName, null)
    }

    override fun endTimedEvent(eventName: String?) {
        super.endTimedEvent(eventName)
        endTimedEvent(eventName, TreeMap())
    }

    override fun startTimedEvent(eventName: String?, params: TreeMap<String, String>?) {
        super.startTimedEvent(eventName, params)
        if(null == eventName) {
            return
        }
        synchronized(adapters) {
            if(adapters.any { it.routeTimedEventStart(eventName, params) }) {
                return
            }
        }
    }

    override fun endTimedEvent(eventName: String?, params: TreeMap<String, String>) {
        super.endTimedEvent(eventName, params)
        if(null == eventName) {
            return
        }
        synchronized(adapters) {
            if(adapters.any { it.routeTimedEventEnd(eventName, params) }) {
                return
            }
        }
    }

    override fun logEvent(eventName: String?, params: TreeMap<String, String>?) {
        super.logEvent(eventName, params)
        if(null == eventName) {
            return
        }
        synchronized(adapters) {
            if(adapters.any { it.routeEvent(eventName, params) }) {
                return
            }
        }
        // todo: handle or forward any other event types if needed
    }

    companion object {
        const val TAG = "GemiusAgent"
        private const val playerID = "DefaultPlayer" // todo: maybe check for, say, inline player, theo?
    }
}