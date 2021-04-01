package com.applicaster.analytics.gemius

import java.util.*

open class AnalyticsPlayerAdapter {

    var data: Map<String, Any>? = null
    var duration: Long? = null
    var position: Long? = null

    private fun cleanData() {
        data = null
        duration = null
        position = null
    }

    open fun onStart(data: Map<String, Any>?) {
        cleanData()
        this.data = data
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
        const val PLAY_TIMED_EVENT = "Play VOD Item"
    }
}
