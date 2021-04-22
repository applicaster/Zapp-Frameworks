package com.applicaster.opta.statsscreenplugin.screens.home.adapters

import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.transition.Transition
import android.transition.TransitionInflater
import android.transition.TransitionManager
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.DimenRes
import androidx.annotation.RequiresApi
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import kotlinx.android.synthetic.main.item_group_card.view.*

class GroupAdapter(private val items: List<GroupModel.Division>,
                   private val context: Context?,
                   private val listener: OnTeamFlagClickListener)
    : RecyclerView.Adapter<GroupViewHolder>() {

    interface OnTeamFlagClickListener {
        fun onTeamFlagClicked(teamId: String)
    }

    private var expandCollapseTransition: Transition? = null
    private var recyclerView: RecyclerView? = null
    private var teamItemMargin: Int = 0

    init {
        context?.resources?.apply {
            val generalListMargin = getDimensionPixelOffset(R.dimen.horizontal_margin_item_group_list)
            val teamListMargin = getDimensionPixelOffset(R.dimen.horizontal_margin_teams_list)
            val teamItemWidth = getDimensionPixelOffset(R.dimen.horizontal_item_flag_width)
            val screenWidth = displayMetrics.widthPixels
            teamItemMargin = ((screenWidth - (generalListMargin * 2 + teamListMargin * 2 + teamItemWidth * 4)) / 5).let { if (it < 0) 0 else it }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): GroupViewHolder {
        return GroupViewHolder(LayoutInflater.from(context).inflate(R.layout.item_group_card, parent, false))
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onAttachedToRecyclerView(recyclerView: RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
        this.recyclerView = recyclerView
        expandCollapseTransition = TransitionInflater.from(recyclerView.context)
                .inflateTransition(R.transition.card_expand_toggle)
                .apply { duration = 300 }
    }


    override fun onBindViewHolder(holderGroup: GroupViewHolder, position: Int) {
        holderGroup.tvGroupName.text = items[position].groupName.toUpperCase()
        holderGroup.rvRankProfileTop.adapter = RankProfileTopAdapter(items[position].ranking, context, listener)
        holderGroup.rvRankProfileTop.addItemDecoration(RankProfileTopItemDecoration(teamItemMargin))
        holderGroup.rvRankProfileStatistic.adapter = RankProfileStatisticAdapter(items[position].ranking, context, listener)
        holderGroup.rvRankProfileStatistic.addItemDecoration(RankProfileStatisticItemDecoration(R.dimen.margin_rank_statistic_divider))
        holderGroup.ivArrow.setOnClickListener {
            // only for devices with Android 5.0 and above
            // come on! if you have a device with KitKat facebook will not work
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                toggleView(holderGroup)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    private fun toggleView(holderGroup: GroupViewHolder) {
        if (holderGroup.rvRankProfileStatistic.visibility == View.GONE) {
            holderGroup.ivArrow.animate().rotation(180f).start()

            recyclerView?.let {
                TransitionManager.beginDelayedTransition(it, expandCollapseTransition)
            }
            holderGroup.rvRankProfileStatistic.visibility = View.VISIBLE
            holderGroup.vDivider.visibility = View.VISIBLE
        } else {
            holderGroup.ivArrow.animate().rotation(0f).start()

            recyclerView?.let {
                TransitionManager.beginDelayedTransition(it, expandCollapseTransition)
            }
            holderGroup.rvRankProfileStatistic.visibility = View.GONE
            holderGroup.vDivider.visibility = View.GONE
        }
    }
}

class GroupViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    var tvGroupName: TextView = view.tv_group_name
    var rvRankProfileTop: RecyclerView = view.rv_rank_profile_top
    var rvRankProfileStatistic: RecyclerView = view.rv_rank_profile_statistic
    var ivArrow: ImageView = view.iv_arrow
    var vDivider: View = view.vDivider
}

private class RankProfileTopItemDecoration(val marginDimen: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(outRect: Rect, view: View,
                                parent: RecyclerView, state: RecyclerView.State) {
        with(outRect) {
            if (parent.getChildAdapterPosition(view) == 0) left = marginDimen
            right = marginDimen
        }
    }
}

private class RankProfileStatisticItemDecoration(@DimenRes val marginRes: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(outRect: Rect, view: View,
                                parent: RecyclerView, state: RecyclerView.State) {
        with(outRect) {
            val margin = view.context.resources.getDimensionPixelOffset(marginRes)
            if (parent.getChildAdapterPosition(view) == 0) top = margin
            bottom = margin
        }
    }
}