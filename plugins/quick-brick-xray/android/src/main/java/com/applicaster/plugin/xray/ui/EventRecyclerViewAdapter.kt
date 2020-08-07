package com.applicaster.plugin.xray.ui

import android.content.ClipData
import android.content.ClipboardManager
import android.text.format.DateFormat
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat.getSystemService
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.utility.format
import com.applicaster.xray.core.Event
import kotlinx.android.synthetic.main.fragment_event_log_entry.view.*

class EventRecyclerViewAdapter(
        owner: LifecycleOwner,
        observableEventList: LiveData<List<Event>>
) : RecyclerView.Adapter<EventRecyclerViewAdapter.ViewHolder>(), Observer<List<Event>> {

    private var values: List<Event> = observableEventList.value!!

    init {
        observableEventList.observe(owner, this)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = LayoutInflater.from(parent.context)
                .inflate(R.layout.fragment_event_log_entry, parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = values[position]
        holder.bind(item)
    }

    override fun getItemCount(): Int = values.size

    inner class ViewHolder(private val view: View)
        : RecyclerView.ViewHolder(view) {

        init {
            view.setOnLongClickListener {
                getSystemService<ClipboardManager>(
                        view.context,
                        ClipboardManager::class.java
                )?.let {
                    val clip = ClipData.newPlainText("log event", event!!.format())
                    it.setPrimaryClip(clip)
                    Toast.makeText(
                            view.context,
                            "Message was copied to clipboard",
                            Toast.LENGTH_SHORT
                    ).show()
                }
                true
            }
        }

        private var event: Event? = null

        // should be static, but its internal class
        private val colors = view.resources.getIntArray(R.array.log_levels)

        override fun toString(): String {
            return super.toString() + " '" + view.message.text + "'"
        }

        fun bind(item: Event) {
            event = item
            itemView.message.text = item.message
            itemView.lbl_tag.text = item.category
            itemView.lbl_subsystem.text = item.subsystem
            itemView.time.text = DateFormat.format("yyyy-MM-dd HH:mm:ss", item.timestamp)
            itemView.view_color_tag.setBackgroundColor(getColor(item))
        }

        private fun getColor(item: Event): Int {
            return if (item.level < colors.size) colors[item.level] else colors.last()
        }
    }

    override fun onChanged(t: List<Event>?) {
        this.values = t!!
        notifyDataSetChanged()
    }
}

