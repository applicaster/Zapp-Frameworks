package com.applicaster.analytics.gemius

import com.applicaster.analytics.adapters.AnalyticsPlayerAdapter
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.gemius.sdk.stream.*
import org.json.JSONException
import org.json.JSONObject

class PlayerAdapter(playerID: String,
                    hitCollectorHost: String,
                    gemiusID: String) : AnalyticsPlayerAdapter() {

    private val player: Player = Player(playerID, hitCollectorHost, gemiusID, PlayerData())
    private var idOverride: String? = null

    init {
        player.setContext(AppContext.get())
    }

    override fun getId(): String = idOverride ?: super.getId()

    override fun onStart(params: Map<String, Any>?) {
        super.onStart(params)

        idOverride = null

        val pdata = ProgramData()
        pdata.name = getName()
        pdata.duration = duration?.toInt()
        // todo: need to determine type
        pdata.programType = ProgramData.ProgramType.VIDEO

        var id = super.getId()

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
                    if (!whitelistedKeys.contains(k))
                        continue
                    if ("_SC" == k) {
                        val sc = jsonObject.get(k).toString()
                        if (id != sc) {
                            APLogger.warn(GemiusAgent.TAG, "Content ID in the feed and analytics extension do not match: $id vs $sc, it will be overridden")
                            id = sc
                            idOverride = sc
                        }
                        continue
                    }
                    if ("_SCT" == k) {
                        // use content title provided by the feed extension
                        pdata.name = jsonObject.get(k).toString()
                        continue
                    }
                    if ("_SCD" == k) {
                        // use duration provided by the feed extension
                        pdata.duration = jsonObject.getInt(k)
                        continue
                    }
                    val value = jsonObject.get(k).toString()
                    pdata.addCustomParameter(k, value)
                }
            } catch (e: JSONException) {
                APLogger.error(GemiusAgent.TAG, "Failed to deserialize custom properties block", e)
            }
        }
        player.newProgram(id, pdata)
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

    override fun onResume(params: Map<String, Any>?) {
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
        if (id.isEmpty())
            APLogger.warn(GemiusAgent.TAG, "$KEY_AD_ID is missing in the event $AD_START_EVENT data")
        val adata = AdData().apply {
            adType = AdData.AdType.BREAK
            when (val d = params?.get(KEY_AD_DURATION)) {
                is String -> duration = d.toFloat().toInt()
                is Number -> duration = d.toInt()
                else -> APLogger.warn(GemiusAgent.TAG, "$KEY_AD_DURATION is missing in the event $AD_START_EVENT data")
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
                        else -> APLogger.warn(GemiusAgent.TAG, "$KEY_AD_BREAK_SIZE is missing in the event $AD_START_EVENT data")
                    }
                })
    }

    override fun onAdEnd(params: Map<String, Any>?) {
        super.onAdEnd(params)
        val id = params?.get(KEY_AD_ID)?.toString() ?: ""
        if (id.isEmpty())
            APLogger.warn(GemiusAgent.TAG, "$KEY_AD_ID is missing in the event $AD_END_EVENT data")
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

    companion object {
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