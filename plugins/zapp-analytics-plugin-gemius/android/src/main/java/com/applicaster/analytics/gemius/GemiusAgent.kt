package com.applicaster.analytics.gemius

import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.util.APLogger
import com.applicaster.util.OSUtil
import com.gemius.sdk.Config
import com.gemius.sdk.audience.AudienceConfig
import com.gemius.sdk.stream.*
import java.util.*


class GemiusAgent : BaseAnalyticsAgent() {

    private var testIdentifier: String = ""

    inner class PlayerAdapter : AnalyticsPlayerAdapter() {

        private val player: Player = Player(playerID, serverHost, testIdentifier, PlayerData())

        override fun onStart(data: Map<String, Any>?) {
            super.onStart(data)
            // todo: copy all required fields
            val pdata = ProgramData().apply {
                name = this@PlayerAdapter.getName()
                duration = duration?.toInt()
                data?.forEach { addCustomParameter(it.key, it.value.toString()) }
            }
            player.newProgram(getId(), pdata)
        }

        override fun onPlay(data: Map<String, Any>?) {
            super.onPlay(data)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PLAY,
                    EventProgramData())
        }

        override fun onStop(data: Map<String, Any>?) {
            super.onStop(data)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.CLOSE,
                    EventProgramData())
        }

        override fun onPause(data: Map<String, Any>?) {
            super.onPause(data)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PAUSE,
                    EventProgramData())
        }

        override fun onAdBreakStart(data: Map<String, Any>?) {
            super.onAdBreakStart(data)
            // not reported
        }

        override fun onAdBreakEnd(data: Map<String, Any>?) {
            super.onAdBreakEnd(data)
            // not reported
        }

        override fun onAdStart(data: Map<String, Any>?) {
            super.onAdStart(data)
            // todo: id, other data
            val adata = AdData().apply {
                //duration = 15
                adType = AdData.AdType.BREAK
            }
            player.newAd("a1", adata)
        }

        override fun onAdEnd(data: Map<String, Any>?) {
            super.onAdEnd(data)
            // not reported
        }

        override fun onSeek(data: Map<String, Any>?) {
            super.onSeek(data)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.SEEK,
                    EventProgramData())
        }
    }

    private val player: PlayerAdapter? = null

    override fun initializeAnalyticsAgent(context: android.content.Context?) {
        super.initializeAnalyticsAgent(context)

        if (testIdentifier.isEmpty()) {
            APLogger.error(TAG, "testIdentifier is empty. Analytics agent won't be activated")
            return
        }

        Config.setLoggingEnabled(true)
        Config.setAppInfo(OSUtil.getPackageName(), OSUtil.getZappAppVersion())

        //global config for Audience/Prism hits
        AudienceConfig.getSingleton().hitCollectorHost = serverHost
        AudienceConfig.getSingleton().scriptIdentifier = testIdentifier
    }

    override fun setParams(params: MutableMap<Any?, Any?>) {
        super.setParams(params)
        testIdentifier = params["testIdentifier"]?.toString() ?: ""
        if (testIdentifier.isEmpty()) {
            APLogger.error(TAG, "testIdentifier is empty. Analytics agent won't be activated")
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
        if(true == player?.routeTimedEventStart(eventName, params))
            return
    }

    override fun endTimedEvent(eventName: String?, params: TreeMap<String, String>) {
        super.endTimedEvent(eventName, params)
        if(null == eventName) {
            return
        }
        if(true == player?.routeTimedEventEnd(eventName, params))
            return
    }

    override fun logEvent(eventName: String?, params: TreeMap<String, String>?) {
        super.logEvent(eventName, params)
        if(null == eventName) {
            return
        }
        if(true == player?.routeEvent(eventName, params))
            return
        // todo: handle or forward any other event types if needed
    }

    companion object {
        private const val TAG = "GemiusAgent"
        private const val serverHost = "https://main.hit.gemius.pl"
        private const val playerID = "DefaultPlayer" // todo: maybe check for, say, inline player, theo?
    }
}