package com.theoplayerreactnative.events

import com.applicaster.util.APLogger
import com.facebook.react.bridge.Arguments.createMap
import com.facebook.react.bridge.WritableMap
import com.theoplayer.android.api.event.player.*
import com.theoplayerreactnative.TheoPlayerViewManager

object PlayerEventMapper {

    @JvmStatic
    fun toRN(event: PlayEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: PauseEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: SeekedEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: RateChangeEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
        putDouble("playbackRate", event.playbackRate)
    }

    @JvmStatic
    fun toRN(event: VolumeChangeEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
        putDouble("volume", event.volume)
    }

    @JvmStatic
    fun toRN(event: ProgressEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: DurationChangeEvent): WritableMap = createMap().apply {
        putDouble("duration", fixNan(event.duration))
    }

    @JvmStatic
    fun toRN(event: SourceChangeEvent): WritableMap = createMap()

    @JvmStatic
    fun toRN(event: ReadyStateChangeEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
        putString("readyState", event.readyState.name)
    }

    @JvmStatic
    fun toRN(event: TimeUpdateEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
        putInt("currentProgramDateTime", event.currentProgramDateTime?.time?.toInt() ?: 0)
    }

    @JvmStatic
    fun toRN(event: WaitingEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixTime(event.currentTime)) // bug in THEO: should be number
    }

    @JvmStatic
    fun toRN(event: PlayingEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: EndedEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: LoadedMetadataEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: LoadedDataEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixTime(event.currentTime)) // bug in THEO: should be number
    }

    @JvmStatic
    fun toRN(event: CanPlayEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: CanPlayThroughEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: SegmentNotFoundEvent): WritableMap = createMap().apply {
        putDouble("segmentStartTime", event.segmentStartTime)
        putString("error", event.error)
        putInt("retryCount", event.retryCount)
    }

    @JvmStatic
    fun toRN(event: ErrorEvent): WritableMap = createMap().apply {
        APLogger.error(TAG, "ErrorEvent:" + event.errorObject.message)
        putString("error", event.errorObject.message)
    }

    @JvmStatic
    fun toRN(event: MediaEncryptedEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
        putString("initData", event.initData)
        putString("initDataType", event.initDataType)
    }

    @JvmStatic
    fun toRN(event: ContentProtectionErrorEvent): WritableMap = createMap().apply {
        // can explode the object if needed
        APLogger.error(TAG, "ContentProtectionErrorEvent:" + event.errorObject.toString())
        putString("error", event.errorObject.toString())
    }

    @JvmStatic
    fun toRN(event: ContentProtectionSuccessEvent): WritableMap = createMap().apply {
        putString("mediaTrackType", event.mediaTrackType)
    }

    @JvmStatic
    fun toRN(event: NoSupportedRepresentationFoundEvent): WritableMap = createMap()

    @JvmStatic
    fun toRN(event: SeekingEvent): WritableMap = createMap().apply {
        putDouble("currentTime", fixNan(event.currentTime))
    }

    @JvmStatic
    fun toRN(event: PresentationModeChange): WritableMap = createMap()

    @JvmStatic
    fun toRN(event: DestroyEvent): WritableMap = createMap()

    @JvmStatic
    fun toRN(event: LoadStartEvent): WritableMap = createMap()

    // sometimes Theo sends NaN during Ads
    private fun fixNan(time: Double): Double = if(time.isFinite()) time else 0.0

    private fun fixTime(currentTime: String): Double = currentTime.toDoubleOrNull() ?: 0.0

    private const val TAG = TheoPlayerViewManager.TAG + ".PlayerEventMapper"
}
