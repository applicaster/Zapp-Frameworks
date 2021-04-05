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
    open fun onStart(data: Map<String, Any>?) {
        cleanData()
        this.data = data
        duration = parseDuration()
        isStarted = true
    }

    @CallSuper
    open fun onStop(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onPlay(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onPause(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onAdBreakStart(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onAdBreakEnd(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onAdStart(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onAdEnd(data: Map<String, Any>?) {
        updatePosition()
    }

    @CallSuper
    open fun onSeek(data: Map<String, Any>?) {
        updatePosition()
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
            PLAY_EVENT -> onPlay(params)
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
            is String -> length.toLong()
            is Number -> length as Long
            else -> null
        }
    }

    private fun updatePosition()  {
        when(val length = data?.get(KEY_POSITION)){
            is String -> position = length.toLong()
            is Number -> position = length as Long
            else -> {}
        }
    }

    companion object {
        const val PLAY_EVENT = "VOD Item: Play Was Triggered"

        const val AD_BREAK_START_EVENT = "Ad Break Begin"
        const val AD_BREAK_END_EVENT = "Ad Break End"
        const val AD_START_EVENT = "Ad Begin"
        const val AD_END_EVENT = "Ad End"

        const val PLAY_TIMED_EVENT = "Play VOD Item"

        const val KEY_ID = "Item ID"
        const val KEY_NAME = "Item Name"
        const val KEY_LINK = "Item Link"
        const val KEY_TYPE = "Item Type"

        const val KEY_DURATION = "Custom Propertyduration" // must me Item Length
        const val KEY_CUSTOM_PROPERTIES = "Custom PropertyanalyticsCustomProperties"
        const val KEY_POSITION = "currentTime"
    }
}
