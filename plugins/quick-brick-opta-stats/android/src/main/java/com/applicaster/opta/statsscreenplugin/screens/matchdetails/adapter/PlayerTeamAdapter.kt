package com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import kotlinx.android.synthetic.main.item_away_player_team.view.tv_player_name
import kotlinx.android.synthetic.main.item_away_player_team.view.tv_player_number
import kotlinx.android.synthetic.main.item_away_player_team.view.tv_player_position

class PlayerTeamAdapter(private val items: List<MatchModel.Player>?, val context: Context?,
                        var isFromHomeTeam: Boolean)
    : RecyclerView.Adapter<PlayerViewHolder>() {

    private val homePlayer = 0
    private val awayPlayer = 1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlayerViewHolder {
        val layoutId = if (viewType == homePlayer) R.layout.item_home_player_team
        else R.layout.item_away_player_team

        return PlayerViewHolder(LayoutInflater.from(context).inflate(layoutId, parent, false))
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: PlayerViewHolder, position: Int) {

        items?.let {
            val item = it[position]
            holder.tvPlayerName.text = item.matchName
            holder.tvPlayerNumber.text = item.shirtNumber.toString()
            holder.tvPlayerPosition.text = ModelUtils.getPlayerPosition(context, item.position)

            holder.generalView.setOnClickListener {
                PluginUtils.goToPlayerScreen(item.playerId)
            }
        }

    }

    override fun getItemViewType(position: Int): Int {
        // if player is from home team load the view correspondent to home team player
        return if (isFromHomeTeam) homePlayer else awayPlayer
    }
}

class PlayerViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    var tvPlayerNumber = view.tv_player_number
    var tvPlayerPosition = view.tv_player_position
    var tvPlayerName = view.tv_player_name
    var generalView = view
}