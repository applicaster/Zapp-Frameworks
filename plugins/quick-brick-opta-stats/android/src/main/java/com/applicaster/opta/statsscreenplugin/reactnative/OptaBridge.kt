package com.applicaster.opta.statsscreenplugin.reactnative

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.applicaster.util.APLogger
import com.facebook.react.bridge.*

class OptaBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "OptaBridge"
        private const val REQUEST_CODE = 12434;
        private const val TAG = NAME

        // todo unify with getCallingIntent in PluginConfigurationHandler

        private fun getCallingIntent(context: Context, data: Map<String, String>): Intent {
            val screen = when (val screenType = data["type"]) {
                null -> {
                    APLogger.error(TAG, "Screen 'type' argument is missing in URL")
                    OptaStatsActivity.Companion.Screen.HOME
                }
                "match_details" -> OptaStatsActivity.Companion.Screen.MATCH_DETAILS
                "player" -> OptaStatsActivity.Companion.Screen.PLAYER_DETAILS
                "team" -> OptaStatsActivity.Companion.Screen.TEAM
                "all_matches" -> OptaStatsActivity.Companion.Screen.ALL_MATCHES
                else -> {
                    APLogger.error(TAG, "Screen 'type' $screenType URL argument is not supported")
                    OptaStatsActivity.Companion.Screen.ALL_MATCHES
                }
            }

            return OptaStatsActivity.getCallingIntent(context, screen, data)
        }
    }

    override fun getName(): String = NAME

    @ReactMethod
    fun showScreen(options: ReadableMap, result: Promise) {

        val params = mutableMapOf<String, String>()
        if (options.hasKey("url")) {
            val url = options.getString("url")
            if (true == url?.isNotEmpty()) {
                val uri = Uri.parse(url)
                params.putAll(uri.queryParameterNames.map { it to uri.getQueryParameter(it) })
            }
        }

        reactApplicationContext.currentActivity?.let {
            val callingIntent = getCallingIntent(it, params)
            reactApplicationContext.addActivityEventListener(object : ActivityEventListener {
                override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent?) {
                    if (REQUEST_CODE == requestCode) {
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