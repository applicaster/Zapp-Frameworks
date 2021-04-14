package com.applicaster.opta.statsscreenplugin.screens.team

import com.applicaster.opta.statsscreenplugin.data.model.PlayerSquadModel
import com.applicaster.opta.statsscreenplugin.data.model.TeamModel
import com.applicaster.opta.statsscreenplugin.data.model.TrophiesModel


class TeamPresenter(private var teamView: TeamView?,
                    private val teamInteractor: TeamInteractor):
        TeamInteractor.OnFinishedListener {

    lateinit var teamId: String

    fun getTeamStats(teamId: String) {
        teamView?.showProgress()
        teamInteractor.requestTeamStats(this, teamId)
    }

    fun getTeamSquad(teamId: String) {
        teamInteractor.requestTeamSquad(this, teamId)
    }

    fun getTrophies(teamId: String) {
        this.teamId = teamId
        teamInteractor.requestTrophies(this)
    }

    fun onDestroy() {
        teamView = null
        teamInteractor.onDestroy()
    }

    override fun onGetTeamStatsSuccess(team: TeamModel.Team) {
        teamView?.hideProgress()
        teamView?.getTeamStatsSuccess(team)
    }

    override fun onGetTeamStatsFail(error: String?) {
        teamView?.hideProgress()
        teamView?.getTeamStatsFailed(error)
    }

    override fun onGetTeamSquadSuccess(teamSquad: PlayerSquadModel.PlayerSquad) {
        teamView?.getTeamSquadSuccess(teamSquad)
    }

    override fun onGetTeamSquadFail(error: String?) {
        teamView?.getTeamSquadFail(error)
    }

    override fun onGetTrophiesSuccess(trophies: TrophiesModel.Trophies) {
        val trophiesLoop = trophies.competition[0].trophy
        var counter = 0
        for(trophy in trophiesLoop) {
            if(trophy.winnerContestantId == teamId) {
                counter++
            }
        }
        teamView?.getTrophiesSuccess(counter)
    }

    override fun onGetTrophiesFailed(error: String?) {
        teamView?.getTrophiesFailed(error)
    }
}