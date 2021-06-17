package com.applicaster.opta.statsscreenplugin.screens.home

import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.base.HeartbeatFragment
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.GroupAdapter
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.MatchAdapter
import com.applicaster.opta.statsscreenplugin.screens.match.MatchInteractor
import com.applicaster.opta.statsscreenplugin.screens.match.MatchPresenter
import com.applicaster.opta.statsscreenplugin.screens.match.MatchView
import com.applicaster.opta.statsscreenplugin.utils.Constants.UTC_DATE_FORMAT
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import com.applicaster.lesscodeutils.date.DateUtils.Companion.getCurrentDate
import kotlinx.android.synthetic.main.fragment_home.*
import kotlin.collections.ArrayList

/**
 * To apply MVP architecture I used as reference this article
 * https://hackernoon.com/https-medium-com-rohitss-android-app-architectures-mvp-with-kotlin-f255b236010a
 */
class HomeFragment : HeartbeatFragment(), HomeView, MatchView, GroupAdapter.OnTeamFlagClickListener,
        MatchAdapter.OnMatchClickListener {

    companion object {
        @JvmStatic
        fun newInstance(): Fragment = HomeFragment()

        private const val TAG: String = "CopaHomeFragment"
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

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_home, container,
                false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // get all matches so we can get the matches corresponding to a specific date
        // this will be better if one of the api calls has an extra parameter to set the date
        // WARNING: this is not optimized because to get two or three matches (sometimes only one),
        // we need to get all matches
        // get groups
        homePresenter.getAllMatchesFromDate()
        homePresenter.getGroups()
    }

    override fun heartbeat() {
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

        val date = if (startDate > getCurrentDate(UTC_DATE_FORMAT)) startDate else getCurrentDate(UTC_DATE_FORMAT)
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
            matchesDetailed.add(0, MatchModel.Match())
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

    override fun onDestroy() {
        super.onDestroy()
        homePresenter.onDestroy()
        matchPresenter.onDestroy()
    }
}