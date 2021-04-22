package com.applicaster.opta.statsscreenplugin.screens.home.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.UrlType
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.item_rank_profile_top.view.*

class RankProfileTopAdapter(private val items: List<GroupModel.Ranking>,
                            private val context: Context?,
                            private val listener: GroupAdapter.OnTeamFlagClickListener)
    : RecyclerView.Adapter<RankProfileTopViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, p1: Int): RankProfileTopViewHolder =
            RankProfileTopViewHolder(LayoutInflater.from(context).inflate(R.layout.item_rank_profile_top, parent, false))

    override fun getItemCount(): Int {
        val rankTeamsCount = PluginDataRepository.INSTANCE.getTeamsCount()
        return if (items.size > rankTeamsCount) rankTeamsCount else items.size
    }

    override fun onBindViewHolder(holder: RankProfileTopViewHolder, position: Int) {
        val rank = items[position]
        rank.contestantId?.let { Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it)).into(holder.ivFlag) }
        holder.tvName.text = rank.contestantCode
        holder.tvPoints.text = rank.points.toString()
        holder.ivFlag.setOnClickListener { listener.onTeamFlagClicked(rank.contestantId) }
    }
}

class RankProfileTopViewHolder(view: View) : RecyclerView.ViewHolder(view) {

    var ivFlag: ImageView = view.iv_flag
    var tvName: TextView = view.tv_name
    var tvPoints: TextView = view.tv_points

}