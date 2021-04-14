package com.applicaster.opta.statsscreenplugin.screens.matchdetails

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface MatchDetailsView : View {
    fun getMatchDetailsSuccess(matchDetails: MatchModel.Match)
    fun getMatchDetailsFail(error: String?)
}