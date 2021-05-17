package com.applicaster.plugin.xray.sinks

import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import com.applicaster.util.OSUtil
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.ISink
import com.applicaster.xray.ui.utility.GsonHolder
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.*


class LogzSink(
    token: String,
    private val instanceId: String
) : ISink {

    private val url = URL("$BASE_URL?token=$token")

    private val bundleId = OSUtil.getPackageName()

    private val handler: Handler

    private val events = mutableListOf<Event>()

    private val sender = Runnable {
        sendBatch()
    }

    override fun log(event: Event) {
        synchronized(events) {
            events += event
            handler.removeCallbacks(sender)
            handler.postDelayed(sender, 1000)
        }
    }

    // todo: add custom serializer to inject these values
    private fun wrapEvent(event: Event): String =
            gson.toJsonTree(event).apply {
                asJsonObject.apply {
                    addProperty("instanceId", instanceId)
                    addProperty("bundleId", bundleId)
                }
            }.toString()

    private fun sendBatch() {
        var toSend: List<Event>
        synchronized(events) {
            if (events.isEmpty()) return
            toSend = ArrayList(events)
            events.clear()
        }
        try {
            val data = toSend.joinToString("\n") { wrapEvent(it) }
            val connection: HttpURLConnection = url.openConnection() as HttpURLConnection
            connection.apply {
                requestMethod = "POST"
                doOutput = true
                doInput = true
                OutputStreamWriter(outputStream, "UTF-8").use {
                    it.write(data)
                }
                if (responseCode < 300)
                    return
                val message = inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
                Log.e(TAG, "Send failed: $responseCode $message")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Send failed", e)
        }
    }

    companion object {
        private const val BASE_URL = "http://listener.logz.io:8070/"
        private const val TAG = "LogzSink"
        private val gson = GsonHolder.gson
    }

    init {
        val handlerThread = HandlerThread("Logz.io Sink Worker")
        handlerThread.start()
        handler = Handler(handlerThread.looper)
    }
}