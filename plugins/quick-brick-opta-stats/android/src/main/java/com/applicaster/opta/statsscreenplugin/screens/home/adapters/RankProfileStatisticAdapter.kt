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
import kotlinx.android.synthetic.main.item_rank_profile_statistic.view.*

class RankProfileStatisticAdapter(private val items: List<GroupModel.Ranking>,
                                  private val context: Context?,
                                  private val listener: GroupAdapter.OnTeamFlagClickListener)
    : RecyclerView.Adapter<RankProfileStatisticBasicViewHolder>() {

    enum class Type { Header, Item }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RankProfileStatisticBasicViewHolder {
        val inflater = LayoutInflater.from(context)
        return when (Type.values()[viewType]) {
            Type.Header -> HeaderViewHolder(inflater.inflate(R.layout.item_rank_profile_statistic_header, parent, false))
            Type.Item -> ItemViewHolder(inflater.inflate(R.layout.item_rank_profile_statistic, parent, false), listener)
        }
    }

    override fun getItemCount(): Int {
        val rankTeamsCount = PluginDataRepository.INSTANCE.getTeamsCount()
        val finalSize = if (items.size > rankTeamsCount) rankTeamsCount else items.size
        return finalSize + 1
    }

    override fun onBindViewHolder(holder: RankProfileStatisticBasicViewHolder, position: Int) {
        if (position != 0) {
            holder.bind(items[position - 1])
        }
    }

    override fun getItemViewType(position: Int): Int {
        val type = if (position == 0) Type.Header else Type.Item
        return type.ordinal
    }
}

class ItemViewHolder(view: View, private val listener: GroupAdapter.OnTeamFlagClickListener) : RankProfileStatisticBasicViewHolder(view) {
    var ivFlag: ImageView = view.team
    var tvPlayed: TextView = view.played
    var tvWon: TextView = view.won
    var tvLost: TextView = view.lost
    var tvDrawn: TextView = view.drawn
    var tvGf: TextView = view.gf
    var tvGc: TextView = view.gc
    var tvPlusLess: TextView = view.plus_less
    var tvPts: TextView = view.pts

    override fun bind(rank: GroupModel.Ranking) {
        rank.contestantId?.let { Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it)).into(ivFlag) }
        tvPlayed.text = rank.matchesPlayed.toString()
        tvWon.text = rank.matchesWon.toString()
        tvLost.text = rank.matchesLost.toString()
        tvDrawn.text = rank.matchesDrawn.toString()
        tvGf.text = rank.goalsFor.toString()
        tvGc.text = rank.goalsAgainst.toString()
        tvPlusLess.text = rank.goaldifference
        tvPts.text = rank.points.toString()
        ivFlag.setOnClickListener { listener.onTeamFlagClicked(rank.contestantId) }
    }
}

class HeaderViewHolder(view: View) : RankProfileStatisticBasicViewHolder(view) {

    override fun bind(rank: GroupModel.Ranking) {}
}

abstract class RankProfileStatisticBasicViewHolder(view: View) : RecyclerView.ViewHolder(view) {

    abstract fun bind(rank: GroupModel.Ranking)

}