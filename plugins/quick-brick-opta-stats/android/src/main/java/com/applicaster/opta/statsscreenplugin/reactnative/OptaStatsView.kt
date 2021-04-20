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
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
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

class OptaStatsView(context: Context) : FrameLayout(context),
        HomeView, MatchView,
        GroupAdapter.OnTeamFlagClickListener,
        MatchAdapter.OnMatchClickListener {

    // todo: timers (handle focus lost as well)

    // instead of synthetics for now
    private var pageIndicator: com.chahinem.pageindicator.PageIndicator
    private var rv_group_cards: RecyclerView
    private var rv_matches: StickyRecyclerView
    private var pb_loading: View

    init {
        APLogger.info(TAG, "OptaStatsView created")
        val view = LayoutInflater.from(context).inflate(R.layout.fragment_home, this, false)

        pageIndicator = view.findViewById(R.id.pageIndicator)
        rv_group_cards = view.findViewById(R.id.rv_group_cards)
        rv_matches = view.findViewById(R.id.rv_matches)
        pb_loading = view.findViewById(R.id.pb_loading)

        view.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        addView(view)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()

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
    }

    // todo: this should be configurable
    lateinit var startDate: String
    lateinit var endDate: String

    // presenters
    private var homePresenter: HomePresenter = HomePresenter(this, HomeInteractor())
    private var matchPresenter: MatchPresenter = MatchPresenter(this, MatchInteractor())

    // array to save matches from a specific date
    private lateinit var matchesFromDate: List<AllMatchesModel.Match>

    // above matches but with more details
    private var matchesDetailed: ArrayList<MatchModel.Match> = ArrayList()

    // counter to get the details from each match retrieved in a for loop
    private var matchesDetailedCounter: Int = 0
    // total of matches that we want to get the details
    private var matchesDetailedTotal: Int = 0

    fun heartbeat() {
        // every time the heartbeat is called is needed to clear the matches
        resetList()
        homePresenter.getAllMatchesFromDate()
    }

    private fun resetList() {
        matchesFromDate = ArrayList()
        matchesDetailed = ArrayList()
        matchesDetailedCounter = 0
        matchesDetailedTotal = 0
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

    override fun getAllMatchesFromDateSuccess(allMatchesFromDate: AllMatchesModel.AllMatches) {
        startDate = allMatchesFromDate.tournamentCalendar.startDate
        endDate = allMatchesFromDate.tournamentCalendar.endDate

        val date = if (startDate > DateUtils.getCurrentDate(Constants.UTC_DATE_FORMAT)) startDate else DateUtils.getCurrentDate(Constants.UTC_DATE_FORMAT)
        getAllMatchesDetailed(allMatchesFromDate, date)
    }

    private fun getAllMatchesDetailed(allMatches: AllMatchesModel.AllMatches, date: String) {
        // this is the specific method that get all the matches from a specific date
        matchesFromDate = ModelUtils.getNextThreeMatches(allMatches, date)
        // check if there are matches for this day
        if (matchesFromDate.isNotEmpty()) {
            // initialize a counter that will be use to count each match details
            matchesDetailedTotal = matchesFromDate.size
            getMatchDetails(matchesDetailedCounter)
        } else if (date > endDate) {
            matchesFromDate = ModelUtils.getLastThreeMatches(allMatches)
            matchesDetailedTotal = matchesFromDate.size
            getMatchDetails(matchesDetailedCounter)
        }
    }

    private fun getMatchDetails(matchesDetailedCounter: Int) {
        matchPresenter.getMatchDetails(matchesFromDate[matchesDetailedCounter].id)
    }

    override fun getMatchSuccess(matches: MatchModel.Match) {
        matchesDetailed.add(matches)
        matchesDetailedCounter++
        if (matchesDetailedCounter < matchesDetailedTotal) {
            getMatchDetails(matchesDetailedCounter)
        } else {
            Log.d(TAG, "Details from each match have been retrieved")
            matchesDetailedCounter = 0
            matchesDetailedTotal = 0

            // add extra element to build the extra card (to show all matches card)
            matchesDetailed.add(MatchModel.Match())
            // set up recycler view
            rv_matches.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            rv_matches.adapter = MatchAdapter(matchesDetailed, context, this, this, false)
            pageIndicator.attachTo(rv_matches)
        }
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
