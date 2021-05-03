package com.applicaster.analytics.gemius

import androidx.annotation.CallSuper
import java.util.*

open class AnalyticsPlayerAdapter {

    var data: Map<String, Any>? = null
    var duration: Long? = null
    var position: Long? = null
    var isStarted: Boolean = false

    private fun cleanData() {
        data = null
        duration = null
        position = null
    }

    @CallSuper
    open fun onStart(params: Map<String, Any>?) {
        cleanData()
        data = params
        duration = parseDuration()
        isStarted = true
    }

    @CallSuper
    open fun onLoaded(params: Map<String, Any>?) {
        updatePosition(params)
        duration = parseDuration()
    }

    @CallSuper
    open fun onStop(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onPlay(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onPause(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onAdBreakStart(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onAdBreakEnd(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onAdStart(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onAdEnd(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onSeek(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onSeekEnd(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onBuffering(params: Map<String, Any>?) {
        updatePosition(params)
    }

    @CallSuper
    open fun onComplete(params: Map<String, Any>?) {
        updatePosition(params)
    }

    fun routeTimedEventStart(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            // ...add events there and return true
            else -> return false
        }
        return true
    }

    fun routeTimedEventEnd(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            // ...add events there and return true
            else -> return false
        }
        return true
    }

    fun routeEvent(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            PLAYER_CREATED_EVENT -> onStart(params)
            PLAYER_CLOSED_EVENT -> onStop(params)

            ENTRY_LOADED_EVENT -> onLoaded(params)

            PLAYER_PLAYING_EVENT -> onPlay(params)
            PLAYER_PAUSE_EVENT -> onPause(params)
            PLAYER_SEEK_EVENT -> onSeek(params)
            PLAYER_SEEK_EVENT_END -> onSeekEnd(params)
            PLAYER_BUFFERING_EVENT -> onBuffering(params)

            PLAYER_COMPETE_EVENT -> onComplete(params)

            AD_START_EVENT -> onAdStart(params)
            AD_END_EVENT -> onAdEnd(params)
            AD_BREAK_START_EVENT -> onAdBreakStart(params)
            AD_BREAK_END_EVENT -> onAdBreakEnd(params)
            else -> return false
        }
        return true;
    }

    fun getName() : String? = data?.get(KEY_NAME) as String?

    fun getLink() : String? = data?.get(KEY_LINK) as String?

    fun getId() : String = data?.get(KEY_ID) as String? ?: ""

    fun getType() : String? = data?.get(KEY_TYPE) as String?

    private fun parseDuration() : Long? {
        return when(val length = data?.get(KEY_DURATION)){
            null -> null
            is String -> length.toDouble().toLong() // can contain .
            is Number -> length as Long
            else -> null
        }
    }

    private fun updatePosition(params: Map<String, Any>?)  {
        when(val pos = params?.get(KEY_POSITION)){
            is String -> position = pos.toDouble().toLong() // can contain .
            is Number -> position = pos as Long
            else -> {}
        }
    }

    companion object {

        // Player was created with some entry to play.
        // We have to create new program here, even though we don't have some data like real duration.
        const val PLAYER_CREATED_EVENT = "Player Created"

        // Player closed (destroyed)
        const val PLAYER_CLOSED_EVENT = "Player Closed"

        // User initiated play action
        const val PLAYER_PLAYING_EVENT = "Player Playing"

        // User initiated pause action
        const val PLAYER_PAUSE_EVENT = "Player Pause"

        // Buffering caused by stream interruption (no data), not seek, ad, or start
        const val PLAYER_BUFFERING_EVENT = "Player Buffering"

        // Player has opened entry url (does not loads anything yet, we can go into preroll instead of main bideo after that)
        const val ENTRY_LOADED_EVENT = "Media Entry Load"

        // Main video loaded (after preroll, if any). Only here we have real duration.
        // Not used right now due to bug in Gemius: we can't report ads if there is no Program
        // despite what docs says (they say we can), therefore all programs will report wrong duration
        const val PLAYER_LOADED_EVENT = "Player Loaded Video"

        // Seek in progress, reported each time user moves the position,
        const val PLAYER_SEEK_EVENT = "Player Seek"
        // Seek has competed and playback resumed
        const val PLAYER_SEEK_EVENT_END = "Player Seek End"

        // Reached the end of the video
        const val PLAYER_COMPETE_EVENT = "Player Ended"

        const val AD_BREAK_START_EVENT = "Ad Break Begin"
        const val AD_BREAK_END_EVENT = "Ad Break End"
        const val AD_START_EVENT = "Ad Begin"
        const val AD_END_EVENT = "Ad End"

        const val KEY_ID = "Item ID"
        const val KEY_NAME = "Item Name"
        const val KEY_LINK = "Item Link"
        const val KEY_TYPE = "Item Type"

        const val KEY_AD_ID = "Ad Id"
        const val KEY_AD_DURATION = "Ad Duration" // Single ad duration
        const val KEY_AD_POSITION = "Ad Position" // Ad index in slot: 0, 1, 2 etc
        const val KEY_AD_BREAK_OFFSET = "Ad Break Time Offset" // Ad break position in timeline
        const val KEY_AD_BREAK_SIZE = "Ad Break Size" // Ads count in the break: 1, 2, 3, etc
        const val KEY_AD_BREAK_MAX_DURATION = "Ad Break Max Duration" // Total ad break max duration

        const val KEY_DURATION = "Item Length"
        const val KEY_POSITION = "offset" // must be Position or something like that
        const val KEY_CUSTOM_PROPERTIES = "analyticsCustomProperties"
    }
}
