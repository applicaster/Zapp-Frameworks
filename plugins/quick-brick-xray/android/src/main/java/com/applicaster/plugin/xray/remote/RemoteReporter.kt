package com.applicaster.plugin.xray.remote

import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.ISink
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Request
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.Executors
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit


class RemoteReporter(
        endpoint: String,
        private val deviceId: String
) : ISink {

    companion object {

        // default delay between drains
        private const val MAX_DELAY_MS = 3000L

        // queue size that will trigger drain even if MAX_DELAY_MS has not yet passed
        private const val MAX_QUEUE_SIZE = 100

        // max retries before batch will be dropped for good
        private const val MAX_RETRIES = 0

        // max send errors before shutting the reporter down
        private const val MAX_ERRORS = 3

        // use additional thread for sending (http calls performed in a separate thread anyway)
        private const val USE_WORK_THREAD = true

        // adb logger tag. We can't log back to X-Ray here, so use Android Log
        private const val TAG: String = "RemoteReporter"

        private const val SHUTDOWN_REASON_ERRORS = "Remote logger was stopped due to a high error count. It will stay disabled till next app launch"
        private const val SHUTDOWN_REASON_SERVER = "Remote logger was stopped by server request. It will stay disabled till next app launch"
    }

    private var active: Boolean = true
    private val callback: Callback<Void> = object : Callback<Void> {

        private var errors = 0

        override fun onResponse(call: Call<Void>, response: Response<Void>) {
            if (response.isSuccessful) {
                errors = 0
            } else {
                val code = response.code()
                Log.e(TAG, "Batch send returned error $code")
                if(403 == code || ++errors > MAX_ERRORS) {
                    shutdown(if(403 == code) SHUTDOWN_REASON_SERVER else SHUTDOWN_REASON_ERRORS)
                    return
                }
                // just drop batch on fail
            }
            if (!entries.isEmpty()) {
                scheduleDrain(MAX_DELAY_MS)
            }
        }

        override fun onFailure(call: Call<Void>, t: Throwable) {
            Log.e(TAG, "Batch send failed", t)
            if(++errors > MAX_ERRORS) {
                shutdown(SHUTDOWN_REASON_ERRORS)
                return
            }
            // just drop batch on fail
            if (!entries.isEmpty()) {
                scheduleDrain(MAX_DELAY_MS)
            }
        }
    }

    @Volatile
    private var lastDrain: Long = System.currentTimeMillis() // no need for atomic, but volatile is needed

    // currently accumulated batch
    private val entries: LinkedBlockingQueue<String> = LinkedBlockingQueue()

    private val handler: Handler = Handler(
            if (!USE_WORK_THREAD) Looper.getMainLooper()
            else HandlerThread(TAG).apply { start() }.looper)

    private val drainRunnable: Runnable = Runnable(this::drain)

    private val executor by lazy { Executors.newSingleThreadExecutor() }

    private val api: IRemoteLogAPI by lazy {
        val client: OkHttpClient.Builder = OkHttpClient.Builder().apply {
            readTimeout(60, TimeUnit.SECONDS)
            writeTimeout(60, TimeUnit.SECONDS)
            connectTimeout(60, TimeUnit.SECONDS)
            // basic retrieves. if call fails MAX_RETRIES times, just drop it
            if(MAX_RETRIES > 0) {
                interceptors().add(Interceptor {
                    val request: Request = it.request()
                    var response = it.proceed(request)
                    var tryCount = 0
                    while (!response.isSuccessful && tryCount++ < MAX_RETRIES) {
                        response.close()
                        response = it.proceed(request)
                    }
                    response
                })
            }
        }
        Retrofit.Builder()
                .baseUrl(endpoint)
                .client(client.build())
                .addConverterFactory(GsonConverterFactory.create())
                .callbackExecutor(executor)
                .build()
                .create(IRemoteLogAPI::class.java)
    }

    override fun log(event: Event) {
        if(!active) {
            return
        }
        entries.add(event.message)
        // can add other conditions later, for example, send immediately on errors
        if(entries.size > MAX_QUEUE_SIZE || lastDrain + MAX_DELAY_MS < System.currentTimeMillis()) {
            scheduleDrain(0)
        } else {
            scheduleDrain(MAX_DELAY_MS)
        }
    }

    /**
     * Shutdown this RemoteReporter gracefully, and free up threads
     */
    fun shutdown(reason: String) {
        Log.w(TAG, reason)
        active = false
        handler.removeCallbacks(drainRunnable)
        entries.clear()
        // do not try to stop UI thread
        if(USE_WORK_THREAD) {
            handler.looper.quitSafely()
        }
        // free http thread
        executor.shutdown()
    }

    private fun scheduleDrain(delay: Long) {
        // not more than one scheduled drain at a time
        handler.removeCallbacks(drainRunnable)
        if(active) {
            handler.postDelayed(drainRunnable, delay)
        }
    }

    private fun drain() {
        lastDrain = System.currentTimeMillis() // remember the time even if nothing will be sent
        val batch = ArrayList<String>(MAX_QUEUE_SIZE)
        if(entries.drainTo(batch, MAX_QUEUE_SIZE) > 0) {
            Log.i(TAG, "Draining ${batch.size} events")
            api.batch(LogPack(LogBatch(deviceId, batch))).enqueue(callback)
        }
    }

}
