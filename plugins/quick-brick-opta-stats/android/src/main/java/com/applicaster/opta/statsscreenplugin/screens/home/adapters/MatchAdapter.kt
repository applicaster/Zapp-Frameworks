package com.applicaster.opta.statsscreenplugin.screens.home.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.app.CustomApplication
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.UrlType
import com.applicaster.util.AppContext
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.item_all_matches.view.*
import kotlinx.android.synthetic.main.item_match.view.*

class MatchAdapter(private val items: List<Any>,
                   private val context: Context?,
                   listener: GroupAdapter.OnTeamFlagClickListener,
                   matchListener: OnMatchClickListener,
                   var allMatchesView: Boolean) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {


    private val regularCard = 0
    private val allMatchesCard = 1

    interface OnMatchClickListener {
        fun onMatchClicked(matchId: String)
    }

    var onMatchClickListener: OnMatchClickListener = matchListener
    var onTeamFlagClickListener: GroupAdapter.OnTeamFlagClickListener = listener

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when {
            allMatchesView -> MatchViewHolder(LayoutInflater.from(context).inflate(R.layout.item_match_in_all_matches, parent,
                    false))
            viewType == regularCard -> MatchViewHolder(LayoutInflater.from(context).inflate(R.layout.item_match, parent,
                    false))
            else -> AllMatchesViewHolder(LayoutInflater.from(context).inflate(R.layout.item_all_matches,
                    parent, false))
        }
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun getItemViewType(position: Int): Int {
        return if ((items[position] as MatchModel.Match).matchInfo != null) {
            regularCard
        } else {
            allMatchesCard
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if ((items[position] as MatchModel.Match).matchInfo != null) {
            (holder as MatchViewHolder).bind(items[position] as MatchModel.Match,
                    onTeamFlagClickListener, onMatchClickListener)
        } else {
            (holder as AllMatchesViewHolder).bind()
        }
    }
}

class MatchViewHolder(val view: View) : RecyclerView.ViewHolder(view) {
    private val cvMatch = view.cv_match

    private val tvDate = view.tv_date
    private val tvPhase = view.tv_phase
    private val tvLocation = view.tv_location
    private val ivFlag1 = view.iv_flag_1
    private val ivFlag2 = view.iv_flag_2
    private val tvCountry1 = view.tv_country_1
    private val tvCountry2 = view.tv_country_2
    private val tvGoals1 = view.tv_goals_1
    private val tvGoals2 = view.tv_goals_2
    private val tvGameState = view.tv_game_state
    private val tvTime = view.tv_time
    private val pbGameState = view.pb_gam_state
    private val tvPenalties = view.tv_penalties
    private val tvPenaltiesHome = view.tv_penalties_home
    private val tvPenaltiesAway = view.tv_penalties_away

    fun bind(match: MatchModel.Match, onTeamFlagClickListener: GroupAdapter.OnTeamFlagClickListener,
             onMatchClickListener: MatchAdapter.OnMatchClickListener) {
        val context = view.context
        val matchInfo = match.matchInfo
        val contestants = matchInfo?.contestant
        val liveData = match.liveData

        ivFlag1.setImageResource(R.drawable.unknow_flag)
        ivFlag2.setImageResource(R.drawable.unknow_flag)
        tvCountry1.text = ""
        tvCountry2.text = ""

        matchInfo?.let {
            tvDate.text = ModelUtils.getReadableDateFromString(
                    String.format("%s%s", it.date, it.time)).toUpperCase()
            tvPhase.text = it.stage.name.toUpperCase()
            tvLocation.text = it.venue?.shortName?.toUpperCase()
            cvMatch.setOnClickListener { onMatchClickListener.onMatchClicked(matchInfo.id) }
        }

        contestants?.let {
            tvCountry1.text = it[0].code
            Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it[0].id)).placeholder(R.drawable.unknow_flag).into(ivFlag1)
            ivFlag1.setOnClickListener { onTeamFlagClickListener.onTeamFlagClicked(contestants[0].id) }

            if (it.size > 1) {
                tvCountry2.text = it[1].code
                Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it[1].id)).placeholder(R.drawable.unknow_flag).into(ivFlag2)
                ivFlag2.setOnClickListener { onTeamFlagClickListener.onTeamFlagClicked(contestants[1].id) }
            }
        } ?: applyDefaultValues()

        liveData?.let {
            tvGoals1.text = liveData.matchDetails.scores?.total?.home?.toString()
            tvGoals2.text = liveData.matchDetails.scores?.total?.away?.toString()
            // todo: find a way to make this better
            if (tvGoals1.text == "null") tvGoals1.text = "-"
            if (tvGoals2.text == "null") tvGoals2.text = "-"

            liveData.matchDetails.scores?.pen?.let {
                if (liveData.matchDetails.scores?.et != null) {
                    tvGoals1.text = liveData.matchDetails.scores?.et?.home.toString()
                    tvGoals2.text = liveData.matchDetails.scores?.et?.away.toString()
                } else {
                    tvGoals1.text = liveData.matchDetails.scores?.ft?.home.toString()
                    tvGoals2.text = liveData.matchDetails.scores?.ft?.away.toString()
                }

                tvPenalties.visibility = View.VISIBLE
                tvPenaltiesHome.visibility = View.VISIBLE
                tvPenaltiesAway.visibility = View.VISIBLE
                tvPenaltiesHome.text = liveData.matchDetails.scores?.pen?.home.toString()
                tvPenaltiesAway.text = liveData.matchDetails.scores?.pen?.away.toString()
            } ?: run {
                // to avoid recycling values
                tvPenalties.visibility = View.GONE
                tvPenaltiesHome.visibility = View.GONE
                tvPenaltiesAway.visibility = View.GONE
            }

            tvGameState.text = ModelUtils.getGameState(context, liveData.matchDetails.matchStatus)

            pbGameState.max = 90
            tvTime.text = "-"

            liveData.matchDetails.matchTime?.let {
                tvTime.text = String.format("%s\'", it)

                pbGameState.progress = it
            } ?: run {
                liveData.matchDetails.period?.let {
                    // when period size equals 1 it's half time
                    if (it.size == 1) {
                        tvTime.text = AppContext.get()
                                .resources
                                .getString(R.string.half_time)
                    } else {
                        liveData.matchDetails.matchLengthMin?.let {
                            pbGameState.progress = it
                            tvTime.text = String.format("%d\'", it)
                        } ?: run {
                            pbGameState.progress = 0
                        }
                    }
                } ?: run {
                    pbGameState.progress = 0
                }
            }

        }
    }

    private fun applyDefaultValues() {
        Picasso.get().load(R.drawable.unknow_flag).into(ivFlag1)
        Picasso.get().load(R.drawable.unknow_flag).into(ivFlag2)

        tvCountry1.text = ""
        tvCountry2.text = ""
    }
}

class AllMatchesViewHolder(val view: View) : RecyclerView.ViewHolder(view) {
    private val card = view.card_all_matches
    private val ivAllMatches = view.iv_all_matches

    fun bind() {
        val context = view.context
        val density = context.resources.displayMetrics.density
        val resizeHeight = context.resources.getDimensionPixelOffset(R.dimen.min_height_item_all_matches)
        val resizeWidth = context.resources.displayMetrics.widthPixels - (density * 20)

        Picasso.get()
                .load(ModelUtils.getImageUrl(UrlType.Partidos, CustomApplication.getDefaultDeviceLocale().language))
                .resize(resizeWidth.toInt(), resizeHeight)
                .into(ivAllMatches)

        card.setOnClickListener {
            context?.startActivity(OptaStatsActivity.getCallingIntent(context,
                    OptaStatsActivity.Companion.Screen.ALL_MATCHES, HashMap()))
        }
    }
}