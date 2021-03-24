package com.applicaster.plugin.didomi.reactnative

import androidx.appcompat.app.AppCompatActivity
import com.applicaster.plugin.didomi.DidomiPlugin
import com.applicaster.plugin_manager.PluginManager
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class DidomiBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "DidomiBridge"
    }

    override fun getName(): String = NAME

    private fun getPlugin(): DidomiPlugin =
            PluginManager
                    .getInstance()
                    .getInitiatedPlugin(DidomiPlugin.PluginId)!!.instance as DidomiPlugin

    @ReactMethod
    fun showPreferences(result: Promise) {
        getPlugin().apply {
            when {
                isReady() -> showPreferences(
                        { result.resolve(true) },
                        currentActivity as AppCompatActivity)
                else -> result.reject("NotReady", "Didomi is not ready")
            }
        }
    }

    @ReactMethod
    fun showNotice(result: Promise) {
        getPlugin().apply {
            when {
                isReady() -> showNotice(
                        { result.resolve(true) },
                        currentActivity as AppCompatActivity)
                else -> result.reject("NotReady", "Didomi is not ready")
            }
        }
    }

}