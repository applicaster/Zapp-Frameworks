package com.applicaster.opta.statsscreenplugin.reactnative

import android.content.Context
import android.os.Build
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.lesscodeutils.date.DateUtils
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesInteractor
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesPresenter
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesView
import com.applicaster.opta.statsscreenplugin.screens.home.HomeInteractor
import com.applicaster.opta.statsscreenplugin.screens.home.HomePresenter
import com.applicaster.opta.statsscreenplugin.screens.home.HomeView
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.GroupAdapter
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.MatchAdapter
import com.applicaster.opta.statsscreenplugin.screens.match.MatchInteractor
import com.applicaster.opta.statsscreenplugin.screens.match.MatchPresenter
import com.applicaster.opta.statsscreenplugin.screens.match.MatchView
import com.applicaster.opta.statsscreenplugin.utils.Constants
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import com.applicaster.opta.statsscreenplugin.view.StickyRecyclerView
import com.applicaster.util.APLogger
import java.util.*

class OptaHomeView(context: Context) : FrameLayout(context),
        HomeView, MatchView, AllMatchesView,
        GroupAdapter.OnTeamFlagClickListener,
        MatchAdapter.OnMatchClickListener {

    // todo: timers (handle focus lost as well)

    private val knockout: Boolean = true
    private val loadQueue = ArrayDeque<AllMatchesModel.Match>()

    // instead of synthetics for now
    private var pageIndicator: com.chahinem.pageindicator.PageIndicator
    private var rv_group_cards: RecyclerView
    private var rv_past_matches: RecyclerView
    private var rv_matches: StickyRecyclerView
    private var pb_loading: View

    init {
        APLogger.info(TAG, "OptaStatsView created")
        val view = LayoutInflater.from(context).inflate(R.layout.fragment_home, this, false)

        pageIndicator = view.findViewById(R.id.pageIndicator)
        rv_group_cards = view.findViewById(R.id.rv_group_cards)
        rv_matches = view.findViewById(R.id.rv_matches)
        rv_past_matches = view.findViewById(R.id.rv_past_matches)
        pb_loading = view.findViewById(R.id.pb_loading)

        view.findViewById<View>(R.id.btn_all_matches).apply {
            if (!knockout) {
                visibility = GONE
            } else {
                setOnClickListener {
                    context.startActivity(OptaStatsActivity.getCallingIntent(context,
                            OptaStatsActivity.Companion.Screen.ALL_MATCHES, HashMap()))
                }
                visibility = VISIBLE
            }
        }

        view.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        addView(view)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        // this one has a bug: we do 2 parallel requests, but it only has one disposable inside.
        // so one disposable will never be disposed
        homePresenter.getAllMatchesFromDate()
        homePresenter.getGroups()
    }

    override fun requestLayout() {
        super.requestLayout()

        // This view relies on a measure + layout pass happening after it calls requestLayout().
        // https://github.com/facebook/react-native/issues/4990#issuecomment-180415510
        // https://stackoverflow.com/questions/39836356/react-native-resize-custom-ui-component
        post(measureAndLayout)
    }

    private val measureAndLayout = Runnable {
        measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        layout(left, top, right, bottom)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        homePresenter.onDestroy()
        matchPresenter.onDestroy()
        matchesPresenter.onDestroy()
    }

    // todo: this should be configurable
    lateinit var startDate: String
    lateinit var endDate: String

    // presenters
    private var homePresenter: HomePresenter = HomePresenter(this, HomeInteractor())
    private var matchPresenter: MatchPresenter = MatchPresenter(this, MatchInteractor())

    // this one is only used in knockout
    private var matchesPresenter: AllMatchesPresenter = AllMatchesPresenter(this, AllMatchesInteractor())

    private var matches: List<AllMatchesModel.MatchDate> = listOf()

    // above matches but with more details
    private var matchDetails = mutableMapOf<String, MatchModel.Match>()

    fun heartbeat() {
        // every time the heartbeat is called is needed to clear the matches
        resetList()
        homePresenter.getAllMatchesFromDate()
    }

    private fun resetList() {
        matches = listOf()
        loadQueue.clear()
        matchDetails.clear()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun getGroupsSuccess(groupCards: GroupModel.Group) {
        rv_group_cards.layoutManager = LinearLayoutManager(context)
        rv_group_cards.isNestedScrollingEnabled = false
        rv_group_cards.adapter = GroupAdapter(ModelUtils.getDivisionWithTypeTotal(groupCards), context, this)
    }

    override fun getGroupsFail(error: String?) {
        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
    }

    override fun getAllMatchesSuccess(allMatches: AllMatchesModel.AllMatches) {
        startDate = allMatches.tournamentCalendar.startDate
        endDate = allMatches.tournamentCalendar.endDate

        val currentDate = DateUtils.getCurrentDate(Constants.UTC_DATE_FORMAT)
        val bannerLimit = PluginDataRepository.INSTANCE.getNumberOfMatches().toInt()
        matches = when {
            currentDate > startDate -> {
                val (past, future) = allMatches.matchDate.partition { it.date < currentDate }
                when {
                    knockout -> future + past.takeLast(5)// only take last 5 games and all future
                    else -> {
                        // old behavior: take only future games if any, or last few games
                        if (future.isNotEmpty())
                            future.take(bannerLimit)
                        else
                            past.takeLast(bannerLimit)
                    }
                }
            }
            else -> {
                allMatches.matchDate.take(bannerLimit)
            }
        }

        loadQueue.clear()
        loadQueue.addAll(matches.flatMap { it.match }.filter { !matchDetails.containsKey(it.id) })
        if (!loadQueue.isEmpty()) {
            when {
                loadQueue.size > 3 -> matchesPresenter.getAllMatches()
                else -> matchPresenter.getMatchDetails(loadQueue.poll().id)
            }
        } else {
            Log.d(TAG, "Details from each match were already present")
            showMatchData()
        }
    }

    private fun showMatchData() {
        val currentDate = DateUtils.getCurrentDate(Constants.UTC_DATE_FORMAT)
        val date = if (startDate > currentDate) startDate else currentDate
        val (past, future) = matches.partition { it.date < date }

        if (future.isEmpty()) {
            rv_matches.visibility = GONE
            pageIndicator.visibility = GONE
        } else {
            val futureMatches = future.flatMap { it.match }.map { matchDetails[it.id]!! }.toMutableList()
            // add extra element to build the extra card (to show all matches card)
            futureMatches.add(0, MatchModel.Match())

            // set up top recycler view
            rv_matches.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            rv_matches.adapter = MatchAdapter(futureMatches, context, this, this, false)
            pageIndicator.attachTo(rv_matches)
            rv_matches.visibility = VISIBLE
            pageIndicator.visibility = VISIBLE
        }

        if (past.isEmpty()) {
            rv_past_matches.visibility = View.GONE
        } else {
            // set up list recycler view
            rv_past_matches.visibility = View.VISIBLE
            val pastMatches = past.reversed().flatMap { it.match }.map { matchDetails[it.id]!! }
            rv_past_matches.layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            rv_past_matches.adapter = MatchAdapter(pastMatches, context, this, this, false)
        }
    }

    private fun nextMatchDetails() {
        if (!loadQueue.isEmpty()) {
            matchPresenter.getMatchDetails(loadQueue.poll().id)
        } else {
            Log.d(TAG, "Details from each match have been retrieved")
            showMatchData()
        }
    }

    override fun getMatchSuccess(matches: MatchModel.Match) {
        matchDetails[matches.matchInfo!!.id] = matches
        nextMatchDetails()
    }

    override fun onTeamFlagClicked(teamId: String) {
        PluginUtils.goToTeamScreen(teamId)
    }

    override fun onMatchClicked(matchId: String) {
        PluginUtils.goToMatchDetailsScreen(matchId)
    }

    override fun getMatchFailed(error: String?) {
        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
    }

    override fun getAllMatchesSuccess(allMatches: List<MatchModel.Match>) {
        matchDetails.plusAssign(allMatches.map { it.matchInfo!!.id to it })
        loadQueue.clear()
        loadQueue.addAll(matches.flatMap { it.match }.filter { !matchDetails.containsKey(it.id) })
        nextMatchDetails()
    }

    override fun getAllMatchesFail(error: String?) {
        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
    }

    override fun showProgress() {
        pb_loading.visibility = View.VISIBLE
    }

    override fun hideProgress() {
        pb_loading.visibility = View.GONE
    }

    companion object {
        private const val TAG = "OptaStatsView"
    }
}
