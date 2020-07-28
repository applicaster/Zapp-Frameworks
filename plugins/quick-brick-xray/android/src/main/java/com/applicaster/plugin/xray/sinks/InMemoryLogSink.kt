package com.applicaster.xray.example.sinks

import android.os.Handler
import android.os.Looper
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.ISink
import java.util.*

class InMemoryLogSink : ISink {
    private val events: MutableList<Event> = ArrayList()
    private val handler = Handler(Looper.getMainLooper())
    private val liveData: MutableLiveData<List<Event>> =
            object : MutableLiveData<List<Event>>() {
                init {
                    value = events
                }
            }

    override fun log(event: Event) {
        handler.post { add(event) }
    }

    private fun add(event: Event) {
        events.add(event)
        liveData.postValue(events)
    }

    fun getLiveData(): LiveData<List<Event>> {
        return liveData
    }
}