package com.applicaster.analytics.segment

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap

class SegmentAPI(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = TAG

    // Make sure to not call this method before the application initialization
    @ReactMethod
    fun identifyUser(userId: String,
                     traits: ReadableMap,
                     options: ReadableMap) {
        val plugin = SegmentAgent.instance()
        plugin?.setUserIdentify(SegmentAgent.Identity(userId, traits.toHashMap(), options.toHashMap()))
    }

    companion object {
        private const val TAG = "SegmentAPI"
    }
}