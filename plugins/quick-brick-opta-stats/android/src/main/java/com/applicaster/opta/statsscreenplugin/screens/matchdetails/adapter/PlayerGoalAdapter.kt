package com.applicaster.opta.statsscreenplugin.screens.matchdetails.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import kotlinx.android.synthetic.main.item_away_goal.view.*

class PlayerGoalAdapter(private val items: List<MatchModel.Goal>?, val context: Context?,
                        var homeContestantId: String)
    : RecyclerView.Adapter<PlayerGoalViewHolder>() {

    private val homeGoal = 0
    private val awayGoal = 1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlayerGoalViewHolder {
        val layoutId = if (viewType == homeGoal) R.layout.item_home_goal else R.layout.item_away_goal
        return PlayerGoalViewHolder(LayoutInflater.from(context).inflate(layoutId, parent, false))
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0


    }

    override fun onBindViewHolder(holder: PlayerGoalViewHolder, position: Int) {
        items?.let {
            holder.tvGoalTime.text = String.format("%s\'", it[position].timeMin.toString())
            holder.tvPlayerGoalName.text = it[position].scorerName
        }
    }

    override fun getItemViewType(position: Int): Int {
        items?.let {
            return if (it[position].contestantId == homeContestantId) homeGoal else awayGoal
        } ?: return homeGoal
    }

}

class PlayerGoalViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    var tvGoalTime = view.tv_goal_time
    var tvPlayerGoalName = view.tv_player_goal_name
}