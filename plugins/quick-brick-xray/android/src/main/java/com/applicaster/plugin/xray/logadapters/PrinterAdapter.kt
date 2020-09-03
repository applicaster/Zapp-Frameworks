package com.applicaster.plugin.xray.logadapters

import android.util.Printer
import com.applicaster.xray.core.Logger
import com.facebook.debug.debugoverlay.model.DebugOverlayTag

class PrinterAdapter : Printer, com.facebook.debug.holder.Printer {

    private val TAG = "DebugPrinter"

    private val logger = Logger.get("ReactNative/DebugPrinter")

    override fun println(x: String?) {
        logger.d(TAG).message(x!!)
    }

    override fun logMessage(tag: DebugOverlayTag?, message: String?, vararg args: Any?) {
        logger.d(tag!!.name).message(java.lang.String.format(message!!, *args))
    }

    override fun logMessage(tag: DebugOverlayTag?, message: String?) {
        logger.d(tag!!.name).message(message!!)
    }

    override fun shouldDisplayLogMessage(tag: DebugOverlayTag?): Boolean {
        return true
    }

}