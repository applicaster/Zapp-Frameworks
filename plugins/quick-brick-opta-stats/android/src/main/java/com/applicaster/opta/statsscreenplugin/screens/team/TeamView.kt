package com.applicaster.opta.statsscreenplugin.screens.team

import com.applicaster.opta.statsscreenplugin.data.model.PlayerSquadModel
import com.applicaster.opta.statsscreenplugin.data.model.TeamModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface TeamView : View {
    fun getTeamStatsSuccess(team: TeamModel.Team)
    fun getTeamStatsFailed(error: String?)
    fun getTeamSquadSuccess(teamSquad: PlayerSquadModel.PlayerSquad)
    fun getTeamSquadFail(error: String?)
    fun getTrophiesSuccess(counter: Int)
    fun getTrophiesFailed(error: String?)
}