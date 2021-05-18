package com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter

import android.content.Context
import android.content.res.Resources
import androidx.core.content.ContextCompat
import android.view.View
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import kotlinx.android.synthetic.main.item_player.view.*

class PlayerPositionAdapter(private val items: List<PlayerPosition>?, val context: Context?)
    : RecyclerView.Adapter<PositionViewHolder>() {

    var resources: Resources? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PositionViewHolder {
        resources = context?.resources
        return PositionViewHolder(LayoutInflater.from(context).inflate(R.layout.item_player, parent,
                false))
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: PositionViewHolder, position: Int) {
        items?.let {
            val item = it[position]

            holder.tvShirtNumber.text = item.shirtNumber
            context?.let { ctx ->
                val textColor = ContextCompat.getColor(ctx, if (item.isRightTeam) R.color.white else R.color.black)
                val drawable = if (item.isRightTeam) R.drawable.gray_circle else R.drawable.white_circle
                holder.tvShirtNumber.setTextColor(textColor)
                holder.ivBackground.setImageResource(drawable)
            }
        }
    }

}

class PositionViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    var tvShirtNumber: TextView = view.tv_player_number
    var ivBackground: ImageView = view.iv_player_background
}

data class PlayerPosition(var shirtNumber: String, var isRightTeam: Boolean)