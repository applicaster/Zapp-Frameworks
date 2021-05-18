package com.applicaster.opta.statsscreenplugin.screens.allmatches

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.GroupAdapter
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.MatchAdapter
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import kotlinx.android.synthetic.main.fragment_all_matches.*

class AllMatchesFragment : Fragment(), AllMatchesView, GroupAdapter.OnTeamFlagClickListener,
        MatchAdapter.OnMatchClickListener {

    var allMatchesPresenter: AllMatchesPresenter = AllMatchesPresenter(this,
            AllMatchesInteractor())

    lateinit var allMatchesAdapter: MatchAdapter

    var matches: ArrayList<AllMatchesModel.Match> = ArrayList()

    companion object {
        fun newInstance(teamId: String): Fragment {
            val args = Bundle()
            args.putString(OptaStatsActivity.TEAM_ID, teamId)
            val fragment = AllMatchesFragment()
            fragment.arguments = args
            return fragment
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_all_matches, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        arguments?.get(OptaStatsActivity.TEAM_ID)?.let {
            allMatchesPresenter.getAllMatchesById(it.toString())
            return
        }

        allMatchesPresenter.getAllMatches()
    }

    override fun getAllMatchesSuccess(allMatches: List<MatchModel.Match>) {
        allMatchesAdapter = MatchAdapter(allMatches, context, this, this, true)
        rv_all_matches.layoutManager = LinearLayoutManager(context)
        rv_all_matches.adapter = allMatchesAdapter
        allMatchesAdapter.notifyDataSetChanged()
        rv_all_matches.scrollToPosition(ModelUtils.getPositionOfTodayMatch(allMatches))
    }

    override fun getAllMatchesFail(error: String?) {
        Log.e(this.javaClass.simpleName, error)
    }

    override fun showProgress() {
        pb_loading.visibility = View.VISIBLE
    }

    override fun hideProgress() {
        pb_loading.visibility = View.GONE
    }

    override fun onTeamFlagClicked(teamId: String) {
        PluginUtils.goToTeamScreen(teamId)
    }

    override fun onMatchClicked(matchId: String) {
        PluginUtils.goToMatchDetailsScreen(matchId)
    }

    override fun onDestroy() {
        super.onDestroy()
        allMatchesPresenter.onDestroy()
    }
}