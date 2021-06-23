package com.applicaster.analytics.adapters

import java.util.*

interface IAnalyticsAdapter {
    // todo: we probably don't want nullable eventName
    fun routeTimedEventStart(eventName: String?, params: TreeMap<String, String>?) : Boolean
    fun routeTimedEventEnd(eventName: String?, params: TreeMap<String, String>?) : Boolean
    fun routeEvent(eventName: String?, params: TreeMap<String, String>?) : Boolean
}
