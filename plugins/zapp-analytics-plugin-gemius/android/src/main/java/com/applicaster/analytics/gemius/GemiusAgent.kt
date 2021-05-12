package com.applicaster.analytics.gemius

import androidx.annotation.CallSuper
import com.applicaster.analytics.BaseAnalyticsAgent
import com.applicaster.util.APDebugUtil
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.OSUtil
import com.gemius.sdk.Config
import com.gemius.sdk.audience.AudienceConfig
import com.gemius.sdk.stream.*
import org.json.JSONException
import org.json.JSONObject
import java.util.*


class GemiusAgent : BaseAnalyticsAgent() {

    private var scriptIdentifier: String = ""
    private var serverHost = "https://main.hit.gemius.pl"

    inner class PlayerAdapter : AnalyticsPlayerAdapter() {

        private val player: Player = Player(playerID, serverHost, scriptIdentifier, PlayerData())

        init{
            player.setContext(AppContext.get())
        }

        override fun onStart(params: Map<String, Any>?) {
            super.onStart(params)
            val pdata = ProgramData()
            pdata.name = getName()
            pdata.duration = duration?.toInt()
            // todo: need to determine type
            pdata.programType = ProgramData.ProgramType.VIDEO

            val id = getId()

            // copy all custom fields
            (params?.get(KEY_CUSTOM_PROPERTIES) as? String)?.let {
                // Custom PropertyanalyticsCustomProperties -> {
                // "_SC":"a721efad-b903-4bea-a86f-3877a0fbe423",
                // "_SCD":3146,
                // "_SCT":"Vermist - S3 - Aflevering 21",
                // "_ST":"vid.tvi.ep.vod.free",
                // "channel":"Play5",
                // "ct":"ce/tv",
                // "se":"Vermist",
                // "tv":"10126594220817528",
                // "video_type":"long_form",
                // "video_subtype":"long",
                // "URL_alias":"/video/vermist/seizoen-3/vermist-s3-aflevering-21"}
                try {
                    val jsonObject = JSONObject(it)
                    for (k in jsonObject.keys()) {
                        if(!whitelistedKeys.contains(k))
                            continue
                        if("_SC" == k) {
                            val sc = jsonObject.get(k).toString()
                            if(id != sc) {
                                APLogger.warn(TAG, "Content ID in the feed and analytics extension do not match: $id vs $sc")
                            }
                            continue
                        }
                        if("_SCT" == k) {
                            // use content title provided by the feed extension
                            pdata.name = jsonObject.get(k).toString()
                            continue
                        }
                        if("_SCD" == k) {
                            // use duration provided by the feed extension
                            pdata.duration = jsonObject.getInt(k)
                            continue
                        }
                        val value = jsonObject.get(k).toString()
                        pdata.addCustomParameter(k, value)
                    }
                } catch (e: JSONException) {
                    APLogger.error(TAG, "Failed to deserialize custom properties block", e)
                }
            }
            player.newProgram(getId(), pdata)
        }

        override fun onPlay(params: Map<String, Any>?) {
            super.onPlay(params)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PLAY,
                    EventProgramData())
        }

        override fun onStop(params: Map<String, Any>?) {
            super.onStop(params)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.CLOSE, // stop is close for us
                    EventProgramData())
        }

        override fun onPause(params: Map<String, Any>?) {
            super.onPause(params)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PAUSE,
                    EventProgramData())
        }

        override fun onResume(params: TreeMap<String, Any>?) {
            super.onResume(params)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PLAY,
                    EventProgramData())
        }

        override fun onBuffering(params: Map<String, Any>?) {
            super.onBuffering(params)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.BUFFER,
                    EventProgramData())
        }

        override fun onAdBreakStart(params: Map<String, Any>?) {
            super.onAdBreakStart(params)
            player.programEvent(getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.BREAK,
                    EventProgramData())
        }

        override fun onAdBreakEnd(params: Map<String, Any>?) {
            super.onAdBreakEnd(params)
            // not reported
        }

        override fun onAdStart(params: Map<String, Any>?) {
            super.onAdStart(params)
            // todo: other data if needed
            val id = params?.get(KEY_AD_ID)?.toString() ?: ""
            if(id.isEmpty())
                APLogger.warn(TAG, "$KEY_AD_ID is missing in the event $AD_START_EVENT data")
            val adata = AdData().apply {
                adType = AdData.AdType.BREAK
                when (val d = params?.get(KEY_AD_DURATION)) {
                    is String -> duration = d.toFloat().toInt()
                    is Number -> duration = d.toInt()
                    else -> APLogger.warn(TAG, "$KEY_AD_DURATION is missing in the event $AD_START_EVENT data")
                }
            }
            player.newAd(id, adata)
            player.adEvent(
                    getId(),
                    id, position?.toInt(),
                    Player.EventType.PLAY,
                    EventAdData().apply {
                        autoPlay = true // all our ads are autoplay I assume
                        when (val d = params?.get(KEY_AD_BREAK_SIZE)) {
                            is String -> breakSize = d.toFloat().toInt()
                            is Number -> breakSize = d.toInt()
                            else -> APLogger.warn(TAG, "$KEY_AD_BREAK_SIZE is missing in the event $AD_START_EVENT data")
                        }
                    })
        }

        override fun onAdEnd(params: Map<String, Any>?) {
            super.onAdEnd(params)
            val id = params?.get(KEY_AD_ID)?.toString() ?: ""
            if(id.isEmpty())
                APLogger.warn(TAG, "$KEY_AD_ID is missing in the event $AD_END_EVENT data")
            player.adEvent(
                    getId(),
                    id,
                    position?.toInt(),
                    Player.EventType.COMPLETE,
                    null)
        }

        override fun onSeek(params: Map<String, Any>?) {
            super.onSeek(params)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.SEEK,
                    EventProgramData())
        }

        override fun onSeekEnd(params: Map<String, Any>?) {
            // Gemius requires Play event after seek
            super.onSeekEnd(params)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.PLAY,
                    EventProgramData())
        }

        override fun onComplete(params: Map<String, Any>?) {
            super.onComplete(params)
            player.programEvent(
                    getId(),
                    position?.toInt() ?: 0,
                    Player.EventType.COMPLETE,
                    EventProgramData())
        }
    }

    private var player: PlayerAdapter? = null

    override fun initializeAnalyticsAgent(context: android.content.Context?) {
        super.initializeAnalyticsAgent(context)

        if (scriptIdentifier.isEmpty()) {
            APLogger.error(TAG, "scriptIdentifier is empty. Analytics agent won't be activated")
            return
        }

        player = PlayerAdapter()

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
        private const val playerID = "DefaultPlayer" // todo: maybe check for, say, inline player, theo?

        private val whitelistedKeys = setOf(
                "_SC",
                "_SCT",
                "_EC",
                "_SP",
                "_SCD",
                "channel",
                "ct",
                "_SPI",
                "_SCTE",
                "st",
                "_ST",
                "tv",
                "se",
                "URL_alias")
    }
}