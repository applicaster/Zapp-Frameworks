package com.applicaster.opta.statsscreenplugin.data.api

import android.content.Context
import android.util.Log
import com.applicaster.app.CustomApplication
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import com.applicaster.util.AppContext
import okhttp3.Cache
import okhttp3.CacheControl
import okhttp3.Interceptor
import okhttp3.Response
import java.io.File
import java.io.IOException


class CacheProvider {
    companion object {
        var cacheSize: Long = 10 * 1024 * 1024 // this is 10MB

        fun provideCache(context: Context): Cache? {
            var cache: Cache? = null
            try {
                cache = Cache(File(context.cacheDir, "http-cache"), cacheSize)
            } catch (e: Exception) {
                Log.e("Cache", "Error in creating  Cache!")
            }

            return cache
        }
    }

    class ForceCacheInterceptor : Interceptor {
        @Throws(IOException::class)
        override fun intercept(chain: Interceptor.Chain): Response {
            val builder = chain.request().newBuilder()
            if (!PluginUtils.isNetworkConnected(AppContext.get())) {
                builder.cacheControl(CacheControl.FORCE_CACHE)
            }

            return chain.proceed(builder.build())
        }
    }
}