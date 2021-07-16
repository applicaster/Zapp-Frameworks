package com.applicaster.plugin.xray.sinks

import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import com.applicaster.util.AppContext
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.ISink
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.ConcurrentHashMap

class TimingSink : ISink {

    private var csv: FileOutputStream = FileOutputStream(file)

    private val handler: Handler = Handler(HandlerThread(TAG).apply { start() }.looper)

    init {
        csv.write("time,total diff,thread name,thread diff,category,subsystem,message\n".toByteArray())
    }

    @Volatile
    private var lastTimestamp: Long = System.currentTimeMillis()
    private val lastThreadTimestamps: ConcurrentHashMap<Long, Long> = ConcurrentHashMap()
    private val startTimestamp: Long = System.currentTimeMillis()

    override fun log(event: Event) {
        val now = System.currentTimeMillis()
        val currentThread = Thread.currentThread()
        val prev = lastThreadTimestamps.put(currentThread.id, now) ?: lastTimestamp
        Log.e(TAG, "s ${now - startTimestamp} a ${now - lastTimestamp} t(${currentThread.name}) ${now - prev} | ${event.category} | ${event.subsystem} | ${event.message.take(45)}")
        val s = "${now - startTimestamp}," +
                "${now - lastTimestamp}," +
                "${currentThread.name}," +
                "${now - prev}," +
                "${event.category}," +
                "${event.subsystem}," +
                "\"${event.message.take(MSG_LEN).replace("\"", "\"\"")}\"" +
                "\n"
        handler.post {
            csv.write(s.toByteArray())
            csv.flush()
        }
        lastTimestamp = now
    }

    @Override
    fun finalize() {
        // close can be called multiple times
        close()
    }

    fun close() {
        csv.close()
    }

    companion object {
        val file: File
            get() = File(
                    AppContext.get().getExternalFilesDir(null),
                    "profile.csv")
        private const val TAG = "TimingSink"
        private const val MSG_LEN = 65
    }

}
