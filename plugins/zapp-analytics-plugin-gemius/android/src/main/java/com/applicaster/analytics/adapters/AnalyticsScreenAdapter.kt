package com.applicaster.analytics.adapters

import androidx.annotation.CallSuper
import com.applicaster.util.APLogger
import java.util.*

open class AnalyticsScreenAdapter : IAnalyticsAdapter {

    var data: Map<String, Any>? = null

    private fun cleanData() {
        data = null
    }

    override fun routeTimedEventStart(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            // ...add events there and return true
            else -> return false
        }
        return true
    }

    override fun routeTimedEventEnd(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when(eventName) {
            null -> return false
            // ...add events there and return true
            else -> return false
        }
        return true
    }

    override fun routeEvent(eventName: String?, params: TreeMap<String, String>?) : Boolean {
        when {
            eventName == null -> return false
            eventName.startsWith(SCREEN_VIEW_HOME) -> onOpenHome(eventName, params)
            eventName.startsWith(SCREEN_VIEW) -> routeOpenScreen(eventName, params)
            eventName.startsWith(WEB_PAGE_LOADED) -> routeOpenWebpage(eventName, params)
            BACK_NAV == eventName -> onBackNav(eventName, params)
            else -> return false
        }
        return true
    }

    @CallSuper
    protected open fun onBackNav(eventName: String, params: TreeMap<String, String>?) {
        APLogger.verbose(TAG, "onBackNav $eventName")
    }

    private fun routeOpenWebpage(eventName: String, params: TreeMap<String, String>?) {
        params?.get(WEB_PAGE_LOADED_KEY_URL)?.let {
            if(it.isNotEmpty()) { // if url is missing or empty, its a broken event
                onOpenWebpage(it, params)
            }
        }
    }

    @CallSuper
    protected open fun onOpenWebpage(url: String, params: TreeMap<String, String>?) {
        APLogger.verbose(TAG, "onOpenWebpage $url")
    }

    private fun routeOpenScreen(event: String, params: TreeMap<String, String>?) {
        val screenName = event.substring(SCREEN_VIEW.length)
        onOpenScreen(screenName, params)
    }

    @CallSuper
    protected open fun onOpenScreen(screenName: String, params: TreeMap<String, String>?) {
        APLogger.verbose(TAG, "onOpenScreen $screenName")
    }

    @CallSuper
    protected open fun onOpenHome(eventName: String, params: TreeMap<String, String>?) {
        APLogger.verbose(TAG, "onOpenHome")
    }

    companion object {

        private const val TAG = "AnalyticsScreenAdapter"

        // We definitely need better events

        const val SCREEN_VIEW_HOME = "Home screen: viewed"

        const val SCREEN_VIEW = "Screen viewed: "

        const val WEB_PAGE_LOADED = "Loaded webview page"

        const val WEB_PAGE_LOADED_KEY_URL = "URL"

        // not sure if we want it in that particular adapter
        const val BACK_NAV = "Tap Navbar Back Button"

        const val BACK_NAV_KEY_SOURCE = "Trigger"
    }
}
