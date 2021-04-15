package com.applicaster.opta.statsscreenplugin.reactnative

import android.app.Activity
import android.content.Intent
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.facebook.react.bridge.*

class OptaBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "OptaBridge"
        private const val REQUEST_CODE = 12434;
    }

    override fun getName(): String = NAME

    @ReactMethod
    fun showScreen(options: ReadableMap, result: Promise) {
        reactApplicationContext.currentActivity?.let {
            // todo: parse options["url"]
            val callingIntent = OptaStatsActivity.getCallingIntent(it, OptaStatsActivity.Companion.Screen.HOME, mapOf())
            reactApplicationContext.addActivityEventListener(object : ActivityEventListener {
                override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent?) {
                    if(REQUEST_CODE == requestCode) {
                        reactApplicationContext.removeActivityEventListener(this)
                        result.resolve(true)
                    }
                }

                override fun onNewIntent(intent: Intent) = Unit
            })
            it.startActivityForResult(callingIntent, REQUEST_CODE)
        }
    }

}