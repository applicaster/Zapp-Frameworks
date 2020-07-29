package com.applicaster.plugin.xray.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.XRayPlugin
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.example.sinks.InMemoryLogSink

/**
 * A fragment representing a list of Items.
 */
class EventLogFragment : Fragment() {

    override fun onCreateView(
            inflater: LayoutInflater, container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.fragment_event_log_list, container, false)

        // We expect our example Plugin to provide this sink as InMemoryLogSink
        val inMemoryLogSink = Core.get().getSink(XRayPlugin.inMemorySinkName) as InMemoryLogSink?

        // todo: show message if sink is missing
        if (null != inMemoryLogSink) {
            val list = view.findViewById<RecyclerView>(R.id.list)

            // Wrap original list to filtered one
            val filteredList = FilteredEventList(viewLifecycleOwner, inMemoryLogSink.getLiveData())

            // Setup log level filter spinner
            val levels = view.findViewById<Spinner>(R.id.cb_filter)
            levels.adapter = ArrayAdapter(levels.context, android.R.layout.simple_list_item_1, LogLevel.values())
            levels.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                }

                override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                    filteredList.filter = LogLevel.values()[position]
                }
            }

            // Setup the list adapter
            list.adapter = EventRecyclerViewAdapter(
                    viewLifecycleOwner,
                    filteredList
            )

        }
        return view
    }

    companion object {

        @JvmStatic
        fun newInstance() = EventLogFragment()
    }
}