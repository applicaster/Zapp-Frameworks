package com.theoplayerreactnative.events

import com.facebook.react.bridge.Arguments.createMap
import com.facebook.react.bridge.WritableMap
import com.theoplayer.android.api.event.ads.*

object AdEventsBinder {

    @JvmStatic
    fun toRN(event: AdBreakBeginEvent): WritableMap = createMap().apply {
        putInt("timeOffset", event.adBreak.timeOffset)
    }

    @JvmStatic
    fun toRN(event: AdBreakEndEvent): WritableMap = createMap().apply {
        putInt("timeOffset", event.adBreak.timeOffset)
    }

    @JvmStatic
    fun toRN(event: AdBeginEvent): WritableMap = createMap().apply {
        event.ad?.let { putString("id", it.id) }
    }

    @JvmStatic
    fun toRN(event: AdEndEvent): WritableMap = createMap().apply {
        event.ad?.let { putString("id", it.id) }
    }

    @JvmStatic
    fun toRN(event: AdErrorEvent): WritableMap = createMap().apply {
        event.ad?.let { putString("id", it.id) }
        putString("error", event.error)
    }
}
