package com.applicaster.analytics.segment

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.segment.analytics.Analytics
import com.segment.analytics.Traits
import javax.annotation.Nonnull
import javax.annotation.Nullable

class SegmentAPI(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    val TAG = "SegmentAPI"

    override fun getName(): String {
        return TAG
    }

    // Make sure to not call this method before the application initialization
    @ReactMethod
    fun identifyUser(userId: String,
                 traits: ReadableMap,
                 options: ReadableMap) {

        val analytics = Analytics.with(reactApplicationContext)
        val newTraits = Traits()
        val newOptions = analytics.defaultOptions
/*
        // Add context traits
        for (trait in analytics.analyticsContext.traits()) {
            newTraits.putValue(trait.key, trait.value)
        }
*/
        // Add additional traits
        for (entry in traits.toHashMap()) {
            newTraits.putValue(entry.key, entry.value)
        }

        // Add new options
        newOptions?.context()?.putAll(options.toHashMap())

        analytics.identify(userId, newTraits, newOptions)
    }
}