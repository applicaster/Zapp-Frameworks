package com.applicaster.opta.statsscreenplugin.screens.team

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import com.applicaster.opta.statsscreenplugin.OptaStatsActivity
import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.data.model.PlayerSquadModel
import com.applicaster.opta.statsscreenplugin.data.model.TeamModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesInteractor
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesPresenter
import com.applicaster.opta.statsscreenplugin.screens.allmatches.AllMatchesView
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.GroupAdapter
import com.applicaster.opta.statsscreenplugin.screens.home.adapters.MatchAdapter
import com.applicaster.opta.statsscreenplugin.screens.team.adapter.SquadAdapter
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import com.applicaster.opta.statsscreenplugin.utils.PluginUtils
import com.applicaster.opta.statsscreenplugin.utils.UrlType
import com.applicaster.util.StringUtil
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.fragment_squad.*

class TeamFragment : Fragment(), TeamView, AllMatchesView, SquadAdapter.OnPlayerClickedListener,
        GroupAdapter.OnTeamFlagClickListener, MatchAdapter.OnMatchClickListener {


    private var teamPresenter: TeamPresenter = TeamPresenter(this, TeamInteractor())
    private var allMatchesPresenter: AllMatchesPresenter = AllMatchesPresenter(this, AllMatchesInteractor())
    private lateinit var teamId: String

    companion object {
        fun newInstance(teamId: String): Fragment {
            val args = Bundle()
            args.putString(OptaStatsActivity.TEAM_ID, teamId)
            val fragment = TeamFragment()
            fragment.arguments = args
            return fragment
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_squad, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        teamId = arguments?.get(OptaStatsActivity.TEAM_ID).toString()
        teamPresenter.getTeamSquad(teamId)
        teamPresenter.getTeamStats(teamId)
        teamPresenter.getTrophies(teamId)
        allMatchesPresenter.getAllMatchesById(teamId)

        if (!PluginDataRepository.INSTANCE.isShowTeam())
            ll_team.visibility = View.GONE
    }

    override fun getTeamStatsSuccess(team: TeamModel.Team) {
        val goals = ModelUtils.getTeamStatistic(team.contestant.stat, "Goals")
        val goalsConceded = ModelUtils.getTeamStatistic(team.contestant.stat,
                "Goals Conceded")
        val possessionPercentage = ModelUtils.getTeamStatistic(team.contestant.stat,
                "Possession Percentage")
        val passingAccuracy = ModelUtils.getTeamStatistic(team.contestant.stat,
                "Passing Accuracy")

        tv_gf_value.text = if (!StringUtil.isEmpty(goals)) goals else "-"
        tv_gc_value.text = if (!StringUtil.isEmpty(goalsConceded)) goalsConceded else "-"
        tv_possesion_value.text = if (!StringUtil.isEmpty(possessionPercentage)) String.format("%,.2f%%",
                possessionPercentage?.toFloat()) else "-"
        tv_pass_accuracy_value.text = if (!StringUtil.isEmpty(passingAccuracy)) String.format("%,.2f%%",
                passingAccuracy?.toFloat()) else "-"
    }

    override fun getAllMatchesSuccess(allMatches: List<MatchModel.Match>) {
        val allMatchesAdapter = MatchAdapter(allMatches, context, this, this, true)
        rv_matches_team.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        rv_matches_team.adapter = allMatchesAdapter
        allMatchesAdapter.notifyDataSetChanged()
        pi_matches.attachTo(rv_matches_team)
    }

    override fun getAllMatchesFail(error: String?) {
        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
    }

    override fun getTeamStatsFailed(error: String?) {
        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
    }

    override fun onTeamFlagClicked(teamId: String) {
        if(this.teamId != teamId) {
            PluginUtils.goToTeamScreen(teamId)
        }
    }

    override fun onMatchClicked(matchId: String) {
        PluginUtils.goToMatchDetailsScreen(matchId)
    }

    private fun toggleVisibility(viewData: Boolean) {
        if (viewData) {
            cl_container.visibility = View.VISIBLE
            rv_squad.visibility = View.VISIBLE
            rv_matches_team.visibility = View.VISIBLE
            pi_matches.visibility = View.VISIBLE
//            if (PluginDataRepository.INSTANCE.isShowTeam())
                ll_team.visibility = View.VISIBLE
            rl_info_not_available.visibility = View.GONE
        } else {
            cl_container.visibility = View.GONE
            rv_squad.visibility = View.GONE
            rv_matches_team.visibility = View.GONE
            pi_matches.visibility = View.GONE
            ll_team.visibility = View.GONE
            rl_info_not_available.visibility = View.VISIBLE
        }

    }

    override fun showProgress() {// todo: implement this method
    }

    override fun hideProgress() {// todo: implement this method
    }

    override fun onDestroy() {
        super.onDestroy()
        teamPresenter.onDestroy()
    }

    override fun onPlayerClicked(playerId: String) {
        PluginUtils.goToPlayerScreen(playerId)
    }

    override fun getTeamSquadSuccess(teamSquad: PlayerSquadModel.PlayerSquad) {
        val squad = teamSquad.squad[0]

        squad.contestantId?.let {
            Picasso.get().load(ModelUtils.getImageUrl(UrlType.Flag, it)).placeholder(R.drawable.unknow_flag).into(iv_team_flag)
            Picasso.get().load(ModelUtils.getImageUrl(UrlType.Shirt, it)).into(iv_team_shirt)
            Picasso.get().load(ModelUtils.getImageUrl(UrlType.Shield, it)).into(iv_team_shield)
        }
        tv_team_name.text = squad.contestantName

        if (squad.person.isNotEmpty()) {
            rv_squad.layoutManager = LinearLayoutManager(context)
            rv_squad.isNestedScrollingEnabled = false

            rv_squad.adapter = SquadAdapter(sortTeam(teamSquad.squad[0].person), context, this)
        } else {
            ll_team.visibility = View.GONE
        }

        toggleVisibility(true)
    }

    private fun sortTeam(team: List<PlayerSquadModel.Person>): List<PlayerSquadModel.Person> {

        val sortedTeam: MutableList<PlayerSquadModel.Person> = ArrayList()

        val goalKeepers : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("PLAYER", true) && s.position.equals("GOALKEEPER", true)
        }
        sortedTeam.addAll(goalKeepers)
        val defenders : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("PLAYER", true) && s.position.equals("DEFENDER", true)
        }
        sortedTeam.addAll(defenders)
        val midfielders : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("PLAYER", true) && s.position.equals("MIDFIELDER", true)
        }
        sortedTeam.addAll(midfielders)
        val strikers : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("PLAYER", true) && s.position.equals("ATTACKER", true)
        }
        sortedTeam.addAll(strikers)
        val unknowns : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("PLAYER", true) && s.position.equals("UNKNOWN", true)
        }
        sortedTeam.addAll(unknowns)
        val coaches : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("COACH", true)
        }
        sortedTeam.addAll(coaches)
        val assistantCoaches : List<PlayerSquadModel.Person> = team.filter { s ->
            s.type.equals("ASSISTANT COACH", true)
        }
        sortedTeam.addAll(assistantCoaches)

        return sortedTeam
    }

    override fun getTeamSquadFail(error: String?) {
        toggleVisibility(false)
    }

    override fun getTrophiesSuccess(counter: Int) {
        if (counter != 0) {
            tv_americas_cups_quantity.text = String.format("X%d", counter)
        } else {
            iv_cup.visibility = View.INVISIBLE
            tv_americas_cups_quantity.visibility = View.INVISIBLE
        }
    }

    override fun getTrophiesFailed(error: String?) {
        // do nothing
    }

    override fun onDestroyView() {
        super.onDestroyView()
        teamPresenter.onDestroy()
        allMatchesPresenter.onDestroy()
    }
}