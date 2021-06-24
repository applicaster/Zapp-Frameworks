package com.applicaster.plugin.onetrust.reactnative

import androidx.appcompat.app.AppCompatActivity
import com.applicaster.plugin.onetrust.OneTrustPlugin
import com.applicaster.plugin_manager.PluginManager
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class OneTrustBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "OneTrustBridge"
    }

    override fun getName(): String = NAME

    private fun getPlugin(): OneTrustPlugin =
            PluginManager
                    .getInstance()
                    .getInitiatedPlugin(OneTrustPlugin.PluginId)!!.instance as OneTrustPlugin

    @ReactMethod
    fun showPreferences(result: Promise) {
        getPlugin().apply {
            when {
                isReady -> reactApplicationContext.runOnUiQueueThread {
                    showPreferences(
                            currentActivity as AppCompatActivity
                    ) { result.resolve(true) }
                }
                else -> result.reject("NotReady", "OneTrust is not ready")
            }
        }
    }

    @ReactMethod
    fun showNotice(result: Promise) {
        getPlugin().apply {
            when {
                isReady -> reactApplicationContext.runOnUiQueueThread {
                    showNotice(
                            currentActivity as AppCompatActivity
                    ) { result.resolve(true) }
                }
                else -> result.reject("NotReady", "OneTrust is not ready")
            }
        }
    }

}