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

    fun routeTimedEventStart(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            PLAY_TIMED_EVENT -> onStart(params)
            else -> return false
        }
        return true;
    }

    fun routeTimedEventEnd(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            PLAY_TIMED_EVENT -> onStop(params)
            else -> return false
        }
        return true;
    }

    fun routeEvent(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            PLAYER_PLAYING_EVENT -> onPlay(params)
            PLAYER_PAUSE_EVENT -> onPause(params)
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
        // not used, it comes with PLAY_TIMED_EVENT
        const val PLAY_EVENT = "VOD Item: Play Was Triggered"

        const val PLAYER_PLAYING_EVENT = "Player Playing"
        const val PLAYER_PAUSE_EVENT = "Player Pause"

        const val AD_BREAK_START_EVENT = "Ad Break Begin"
        const val AD_BREAK_END_EVENT = "Ad Break End"
        const val AD_START_EVENT = "Ad Begin"
        const val AD_END_EVENT = "Ad End"

        const val PLAY_TIMED_EVENT = "Play VOD Item"

        const val KEY_ID = "Item ID"
        const val KEY_NAME = "Item Name"
        const val KEY_LINK = "Item Link"
        const val KEY_TYPE = "Item Type"

        const val KEY_DURATION = "Custom Propertyduration" // must me 'Item Length'
        const val KEY_CUSTOM_PROPERTIES = "Custom PropertyanalyticsCustomProperties"
        const val KEY_POSITION = "currentTime" // must be Position or something like that
    }
}
