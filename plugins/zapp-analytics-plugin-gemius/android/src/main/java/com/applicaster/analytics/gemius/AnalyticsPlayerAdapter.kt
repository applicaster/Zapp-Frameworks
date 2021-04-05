package com.applicaster.analytics.gemius

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

    open fun onStart(data: Map<String, Any>?) {
        cleanData()
        this.data = data
        isStarted = true
    }

    open fun onStop(data: Map<String, Any>?) {

    }

    open fun onPlay(data: Map<String, Any>?) {

    }

    open fun onPause(data: Map<String, Any>?) {

    }

    open fun onAdBreakStart(data: Map<String, Any>?) {

    }

    open fun onAdBreakEnd(data: Map<String, Any>?) {

    }

    open fun onAdStart(data: Map<String, Any>?) {

    }

    open fun onAdEnd(data: Map<String, Any>?) {

    }

    open fun onSeek(data: Map<String, Any>?) {

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

    fun getName() : String? = data?.get("Item Name") as String?

    fun getLink() : String? = data?.get("Item Link") as String?

    fun getId() : String = data?.get("Item ID") as String? ?: ""

    fun getType() : String? = data?.get("Item Type") as String?

    companion object {
        const val PLAY_EVENT = "VOD Item: Play Was Triggered"

        const val AD_BREAK_START_EVENT = "Ad Break Begin"
        const val AD_BREAK_END_EVENT = "Ad Break End"
        const val AD_START_EVENT = "Ad Begin"
        const val AD_END_EVENT = "Ad End"

        const val PLAY_TIMED_EVENT = "Play VOD Item"
    }
}
