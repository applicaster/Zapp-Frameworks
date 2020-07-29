package com.applicaster.plugin.xray.ui

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.LogLevel

class FilteredEventList(owner: LifecycleOwner,
                        private val originalList: LiveData<List<Event>>)
    : MutableLiveData<List<Event>>(), Observer<List<Event>> {

    var filter: LogLevel = LogLevel.verbose
        set(value) {
            field = value
            update()
        }

    private fun update() {
        // Assuming we are in the main thread
        value = originalList.value!!.filter { it.level >= filter.level }
    }

    init {
        update()
        this.originalList.observe(owner, this)
    }

    override fun onChanged(t: List<Event>?) = update()
}
