package com.theoplayerreactnative.events

import com.facebook.react.bridge.Arguments.createMap
import com.facebook.react.bridge.WritableMap
import com.theoplayer.android.api.ads.*
import com.theoplayer.android.api.event.ads.*

object AdEventMapper {

    @JvmStatic
    fun toRN(event: AdBreakBeginEvent): WritableMap = createMap().apply {
        collectAdBreakInfo(this, event.adBreak)
    }

    @JvmStatic
    fun toRN(event: AdBreakEndEvent): WritableMap = createMap().apply {
        collectAdBreakInfo(this, event.adBreak)
    }

    private fun collectAdBreakInfo(map: WritableMap, adBreak: AdBreak) {
        map.putInt("timeOffset", adBreak.timeOffset)
        map.putInt("maxDuration", adBreak.maxDuration)
        map.putDouble("maxRemainingDuration", adBreak.maxRemainingDuration)
        map.putString("integrationKind", adBreak.integration.type)
        map.putInt("breakSize", adBreak.ads.size)
    }

    @JvmStatic
    fun toRN(event: AdBeginEvent): WritableMap = createMap().apply {
        collectAdInfo(this, event.ad)
    }

    @JvmStatic
    fun toRN(event: AdEndEvent): WritableMap = createMap().apply {
        collectAdInfo(this, event.ad)
    }

    @JvmStatic
    fun toRN(event: AdErrorEvent): WritableMap = createMap().apply {
        collectAdInfo(this, event.ad)
        putString("error", event.error)
    }

    private fun collectAdInfo(map: WritableMap, ad: Ad?) {
        if(null == ad)
            return
        map.putString("id", ad.id)
        map.putString("type", ad.type)
        (ad as? LinearAd?)?.let {
            map.putInt("duration", it.duration)
        }
        (ad as? GoogleImaAd?)?.let {
            map.putString("creativeId", it.creativeId)
            map.putString("adSystem", it.adSystem)
        }
        (ad as? NonLinearAd?)?.let {
            map.putString("resourceURI", it.resourceURI)
        }
        ad.adBreak?.let {
            map.putInt("breakSize", it.ads.size)
            map.putInt("adPosition", it.ads.indexOf(ad))
        }
    }

}
