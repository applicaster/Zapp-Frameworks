package com.applicaster.opta.statsscreenplugin.screens.team.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.PlayerSquadModel
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.UrlType
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.item_player_squad.view.*

class SquadAdapter(private val items: List<PlayerSquadModel.Person>, val context: Context?, private val listener: OnPlayerClickedListener) :
        RecyclerView.Adapter<SquadViewHolder>() {


    var onPlayerClickedListener: OnPlayerClickedListener = listener

    interface OnPlayerClickedListener {
        fun onPlayerClicked(playerId: String)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SquadViewHolder {
        val layout = if (viewType == 0) R.layout.item_player_squad
        else R.layout.item_player_squad_to_the_right
        return SquadViewHolder(LayoutInflater.from(context).inflate(layout, parent, false))
    }

    override fun getItemViewType(position: Int): Int {
        return position % 2
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holderGroup: SquadViewHolder, position: Int) {
        holderGroup.tvPlayerName.text = items[position].matchName
        if (items[position].type.equals("PLAYER", true)) {
            holderGroup.tvPosition.text = ModelUtils.getPlayerPosition(context, items[position].position)
            holderGroup.tvTShirtNumber.visibility = View.VISIBLE
        } else {
            holderGroup.tvPosition.text = items[position].type.capitalize()
            holderGroup.tvTShirtNumber.visibility = View.GONE
        }

        val shirtNumber = if (items[position].shirtNumber == 0) "-" else items[position].shirtNumber.toString()
        holderGroup.tvTShirtNumber.text = shirtNumber

        holderGroup.cvPlayerView.setOnClickListener {
            if (items[position].type.equals("PLAYER", true)) {
                onPlayerClickedListener.onPlayerClicked(items[position].id)
            }
        }

        Picasso.get().load(ModelUtils.getImageUrl(UrlType.Person, items[position].id))
                .placeholder(R.drawable.player_placeholder)
                .into(holderGroup.ivPlayerImage)
    }
}

class SquadViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    var cvPlayerView = view.cv_item_player
    var tvPlayerName = view.tv_player_in_squad_name
    var ivPlayerImage = view.iv_player_in_squad
    var tvTShirtNumber = view.tv_player_tshirt_number
    var tvPosition = view.tv_player_in_squad_position
}